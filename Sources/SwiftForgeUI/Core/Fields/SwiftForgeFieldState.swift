//
//  SwiftForgeFieldState.swift
//  SwiftForgeUI
//

import SwiftUI

/// The validation state of a SwiftForgeUI form field.
///
/// SwiftForgeUI never validates input itself: your app decides the state
/// and supplies the message to show for it.
///
/// ```swift
/// SwiftForgeTextField("Email", text: $email, state: emailIsValid ? .normal : .error("Enter a valid email address."))
/// ```
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgeFieldState: Sendable, Equatable {

    /// No message.
    case normal

    /// Low-emphasis guidance, read by VoiceOver as the field's hint.
    case helper(LocalizedStringResource)

    /// A confirmation, drawn in the success tone with a checkmark.
    case success(LocalizedStringResource)

    /// An error, drawn in the danger tone with a thicker outline. VoiceOver
    /// reads it with the field and announces it when it appears or changes.
    case error(LocalizedStringResource)

    /// The message for this state, if any.
    public var message: LocalizedStringResource? {
        switch self {
        case .normal: nil
        case .helper(let message), .success(let message), .error(let message): message
        }
    }

    var tone: SwiftForgeTone? {
        switch self {
        case .normal, .helper: nil
        case .success: .success
        case .error: .danger
        }
    }

    var iconName: String {
        switch self {
        case .normal, .helper: "info.circle"
        case .success: "checkmark.circle.fill"
        case .error: "exclamationmark.circle.fill"
        }
    }
}

/// When a text field shows its clear button.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeClearButtonVisibility: Sendable, Hashable {
    /// Never.
    case never
    /// While the field is focused and not empty.
    case whileEditing
    /// Whenever the field isn't empty.
    case always
}

extension EnvironmentValues {
    @Entry var swiftForgeClearButton: SwiftForgeClearButtonVisibility = .never
    @Entry var swiftForgeCharacterLimit: Int? = nil
    @Entry var swiftForgeFieldIsOptional = false
    @Entry var swiftForgeRevealButtonIsVisible = true
}

extension View {

    /// Sets when SwiftForgeUI text fields beneath this view show a clear button.
    public func swiftForgeClearButton(_ visibility: SwiftForgeClearButtonVisibility) -> some View {
        environment(\.swiftForgeClearButton, visibility)
    }

    /// Limits SwiftForgeUI text fields beneath this view to a number of
    /// characters, and shows a counter. Pass `nil` to remove the limit.
    public func swiftForgeCharacterLimit(_ limit: Int?) -> some View {
        environment(\.swiftForgeCharacterLimit, limit)
    }

    /// Marks SwiftForgeUI text fields beneath this view as optional, adding
    /// an "Optional" note beside the label.
    public func swiftForgeOptionalField(_ isOptional: Bool = true) -> some View {
        environment(\.swiftForgeFieldIsOptional, isOptional)
    }

    /// Shows or hides the show/hide password button of
    /// ``SwiftForgeSecureField`` beneath this view. Visible by default.
    public func swiftForgeRevealButton(_ isVisible: Bool) -> some View {
        environment(\.swiftForgeRevealButtonIsVisible, isVisible)
    }
}
