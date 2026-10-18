//
//  SwiftForgeTextArea.swift
//  SwiftForgeUI
//

import SwiftUI

/// A labeled, multi-line text field that grows with its content.
///
/// ```swift
/// SwiftForgeTextArea("Message", text: $message, prompt: Text("Write a note…"), lineLimit: 3...8)
///     .swiftForgeCharacterLimit(500)
/// ```
///
/// The area reserves its minimum number of lines, grows line by line as
/// text is entered, and scrolls once it reaches the maximum. Return inserts
/// a new line. Labels, validation states, the character counter, and
/// accessibility match ``SwiftForgeTextField``.
///
/// - Do: use a text area for free-form text such as notes and messages.
/// - Don't: use one for single values such as names and emails; use a
///   ``SwiftForgeTextField``.
public struct SwiftForgeTextArea: View {

    private var label: Text
    @Binding private var text: String
    private let prompt: Text?
    private let state: SwiftForgeFieldState
    private let lineLimit: ClosedRange<Int>

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeCharacterLimit) private var characterLimit
    @FocusState private var isFocused: Bool

    /// Creates a text area.
    ///
    /// - Parameters:
    ///   - titleKey: The area's label, shown above it and read by VoiceOver.
    ///   - text: The text to edit.
    ///   - prompt: Placeholder text shown while the area is empty. Defaults to none: the
    ///     label above the area already names it.
    ///   - state: The validation state and its message. Defaults to ``SwiftForgeFieldState/normal``.
    ///   - lineLimit: The minimum and maximum number of visible lines.
    ///     Defaults to 3 through 8.
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        state: SwiftForgeFieldState = .normal,
        lineLimit: ClosedRange<Int> = 3...8
    ) {
        self.label = Text(titleKey)
        self._text = text
        self.prompt = prompt
        self.state = state
        self.lineLimit = lineLimit
    }

    /// Creates a text area with a label that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        prompt: Text? = nil,
        state: SwiftForgeFieldState = .normal,
        lineLimit: ClosedRange<Int> = 3...8
    ) {
        self.init("", text: text, prompt: prompt, state: state, lineLimit: lineLimit)
        self.label = Text(title)
    }

    /// The content and behavior of the view.
    public var body: some View {
        SwiftForgeFieldContainer(
            label: label,
            state: state,
            isFocused: isFocused,
            characterCount: text.count,
            field: field,
            leading: EmptyView(),
            trailing: EmptyView()
        )
    }

    /// Without a prompt, SwiftUI would repeat the label, already shown above
    /// the area, as the placeholder.
    private var placeholder: Text {
        (prompt ?? Text(verbatim: "")).foregroundStyle(theme.colors.textSecondary)
    }

    private var field: some View {
        TextField(text: $text, prompt: placeholder, axis: .vertical) { label }
            .lineLimit(lineLimit)
            .focused($isFocused)
            .font(theme.typography.font(theme.typography.body))
            .foregroundStyle(theme.colors.textPrimary)
            .onChange(of: text) { _, newValue in
                if let characterLimit, newValue.count > characterLimit {
                    text = String(newValue.prefix(characterLimit))
                }
            }
    }
}

// MARK: - Previews

private struct TextAreaPreview: View {
    @State private var note = "Leave the parcel with the neighbor at number 12 if nobody answers."
    @State private var empty = ""

    var body: some View {
        VStack(spacing: 16) {
            SwiftForgeTextArea("Delivery note", text: $note, state: .helper("Shown to the courier."))
                .swiftForgeCharacterLimit(200)
            SwiftForgeTextArea("Message", text: $empty, prompt: Text("Write a message…"), lineLimit: 2...4)
            SwiftForgeTextArea("Feedback", text: .constant(""), state: .error("Tell us what went wrong."))
        }
        .padding()
    }
}

#Preview("Text area") { TextAreaPreview() }

#Preview("Dark, AX5") {
    TextAreaPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeTextArea("Delivery note", text: .constant("Leave it at the door."), lineLimit: 2...4)
    }
}
