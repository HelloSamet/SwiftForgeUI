//
//  SwiftForgeRadioGroup.swift
//  SwiftForgeUI
//

import SwiftUI

/// A titled group of radio buttons for choosing one option.
///
/// ```swift
/// SwiftForgeRadioGroup("Delivery", selection: $delivery, options: Delivery.allCases) { option in
///     Text(option.title)
/// }
/// ```
///
/// Pass an optional selection to start with nothing chosen, and a
/// ``SwiftForgeFieldState`` to show guidance or an error below the options:
///
/// ```swift
/// SwiftForgeRadioGroup(
///     "Plan", selection: $plan, options: plans,
///     state: showsErrors && plan == nil ? .error("Choose a plan.") : .normal
/// ) { plan in
///     VStack(alignment: .leading) {
///         Text(plan.name)
///         Text(plan.price).foregroundStyle(.secondary)
///     }
/// }
/// ```
///
/// Options stack vertically by default; with `axis: .horizontal` they flow
/// in rows and wrap, and stack again at accessibility text sizes. Each
/// option is a 44-pt row with its ring aligned to the first line of its
/// label; a chosen ring shows a dot, so the choice never relies on color.
///
/// VoiceOver reads the title as a heading — with the state's message — and
/// each option as a button with its position, such as "Express, selected,
/// button, 2 of 3".
///
/// - Do: use radio buttons for two to five mutually exclusive options that
///   should all be visible.
/// - Don't: use them for many options; use ``SwiftForgePicker`` instead.
public struct SwiftForgeRadioGroup<Value: Hashable, Label: View>: View {

    private var title: Text
    private let options: [Value]
    private let isSelected: (Value) -> Bool
    private let select: (Value) -> Void
    private let state: SwiftForgeFieldState
    private let axis: Axis
    private let tone: SwiftForgeTone
    private let label: (Value) -> Label

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeDensity) private var density
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Creates a radio group with a selection that's always set.
    ///
    /// - Parameters:
    ///   - titleKey: The group's title, shown above the options.
    ///   - selection: The chosen option.
    ///   - options: The options, in display order.
    ///   - state: Guidance or an error shown below the options.
    ///   - axis: Whether options stack vertically or flow horizontally.
    ///   - tone: The color of the chosen ring. Defaults to the accent.
    ///   - label: A view for each option.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [Value],
        state: SwiftForgeFieldState = .normal,
        axis: Axis = .vertical,
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(
            title: Text(titleKey), options: options, isSelected: { selection.wrappedValue == $0 },
            select: { selection.wrappedValue = $0 }, state: state, axis: axis, tone: tone, label: label)
    }

    /// Creates a radio group that starts with no option chosen.
    ///
    /// - Parameters:
    ///   - titleKey: The group's title, shown above the options.
    ///   - selection: The chosen option, or `nil` for none.
    ///   - options: The options, in display order.
    ///   - state: Guidance or an error shown below the options.
    ///   - axis: Whether options stack vertically or flow horizontally.
    ///   - tone: The color of the chosen ring. Defaults to the accent.
    ///   - label: A view for each option.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value?>,
        options: [Value],
        state: SwiftForgeFieldState = .normal,
        axis: Axis = .vertical,
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(
            title: Text(titleKey), options: options, isSelected: { selection.wrappedValue == $0 },
            select: { selection.wrappedValue = $0 }, state: state, axis: axis, tone: tone, label: label)
    }

    init(
        title: Text, options: [Value], isSelected: @escaping (Value) -> Bool, select: @escaping (Value) -> Void,
        state: SwiftForgeFieldState, axis: Axis, tone: SwiftForgeTone, label: @escaping (Value) -> Label
    ) {
        self.title = title
        self.options = options
        self.isSelected = isSelected
        self.select = select
        self.state = state
        self.axis = axis
        self.tone = tone
        self.label = label
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            title
                .font(theme.typography.font(theme.typography.fieldLabel))
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityAddTraits(.isHeader)
                .modifier(SwiftForgeFieldAccessibility(state: state))

            optionsLayout {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    let selected = isSelected(option)
                    Button {
                        select(option)
                    } label: {
                        label(option)
                    }
                    .buttonStyle(SwiftForgeSelectionRowStyle(shape: .radio, state: selected ? .on : .off, tone: tone))
                    .accessibilityAddTraits(selected ? .isSelected : [])
                    .accessibilityValue(SwiftForgeStrings.position(index + 1, of: options.count))
                }
            }

            if state.message != nil {
                SwiftForgeFieldMessage(state: state)
            }
        }
        .swiftForgeHaptic(trigger: options.firstIndex(where: isSelected)) { old, new in old == nil ? nil : .selection }
        .accessibilityElement(children: .contain)
    }

    private var optionsLayout: AnyLayout {
        if axis == .horizontal, !dynamicTypeSize.isAccessibilitySize {
            AnyLayout(SwiftForgeFlowLayout(horizontalSpacing: theme.spacing.lg, verticalSpacing: 0))
        } else {
            AnyLayout(VStackLayout(alignment: .leading, spacing: 0))
        }
    }
}

extension SwiftForgeRadioGroup {

    /// Creates a radio group with a title that isn't localized and a
    /// selection that's always set.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [Value],
        state: SwiftForgeFieldState = .normal,
        axis: Axis = .vertical,
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(
            title: Text(title), options: options, isSelected: { selection.wrappedValue == $0 },
            select: { selection.wrappedValue = $0 }, state: state, axis: axis, tone: tone, label: label)
    }
}

// MARK: - Previews

private enum Delivery: String, CaseIterable {
    case standard = "Standard"
    case express = "Express"
    case pickup = "Store pickup"
}

private struct RadioGroupPreview: View {
    @State private var delivery = Delivery.express
    @State private var size: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SwiftForgeRadioGroup("Delivery", selection: $delivery, options: Delivery.allCases) { option in
                Text(option.rawValue)
            }
            SwiftForgeRadioGroup(
                "Size", selection: $size, options: ["S", "M", "L", "XL"], state: .error("Choose a size."), axis: .horizontal
            ) { Text($0) }
            SwiftForgeRadioGroup("Disabled", selection: .constant("On"), options: ["On", "Off"]) { Text($0) }
                .disabled(true)
        }
        .padding()
    }
}

#Preview("Radio group") { RadioGroupPreview() }

#Preview("Dark, AX5, RTL") {
    RadioGroupPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeRadioGroup("Delivery", selection: .constant(Delivery.express), options: Delivery.allCases) { option in
            Text(option.rawValue)
        }
    }
}
