//
//  SwiftForgeSearchField.swift
//  SwiftForgeUI
//

import SwiftUI

/// A search field with a magnifying glass, a clear button, and an optional
/// Cancel button, that can report the query after typing pauses.
///
/// ```swift
/// SwiftForgeSearchField(text: $query) { query in
///     results = await catalog.search(query)
/// }
/// ```
///
/// The search action runs once typing pauses for `debounce` — 300 ms by
/// default — so a request isn't sent on every keystroke, and a newer query
/// cancels the pending one. Return runs it right away.
///
/// While the field is focused, a Cancel button clears the query and
/// dismisses the keyboard; turn it off with `showsCancelButton: false`.
///
/// For searching a whole screen inside a `NavigationStack`, prefer
/// SwiftUI's `searchable(text:)`: it places search where people expect it.
/// Use `SwiftForgeSearchField` inside content — above a list section, in a
/// sheet, or in a picker.
///
/// VoiceOver reads it as a search field labeled "Search" (or your title)
/// with its query as the value.
public struct SwiftForgeSearchField: View {

    private let label: Text
    @Binding private var text: String
    private let prompt: Text?
    private let showsCancelButton: Bool
    private let debounce: Duration
    private let onSearch: (@MainActor (String) async -> Void)?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @SwiftForgeAccessibilityContext private var accessibility
    @FocusState private var isFocused: Bool

    /// Creates a search field labeled "Search".
    ///
    /// - Parameters:
    ///   - text: The query.
    ///   - prompt: Placeholder text. Defaults to "Search".
    ///   - showsCancelButton: Whether a Cancel button appears while the field
    ///     is focused. Defaults to `true`.
    ///   - debounce: How long typing must pause before `onSearch` runs.
    ///   - onSearch: Runs a search for the query, or `nil` to only bind it.
    public init(
        text: Binding<String>,
        prompt: Text? = nil,
        showsCancelButton: Bool = true,
        debounce: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) async -> Void)? = nil
    ) {
        self.label = SwiftForgeStrings.search
        self._text = text
        self.prompt = prompt
        self.showsCancelButton = showsCancelButton
        self.debounce = debounce
        self.onSearch = onSearch
    }

    /// Creates a search field with a localized label, such as "Search contacts".
    public init(
        _ titleKey: LocalizedStringKey,
        text: Binding<String>,
        prompt: Text? = nil,
        showsCancelButton: Bool = true,
        debounce: Duration = .milliseconds(300),
        onSearch: (@MainActor (String) async -> Void)? = nil
    ) {
        self.label = Text(titleKey)
        self._text = text
        self.prompt = prompt
        self.showsCancelButton = showsCancelButton
        self.debounce = debounce
        self.onSearch = onSearch
    }

    /// The content and behavior of the view.
    public var body: some View {
        HStack(spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityHidden(true)
                TextField(text: $text, prompt: (prompt ?? SwiftForgeStrings.search).foregroundStyle(theme.colors.textSecondary)) {
                    label
                }
                .focused($isFocused)
                .font(theme.typography.font(theme.typography.body))
                .foregroundStyle(theme.colors.textPrimary)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .accessibilityLabel(label)
                .accessibilityAddTraits(.isSearchField)
                .onSubmit { search(text) }
                if !text.isEmpty {
                    SwiftForgeFieldAccessoryButton(systemImage: "xmark.circle.fill", label: SwiftForgeStrings.clearText) {
                        text = ""
                    }
                    .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .padding(.horizontal, theme.fieldContentInset)
            .frame(minHeight: theme.sizes.controlHeightRegular)
            .background(theme.components.field.background ?? theme.colors.fillMuted, in: shape)
            .overlay {
                shape.strokeBorder(
                    isFocused ? theme.colors.focusRing : .clear, lineWidth: isFocused ? theme.borders.thick : 0)
            }
            .fixedSize(horizontal: false, vertical: true)

            if showsCancelButton, isFocused {
                Button {
                    text = ""
                    isFocused = false
                } label: {
                    SwiftForgeStrings.cancel
                }
                .buttonStyle(.swiftForge(.plain))
                .transition(accessibility.reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion), value: isFocused)
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .task(id: text) {
            guard onSearch != nil else { return }
            do {
                try await Task.sleep(for: debounce)
            } catch {
                return
            }
            await onSearch?(text)
        }
    }

    private var shape: SwiftForgeShape {
        theme.radius.shape(theme.components.field.cornerRadius ?? theme.radius.control)
    }

    private func search(_ query: String) {
        guard let onSearch else { return }
        Task { await onSearch(query) }
    }
}

// MARK: - Previews

private struct SearchPreview: View {
    @State private var query = ""
    @State private var lastSearch = "—"

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SwiftForgeSearchField(text: $query) { lastSearch = $0 }
            Text(verbatim: "Searched: \(lastSearch)")
            SwiftForgeSearchField("Search contacts", text: .constant("Ada"), showsCancelButton: false)
            SwiftForgeSearchField(text: .constant(""), prompt: Text("Search recipes")).disabled(true)
        }
        .padding()
    }
}

#Preview("Search field") { SearchPreview() }

#Preview("Dark, AX5, RTL") {
    SearchPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeSearchField(text: .constant("Ada"))
    }
}
