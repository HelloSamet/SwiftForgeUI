//
//  SwiftForgeCheckboxToggleStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// A checkbox in the theme's colors and shapes, for any native `Toggle`.
///
/// ```swift
/// Toggle("I agree to the terms", isOn: $agrees)
///     .toggleStyle(.swiftForgeCheckbox)
/// ```
///
/// A toggle that controls several values shows the mixed state — a dash —
/// when only some are on. Create it with SwiftUI's `Toggle(sources:isOn:)`;
/// tapping a mixed checkbox turns every value on:
///
/// ```swift
/// Toggle(sources: $toppings, isOn: \.isSelected) {
///     Text("All toppings")
/// }
/// .toggleStyle(.swiftForgeCheckbox)
/// ```
///
/// The box sits before the label, aligned with its first line, and the
/// whole row is tappable and at least 44 pt tall. A checked box fills with
/// the tone and shows a checkmark, so the state never relies on color.
/// VoiceOver and Voice Control see a standard toggle with its state — off,
/// on, or mixed — and VoiceOver reads the description set with
/// ``SwiftUICore/View/swiftForgeDescription(_:)-(Text?)`` as the hint.
///
/// - Do: use checkboxes for independent choices and for confirming terms.
/// - Don't: use a checkbox for a setting that applies immediately; use a
///   switch (``SwiftForgeToggleStyle``) instead.
///
/// The box's size, corners, and outline come from ``SwiftForgeSelectionControlTokens``.
public struct SwiftForgeCheckboxToggleStyle: ToggleStyle {

    let tone: SwiftForgeTone

    /// Creates a checkbox style.
    ///
    /// - Parameter tone: The box's color when checked. Defaults to the accent.
    public init(tone: SwiftForgeTone = .accent) {
        self.tone = tone
    }

    /// Creates a view that represents the body of a toggle.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeCheckbox(configuration: configuration, tone: tone)
    }
}

extension ToggleStyle where Self == SwiftForgeCheckboxToggleStyle {

    /// A checkbox in the theme's accent color.
    public static var swiftForgeCheckbox: Self { SwiftForgeCheckboxToggleStyle() }

    /// A checkbox in a tone's color.
    public static func swiftForgeCheckbox(tone: SwiftForgeTone) -> Self { SwiftForgeCheckboxToggleStyle(tone: tone) }
}

private struct SwiftForgeCheckbox: View {

    let configuration: ToggleStyleConfiguration
    let tone: SwiftForgeTone

    @Environment(\.swiftForgeControlDescription) private var description

    var body: some View {
        Button(action: toggle) {
            configuration.label
        }
        .buttonStyle(SwiftForgeSelectionRowStyle(shape: .checkbox, state: state, tone: tone))
        // The enclosing `Toggle` reports its own state — off, on, or mixed —
        // to VoiceOver and Voice Control, whatever the style draws.
        .accessibilityHint(description ?? Text(verbatim: ""))
        .swiftForgeHaptic(trigger: state) { _, _ in .selection }
    }

    /// A mixed checkbox turns everything on, like the system's.
    private func toggle() {
        configuration.isOn = configuration.isMixed ? true : !configuration.isOn
    }

    private var state: SwiftForgeSelectionState {
        configuration.isMixed ? .mixed : configuration.isOn ? .on : .off
    }

}

/// A checkbox or radio row: the indicator before the label and its
/// description, the whole row tappable and at least 44 pt tall.
struct SwiftForgeSelectionRowStyle: ButtonStyle {

    let shape: SwiftForgeSelectionIndicator.Shape
    let state: SwiftForgeSelectionState
    let tone: SwiftForgeTone

    func makeBody(configuration: Configuration) -> some View {
        SwiftForgeSelectionRow(
            label: configuration.label, shape: shape, state: state, tone: tone, isPressed: configuration.isPressed)
    }
}

private struct SwiftForgeSelectionRow<Label: View>: View {

    let label: Label
    let shape: SwiftForgeSelectionIndicator.Shape
    let state: SwiftForgeSelectionState
    let tone: SwiftForgeTone
    let isPressed: Bool

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.swiftForgeDensity) private var density

    var body: some View {
        SwiftForgeLabelsVisibilityReader { labelsHidden in
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                SwiftForgeSelectionIndicator(shape: shape, state: state, tone: tone, isPressed: isPressed, isFocused: isFocused)
                if labelsHidden {
                    // Not drawn, but still the control's VoiceOver label.
                    label.swiftForgeVisuallyHidden()
                } else {
                    SwiftForgeControlLabel(label: label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, density.itemSpacing(in: theme.spacing))
        .frame(minHeight: theme.sizes.minimumHitTarget)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
    }
}

// MARK: - Previews

private struct Topping: Identifiable {
    let id: String
    var isSelected: Bool
}

private struct CheckboxPreview: View {
    @State private var agrees = true
    @State private var newsletter = false
    @State private var toppings = [Topping(id: "Cheese", isSelected: true), Topping(id: "Olives", isSelected: false)]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Toggle("I agree to the terms", isOn: $agrees)
            Toggle("Send me the newsletter", isOn: $newsletter)
                .swiftForgeDescription("About once a month. Unsubscribe any time.")
            Toggle(sources: $toppings, isOn: \.isSelected) { Text(verbatim: "All toppings") }
            ForEach($toppings) { $topping in
                Toggle(topping.id, isOn: $topping.isSelected).padding(.leading, SwiftForgeTheme.forge.spacing.xxl)
            }
            Toggle("Delete my data", isOn: .constant(true)).toggleStyle(.swiftForgeCheckbox(tone: .danger))
            Toggle("Disabled", isOn: .constant(true)).disabled(true)
        }
        .toggleStyle(.swiftForgeCheckbox)
        .padding()
    }
}

#Preview("Checkbox") { CheckboxPreview() }

#Preview("Dark, AX5, RTL") {
    CheckboxPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(alignment: .leading, spacing: 0) {
            Toggle("Checked", isOn: .constant(true))
            Toggle("Unchecked", isOn: .constant(false))
            Toggle(sources: Binding.constant([true, false]), isOn: \.self) { Text(verbatim: "Mixed") }
            Toggle("Disabled", isOn: .constant(true)).disabled(true)
        }
        .toggleStyle(.swiftForgeCheckbox)
    }
}
