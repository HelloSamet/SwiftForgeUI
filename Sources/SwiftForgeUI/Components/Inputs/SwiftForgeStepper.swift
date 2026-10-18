//
//  SwiftForgeStepper.swift
//  SwiftForgeUI
//

import SwiftUI

/// A labeled control for stepping a value up and down within a range, that
/// speeds up while a button is held.
///
/// ```swift
/// SwiftForgeStepper("Guests", value: $guests, in: 1...12) { Text($0, format: .number) }
/// SwiftForgeStepper("Tip", value: $tip, in: 0...30, step: 5) { Text("\($0)%") }
/// ```
///
/// Tapping a button moves one step. Holding it repeats after a short pause,
/// faster the longer it's held. The minus button dims at the lower bound and
/// the plus button at the upper bound.
///
/// VoiceOver sees a standard adjustable stepper — swipe up or down to change
/// the value — and reads the value label. Buttons keep 44-pt hit areas.
public struct SwiftForgeStepper<V: Strideable & Sendable>: View where V.Stride: Sendable {

    private let title: Text
    @Binding private var value: V
    private let bounds: ClosedRange<V>
    private let step: V.Stride
    private let valueLabel: (V) -> Text

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @State private var repeatTask: Task<Void, Never>?
    @State private var didRepeat = false

    /// Creates a stepper.
    ///
    /// - Parameters:
    ///   - titleKey: The stepper's title, read by VoiceOver.
    ///   - value: The value to change.
    ///   - bounds: The range of valid values.
    ///   - step: How much each step changes the value. Defaults to 1.
    ///   - valueLabel: The value as text, shown between the buttons.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in bounds: ClosedRange<V>,
        step: V.Stride = 1,
        valueLabel: @escaping (V) -> Text
    ) {
        title = Text(titleKey)
        _value = value
        self.bounds = bounds
        self.step = step
        self.valueLabel = valueLabel
    }

    /// The content and behavior of the view.
    public var body: some View {
        HStack(spacing: theme.spacing.sm) {
            title
                .font(theme.typography.font(theme.typography.body))
                .foregroundStyle(theme.colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: theme.spacing.xxs) {
                button(direction: -1, systemImage: "minus", label: SwiftForgeStrings.decrement)
                valueLabel(value)
                    .font(theme.typography.font(theme.typography.body.weight(.semibold)))
                    .monospacedDigit()
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(minWidth: theme.sizes.minimumHitTarget)
                    .multilineTextAlignment(.center)
                button(direction: 1, systemImage: "plus", label: SwiftForgeStrings.increment)
            }
            .fixedSize()
        }
        .frame(minHeight: theme.sizes.minimumHitTarget)
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .swiftForgeHaptic(trigger: value) { _, _ in .selection }
        .accessibilityRepresentation {
            Stepper(value: $value, in: bounds, step: step) { title }
                .accessibilityValue(valueLabel(value))
        }
        .onDisappear { stopRepeating() }
    }

    private func button(direction: Int, systemImage: String, label: Text) -> some View {
        Button {
            // A hold has already stepped; its release isn't another tap.
            if didRepeat {
                didRepeat = false
            } else {
                move(direction)
            }
        } label: {
            Label {
                label
            } icon: {
                Image(systemName: systemImage)
            }
        }
        .buttonStyle(.swiftForgeIcon(.tinted, shape: .circle))
        .controlSize(.small)
        .disabled(!canMove(direction))
        // Watches the hold alongside the button's own tap handling.
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if repeatTask == nil { startRepeating(direction) }
                }
                .onEnded { _ in stopRepeating() }
        )
    }

    private func canMove(_ direction: Int) -> Bool {
        direction < 0 ? value > bounds.lowerBound : value < bounds.upperBound
    }

    private func move(_ direction: Int) {
        let next = value.advanced(by: direction < 0 ? -step : step)
        value = min(max(next, bounds.lowerBound), bounds.upperBound)
    }

    /// Repeats the step after a pause, every interval a little shorter.
    private func startRepeating(_ direction: Int) {
        stopRepeating()
        repeatTask = Task { @MainActor in
            var interval = Self.firstRepeatInterval
            try? await Task.sleep(for: Self.holdDelay)
            while !Task.isCancelled, canMove(direction) {
                didRepeat = true
                move(direction)
                try? await Task.sleep(for: interval)
                interval = max(Self.fastestRepeatInterval, interval * Self.acceleration)
            }
        }
    }

    private func stopRepeating() {
        repeatTask?.cancel()
        repeatTask = nil
    }

    // Behavior timings, not visual tokens.
    private static var holdDelay: Duration { .milliseconds(400) }  // swiftforge-lint: allow (behavior timing)
    private static var firstRepeatInterval: Duration { .milliseconds(250) }  // swiftforge-lint: allow (behavior timing)
    private static var fastestRepeatInterval: Duration { .milliseconds(40) }  // swiftforge-lint: allow (behavior timing)
    private static var acceleration: Double { 0.8 }  // swiftforge-lint: allow (behavior timing)
}

// MARK: - Previews

private struct StepperPreview: View {
    @State private var guests = 2
    @State private var tip = 15

    var body: some View {
        VStack(spacing: 8) {
            SwiftForgeStepper("Guests", value: $guests, in: 1...12) { Text($0, format: .number) }
            SwiftForgeStepper("Tip", value: $tip, in: 0...30, step: 5) { Text(verbatim: "\($0)%") }
            SwiftForgeStepper("Disabled", value: .constant(3), in: 0...5) { Text($0, format: .number) }.disabled(true)
        }
        .padding()
    }
}

#Preview("Stepper") { StepperPreview() }

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeStepper("Guests", value: .constant(2), in: 1...12) { Text($0, format: .number) }
    }
}
