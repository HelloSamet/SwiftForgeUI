//
//  SwiftForgeFieldContainer.swift
//  SwiftForgeUI
//

import SwiftUI

/// The label, input area, accessories, and message shared by every
/// SwiftForgeUI form field — for building your own field around any control.
///
/// ``SwiftForgeTextField`` and ``SwiftForgeSecureField`` are built on this
/// container. Use it to give another control the same layout, states, and
/// accessibility:
///
/// ```swift
/// struct AmountField: View {
///     @Binding var amount: Decimal
///     @FocusState private var isFocused: Bool
///
///     var body: some View {
///         SwiftForgeFieldContainer("Amount", isFocused: isFocused) {
///             TextField("Amount", value: $amount, format: .currency(code: "EUR"))
///                 .keyboardType(.decimalPad)
///                 .focused($isFocused)
///         } leading: {
///             Image(systemName: "eurosign")
///         }
///     }
/// }
/// ```
///
/// The container applies the label as the control's accessibility label,
/// reads helper text as its hint, and reads and announces error and success
/// messages, so put exactly one accessibility element in `field`. It doesn't
/// track focus: pass whether the control is focused.
///
/// Its appearance comes from the ``SwiftForgeFieldStyle`` in the
/// environment, ``SwiftForgeAutomaticFieldStyle`` by default.
public struct SwiftForgeFieldContainer<Field: View, Leading: View, Trailing: View>: View {

    private var label: Text
    private let state: SwiftForgeFieldState
    private let isFocused: Bool
    private let characterCount: Int?
    private let field: Field
    private let leading: Leading
    private let trailing: Trailing
    /// Shown above the message row, such as a password strength meter.
    var supplement: AnyView?  // swiftforge-lint: allow (ADR-0015)
    /// The control's accessibility value, for controls that don't report
    /// one themselves, such as a menu showing the chosen option.
    var accessibilityValue: Text?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.swiftForgeFieldStyle) private var style
    @Environment(\.swiftForgeCharacterLimit) private var characterLimit
    @Environment(\.swiftForgeFieldIsOptional) private var isOptional

    /// Creates a field container.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver
    ///     as the control's label.
    ///   - state: The validation state and its message. Defaults to ``SwiftForgeFieldState/normal``.
    ///   - isFocused: Whether the control has keyboard focus.
    ///   - characterCount: The number of characters entered, to show beside
    ///     the limit set with ``SwiftUICore/View/swiftForgeCharacterLimit(_:)``.
    ///     Pass `nil` for controls without text.
    ///   - field: The editable control.
    ///   - leading: An accessory before the control, typically an icon.
    ///   - trailing: An accessory after the control, such as a unit or a button.
    public init(
        _ titleKey: LocalizedStringKey,
        state: SwiftForgeFieldState = .normal,
        isFocused: Bool = false,
        characterCount: Int? = nil,
        @ViewBuilder field: () -> Field,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(
            label: Text(titleKey), state: state, isFocused: isFocused, characterCount: characterCount,
            field: field(), leading: leading(), trailing: trailing())
    }

    /// Creates a field container with a label that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        state: SwiftForgeFieldState = .normal,
        isFocused: Bool = false,
        characterCount: Int? = nil,
        @ViewBuilder field: () -> Field,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(
            label: Text(title), state: state, isFocused: isFocused, characterCount: characterCount,
            field: field(), leading: leading(), trailing: trailing())
    }

    init(
        label: Text, state: SwiftForgeFieldState, isFocused: Bool, characterCount: Int?, field: Field, leading: Leading,
        trailing: Trailing
    ) {
        self.label = label
        self.state = state
        self.isFocused = isFocused
        self.characterCount = characterCount
        self.field = field
        self.leading = leading
        self.trailing = trailing
    }

    /// The content and behavior of the view.
    public var body: some View {
        style.resolvedBody(configuration: configuration)
            .opacity(isEnabled ? 1 : theme.opacity.disabled)
            .accessibilityElement(children: .contain)
    }

    private var configuration: SwiftForgeFieldStyleConfiguration {
        SwiftForgeFieldStyleConfiguration(
            label: .init(content: AnyView(label.accessibilityHidden(true))),  // swiftforge-lint: allow (ADR-0015)
            optionalNote: isOptional ? SwiftForgeStrings.optional : nil,
            content: .init(content: AnyView(inputArea)),  // swiftforge-lint: allow (ADR-0015)
            message: messageRow,
            state: state,
            isFocused: isFocused
        )
    }

    /// The supplement and the message row, or `nil` when there's neither.
    private var messageRow: SwiftForgeFieldStyleConfiguration.Message? {
        let hasMessage = SwiftForgeFieldMessage.isVisible(
            state: state, characterCount: counterValue, characterLimit: characterLimit)
        guard hasMessage || supplement != nil else { return nil }
        return .init(
            content: AnyView(  // swiftforge-lint: allow (ADR-0015)
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    supplement
                    if hasMessage {
                        SwiftForgeFieldMessage(state: state, characterCount: counterValue, characterLimit: characterLimit)
                    }
                }
            ))
    }

    /// The count shown in the counter: only when a limit is set.
    private var counterValue: Int? {
        characterLimit == nil ? nil : characterCount
    }

    private var inputArea: some View {
        HStack(spacing: theme.spacing.xs) {
            leading
                .foregroundStyle(theme.colors.textSecondary)
            field
                // With a prompt, SwiftUI would otherwise read the prompt as the label.
                .accessibilityLabel(label)
                .modifier(SwiftForgeOptionalAccessibilityValue(value: accessibilityValue))
                .modifier(SwiftForgeFieldAccessibility(state: state))
                .frame(maxWidth: .infinity, alignment: .leading)
            trailing
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.horizontal, theme.fieldContentInset)
        // Vertical padding lets the field grow with Dynamic Type instead of
        // clipping large text against its outline.
        .padding(.vertical, theme.spacing.xs)
    }
}

