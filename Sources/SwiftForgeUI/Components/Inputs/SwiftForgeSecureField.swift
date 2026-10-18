//
//  SwiftForgeSecureField.swift
//  SwiftForgeUI
//

import SwiftUI

/// A labeled password field with a show/hide button and validation messages.
///
/// ```swift
/// SwiftForgeSecureField("Password", text: $password, state: passwordState)
///     .textContentType(.newPassword)
/// ```
///
/// Showing the password swaps the secure field for a plain one while keeping
/// the text, the keyboard focus, and the content type, so password managers
/// keep working. The password is hidden again whenever the app leaves the
/// foreground. Use ``SwiftUICore/View/swiftForgeRevealButton(_:)`` to remove the
/// show/hide button, and ``SwiftUICore/View/swiftForgePasswordStrength(_:)``
/// to show how strong a new password is.
///
/// Layout, states, and accessibility match ``SwiftForgeTextField``.
public struct SwiftForgeSecureField: View {

    private enum Field: Hashable { case secure, plain }

    private var label: Text
    @Binding private var text: String
    private let prompt: Text?
    private let state: SwiftForgeFieldState

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeRevealButtonIsVisible) private var revealButtonIsVisible
    @Environment(\.swiftForgePasswordStrength) private var strength
    @Environment(\.scenePhase) private var scenePhase
    @State private var isRevealed = false
    @FocusState private var focusedField: Field?

    /// Creates a secure field with a localized label.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver.
    ///   - text: The password to edit.
    ///   - prompt: Placeholder text shown while the field is empty. Defaults to none: the
    ///     label above the field already names it.
    ///   - state: The validation state and its message. Defaults to ``SwiftForgeFieldState/normal``.
    public init(_ titleKey: LocalizedStringKey, text: Binding<String>, prompt: Text? = nil, state: SwiftForgeFieldState = .normal)
    {
        self.label = Text(titleKey)
        self._text = text
        self.prompt = prompt
        self.state = state
    }

    /// Creates a secure field with a label that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, text: Binding<String>, prompt: Text? = nil, state: SwiftForgeFieldState = .normal)
    {
        self.label = Text(title)
        self._text = text
        self.prompt = prompt
        self.state = state
    }

    /// The content and behavior of the view.
    public var body: some View {
        container
            .onChange(of: isRevealed) { _, newValue in
                if focusedField != nil {
                    focusedField = newValue ? .plain : .secure
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase != .active { isRevealed = false }
            }
    }

    private var container: SwiftForgeFieldContainer<some View, EmptyView, some View> {
        var container = SwiftForgeFieldContainer(
            label: label,
            state: state,
            isFocused: focusedField != nil,
            characterCount: text.count,
            field: field,
            leading: EmptyView(),
            trailing: revealButton
        )
        if let strength {
            let meter = SwiftForgePasswordStrengthMeter(strength: strength)
            container.supplement = AnyView(meter)  // swiftforge-lint: allow (ADR-0015)
        }
        return container
    }

    @ViewBuilder
    private var field: some View {
        // Without a prompt, SwiftUI would repeat the label, already shown
        // above the field, as the placeholder.
        let styledPrompt = (prompt ?? Text(verbatim: "")).foregroundStyle(theme.colors.textSecondary)
        Group {
            if isRevealed {
                TextField(text: $text, prompt: styledPrompt) { label }
                    .focused($focusedField, equals: .plain)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } else {
                SecureField(text: $text, prompt: styledPrompt) { label }
                    .focused($focusedField, equals: .secure)
            }
        }
        .font(theme.typography.font(theme.typography.body))
        .foregroundStyle(theme.colors.textPrimary)
        .accessibilityCustomContent(
            SwiftForgeStrings.passwordStrength,
            strength.map(SwiftForgeStrings.passwordStrengthName) ?? Text(verbatim: ""),
            importance: .high
        )
    }

    @ViewBuilder
    private var revealButton: some View {
        if revealButtonIsVisible {
            SwiftForgeFieldAccessoryButton(
                systemImage: isRevealed ? "eye.slash" : "eye",
                label: isRevealed ? SwiftForgeStrings.hidePassword : SwiftForgeStrings.showPassword
            ) {
                isRevealed.toggle()
            }
        }
    }
}

private struct SecureFieldPreview: View {
    @State private var password = "correct horse"
    @State private var newPassword = ""

    var body: some View {
        VStack(spacing: 16) {
            SwiftForgeSecureField("Password", text: $password)
            SwiftForgeSecureField(
                "New password", text: $newPassword, prompt: Text("At least 12 characters"),
                state: .error("Use at least 12 characters."))
            ForEach(SwiftForgePasswordStrength.allCases, id: \.self) { strength in
                SwiftForgeSecureField("Password", text: .constant("correct horse"), state: .helper("Use 12 or more characters."))
                    .swiftForgePasswordStrength(strength)
            }
        }
        .padding()
    }
}

#Preview("Secure field") { SecureFieldPreview() }

#Preview("Dark, AX3") {
    SecureFieldPreview()
        .environment(\.dynamicTypeSize, .accessibility3)
        .preferredColorScheme(.dark)
}
