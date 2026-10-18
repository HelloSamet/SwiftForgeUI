//
//  SwiftForgeTextField.swift
//  SwiftForgeUI
//

import SwiftUI

/// A labeled, single-line text field with validation messages, accessories,
/// a clear button, and a character limit.
///
/// ```swift
/// SwiftForgeTextField("Email", text: $email, prompt: Text("you@example.com"), state: emailState) {
///     Image(systemName: "envelope")
/// }
/// .keyboardType(.emailAddress)
/// .textContentType(.emailAddress)
/// .textInputAutocapitalization(.never)
/// .swiftForgeClearButton(.whileEditing)
/// ```
///
/// The field wraps a native `TextField`, so `keyboardType`, `textContentType`,
/// `submitLabel`, `onSubmit`, and `focused` work as usual.
///
/// The label is always visible above the field — a prompt never replaces
/// it — and is the field's VoiceOver label. Error and success messages are
/// read with the field and announced when they change. Use `controlSize(.large)`
/// for a 52-pt field, and ``SwiftUICore/View/swiftForgeFieldStyle(_:)`` to
/// change how every field looks.
public struct SwiftForgeTextField<Leading: View, Trailing: View>: View {

    private var label: Text
    @Binding private var text: String
    private let prompt: Text?
    private let state: SwiftForgeFieldState
    private let leading: Leading
    private let trailing: Trailing

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeClearButton) private var clearButton
    @Environment(\.swiftForgeCharacterLimit) private var characterLimit
    @FocusState private var isFocused: Bool

    /// Creates a text field with leading and trailing accessories.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver.
    ///   - text: The text to edit.
    ///   - prompt: Placeholder text shown while the field is empty. Defaults to none: the
    ///     label above the field already names it.
    ///   - state: The validation state and its message. Defaults to ``SwiftForgeFieldState/normal``.
    ///   - leading: An accessory before the text, typically an icon.
    ///   - trailing: An accessory after the text, such as a unit or a button.
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        state: SwiftForgeFieldState = .normal,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.label = Text(titleKey)
        self._text = text
        self.prompt = prompt
        self.state = state
        self.leading = leading()
        self.trailing = trailing()
    }

    /// The content and behavior of the view.
    public var body: some View {
        SwiftForgeFieldContainer(
            label: label,
            state: state,
            isFocused: isFocused,
            characterCount: text.count,
            field: field,
            leading: leading,
            trailing: HStack(spacing: theme.spacing.xs) {
                if showsClearButton {
                    SwiftForgeFieldAccessoryButton(systemImage: "xmark.circle.fill", label: SwiftForgeStrings.clearText) {
                        text = ""
                    }
                }
                trailing
            }
        )
    }

    private var field: some View {
        // Without a prompt, SwiftUI would repeat the label, already shown
        // above the field, as the placeholder.
        TextField(text: $text, prompt: (prompt ?? Text(verbatim: "")).foregroundStyle(theme.colors.textSecondary)) { label }
            .focused($isFocused)
            .font(theme.typography.font(theme.typography.body))
            .foregroundStyle(theme.colors.textPrimary)
            .onChange(of: text) { _, newValue in
                if let characterLimit, newValue.count > characterLimit {
                    text = String(newValue.prefix(characterLimit))
                }
            }
    }

    private var showsClearButton: Bool {
        guard !text.isEmpty else { return false }
        switch clearButton {
        case .never: return false
        case .whileEditing: return isFocused
        case .always: return true
        }
    }
}

extension SwiftForgeTextField where Leading == EmptyView, Trailing == EmptyView {

    /// Creates a text field with a localized label.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver.
    ///   - text: The text to edit.
    ///   - prompt: Placeholder text shown while the field is empty. Defaults to none: the
    ///     label above the field already names it.
    ///   - state: The validation state and its message. Defaults to ``SwiftForgeFieldState/normal``.
    public init(_ titleKey: LocalizedStringKey, text: Binding<String>, prompt: Text? = nil, state: SwiftForgeFieldState = .normal)
    {
        self.init(titleKey, text: text, prompt: prompt, state: state, leading: { EmptyView() }, trailing: { EmptyView() })
    }

    /// Creates a text field with a label that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, text: Binding<String>, prompt: Text? = nil, state: SwiftForgeFieldState = .normal)
    {
        self.init("", text: text, prompt: prompt, state: state, leading: { EmptyView() }, trailing: { EmptyView() })
        self.label = Text(title)
    }
}

extension SwiftForgeTextField where Trailing == EmptyView {

    /// Creates a text field with a leading accessory, typically an icon.
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        state: SwiftForgeFieldState = .normal,
        @ViewBuilder leading: () -> Leading
    ) {
        self.init(titleKey, text: text, prompt: prompt, state: state, leading: leading, trailing: { EmptyView() })
    }
}

// MARK: - Previews

private struct TextFieldPreview: View {
    @State private var email = "sam@"
    @State private var name = ""
    @State private var username = "sam"
    @State private var bio = "Designer"

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                SwiftForgeTextField("Name", text: $name, prompt: Text("Jane Appleseed"))
                SwiftForgeTextField("Email", text: $email, state: .error("Enter a valid email address.")) {
                    Image(systemName: "envelope")
                }
                .swiftForgeClearButton(.always)
                SwiftForgeTextField("Username", text: $username, state: .success("That username is available."))
                SwiftForgeTextField("Bio", text: $bio, state: .helper("Shown on your public profile."))
                    .swiftForgeCharacterLimit(80)
                    .swiftForgeOptionalField()
                SwiftForgeTextField("Disabled", text: .constant("Read only")).disabled(true)
                SwiftForgeTextField("Large", text: .constant(""), prompt: Text("52-pt field")).controlSize(.large)
            }
            .padding()
        }
    }
}

#Preview("States") { TextFieldPreview() }

#Preview("Dark, Neo-Brutal") {
    TextFieldPreview()
        .swiftForgeTheme(.neoBrutal)
        .preferredColorScheme(.dark)
}

#Preview("AX5, RTL") {
    TextFieldPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(spacing: 8) {
            SwiftForgeTextField("Name", text: .constant(""), prompt: Text("Jane Appleseed"))
            SwiftForgeTextField("Email", text: .constant("sam@"), state: .error("Enter a valid email address."))
            SwiftForgeSecureField("Password", text: .constant("hunter22"))
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(spacing: 8) {
            SwiftForgeTextField("Name", text: .constant(""), prompt: Text("Jane Appleseed"))
            SwiftForgeTextField("Email", text: .constant("sam@"), state: .error("Enter a valid email address."))
            SwiftForgeSecureField("Password", text: .constant("hunter22"))
        }
    }
}