extension SwiftForgeFieldContainer where Leading == EmptyView, Trailing == EmptyView {

    /// Creates a field container without accessories.
    public init(
        _ titleKey: LocalizedStringKey,
        state: SwiftForgeFieldState = .normal,
        isFocused: Bool = false,
        characterCount: Int? = nil,
        @ViewBuilder field: () -> Field
    ) {
        self.init(titleKey, state: state, isFocused: isFocused, characterCount: characterCount, field: field) {
            EmptyView()
        } trailing: {
            EmptyView()
        }
    }
}

extension SwiftForgeFieldContainer where Trailing == EmptyView {

    /// Creates a field container with a leading accessory, typically an icon.
    public init(
        _ titleKey: LocalizedStringKey,
        state: SwiftForgeFieldState = .normal,
        isFocused: Bool = false,
        characterCount: Int? = nil,
        @ViewBuilder field: () -> Field,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(titleKey, state: state, isFocused: isFocused, characterCount: characterCount, field: field, leading: leading) {
            EmptyView()
        }
    }
}

// MARK: - Previews

private struct ContainerPreview: View {
    @State private var amount = 12.5
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            SwiftForgeFieldContainer("Amount", state: .helper("Charged when the order ships."), isFocused: isFocused) {
                TextField("Amount", value: $amount, format: .number)
                    .focused($isFocused)
            } leading: {
                Image(systemName: "eurosign")
            }
            SwiftForgeFieldContainer("Quantity", state: .error("Only 3 left in stock.")) {
                Stepper(value: .constant(4), in: 1...10) { Text(verbatim: "4") }
            }
        }
        .padding()
    }
}

#Preview("Custom controls") { ContainerPreview() }

#Preview("All themes") {
    SwiftForgeThemeMatrix { ContainerPreview() }
}

/// Sets an accessibility value only when there is one: an empty value would
/// replace the one a text field reports — its text.
private struct SwiftForgeOptionalAccessibilityValue: ViewModifier {
    let value: Text?

    func body(content: Content) -> some View {
        if let value {
            content.accessibilityValue(value)
        } else {
            content
        }
    }
}
