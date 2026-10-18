//
//  SwiftForgePicker.swift
//  SwiftForgeUI
//

import SwiftUI

/// A labeled field that opens a menu of options — or a searchable list —
/// to choose one.
///
/// ```swift
/// SwiftForgePicker("Country", selection: $country, options: countries) { country in
///     Text(country.name)
/// }
/// ```
///
/// Bind an optional value to start with nothing chosen; the field shows
/// `prompt` until a choice is made:
///
/// ```swift
/// SwiftForgePicker(
///     "Size", selection: $size, options: sizes, prompt: Text("Choose a size"),
///     state: showsErrors && size == nil ? .error("Choose a size.") : .normal
/// ) { Text($0.title) }
/// ```
///
/// For long lists, pass `searchText` to open a searchable list in a sheet
/// instead of a menu; it returns the text each option is found by:
///
/// ```swift
/// SwiftForgePicker("Time zone", selection: $zone, options: zones, searchText: \.identifier) {
///     Text($0.identifier)
/// }
/// ```
///
/// Labels, validation states, and accessibility match ``SwiftForgeTextField``:
/// VoiceOver reads the title, the chosen option as the value, and that the
/// field opens a menu or a list. Menus show the system's checkmark beside
/// the chosen option.
///
/// - Do: use a picker for five or more options, or where space is short.
/// - Don't: hide two or three options in a menu; show them with a
///   ``SwiftForgeRadioGroup`` or ``SwiftForgeSegmentedControl``.
public struct SwiftForgePicker<Value: Hashable>: View {

    private let title: Text
    private let selection: Binding<Value?>
    private let options: [Value]
    private let prompt: Text?
    private let state: SwiftForgeFieldState
    private let searchText: ((Value) -> String)?
    private let label: (Value) -> Text

    @Environment(\.swiftForgeTheme) private var theme
    @State private var isShowingList = false

    /// Creates a picker with a selection that's always set.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver.
    ///   - selection: The chosen option.
    ///   - options: The options, in display order.
    ///   - state: The validation state and its message.
    ///   - searchText: The text each option is found by; pass it to choose
    ///     from a searchable list instead of a menu.
    ///   - label: Each option's title.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value>,
        options: [Value],
        state: SwiftForgeFieldState = .normal,
        searchText: ((Value) -> String)? = nil,
        label: @escaping (Value) -> Text
    ) {
        self.title = Text(titleKey)
        self.selection = Binding(get: { selection.wrappedValue }, set: { if let value = $0 { selection.wrappedValue = value } })
        self.options = options
        self.prompt = nil
        self.state = state
        self.searchText = searchText
        self.label = label
    }

    /// Creates a picker that starts with no option chosen.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver.
    ///   - selection: The chosen option, or `nil` for none.
    ///   - options: The options, in display order.
    ///   - prompt: Shown while nothing is chosen. Defaults to "Select".
    ///   - state: The validation state and its message.
    ///   - searchText: The text each option is found by; pass it to choose
    ///     from a searchable list instead of a menu.
    ///   - label: Each option's title.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value?>,
        options: [Value],
        prompt: Text? = nil,
        state: SwiftForgeFieldState = .normal,
        searchText: ((Value) -> String)? = nil,
        label: @escaping (Value) -> Text
    ) {
        self.title = Text(titleKey)
        self.selection = selection
        self.options = options
        self.prompt = prompt
        self.state = state
        self.searchText = searchText
        self.label = label
    }

    /// The content and behavior of the view.
    public var body: some View {
        container
            .sheet(isPresented: $isShowingList) {
                if let searchText {
                    SwiftForgePickerList(
                        title: title, selection: selection, options: options, searchText: searchText, label: label)
                }
            }
    }

    private var container: some View {
        var container = SwiftForgeFieldContainer(
            label: title,
            state: state,
            isFocused: isShowingList,
            characterCount: nil,
            field: field,
            leading: EmptyView(),
            trailing: Image(systemName: searchText == nil ? "chevron.up.chevron.down" : "chevron.forward")
                .font(theme.typography.font(theme.typography.footnote).weight(.semibold))
                .accessibilityHidden(true)
        )
        container.accessibilityValue = selectedText
        return container
    }

    @ViewBuilder
    private var field: some View {
        if searchText == nil {
            Menu {
                Picker(selection: selection) {
                    ForEach(options, id: \.self) { option in
                        label(option).tag(Optional(option))
                    }
                } label: {
                    title
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } label: {
                currentValue
            }
        } else {
            Button {
                isShowingList = true
            } label: {
                currentValue
            }
            .buttonStyle(.plain)
        }
    }

    /// The chosen option, or the prompt, filling the field.
    private var currentValue: some View {
        Group {
            if let selectedText {
                selectedText.foregroundStyle(theme.colors.textPrimary)
            } else {
                (prompt ?? SwiftForgeStrings.pickerPrompt).foregroundStyle(theme.colors.textSecondary)
            }
        }
        .font(theme.typography.font(theme.typography.body))
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, minHeight: theme.sizes.minimumHitTarget - 2 * theme.spacing.xs, alignment: .leading)
        .contentShape(Rectangle())
    }

    private var selectedText: Text? {
        selection.wrappedValue.map(label)
    }
}

extension SwiftForgePicker {

    /// Creates a picker with a title that isn't localized and a selection
    /// that's always set.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value>,
        options: [Value],
        state: SwiftForgeFieldState = .normal,
        searchText: ((Value) -> String)? = nil,
        label: @escaping (Value) -> Text
    ) {
        self.title = Text(title)
        self.selection = Binding(get: { selection.wrappedValue }, set: { if let value = $0 { selection.wrappedValue = value } })
        self.options = options
        self.prompt = nil
        self.state = state
        self.searchText = searchText
        self.label = label
    }
}

/// The searchable list a picker opens in a sheet.
private struct SwiftForgePickerList<Value: Hashable>: View {

    let title: Text
    let selection: Binding<Value?>
    let options: [Value]
    let searchText: (Value) -> String
    let label: (Value) -> Text

    @Environment(\.dismiss) private var dismiss
    @Environment(\.swiftForgeTheme) private var theme
    @State private var query = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered, id: \.self) { option in
                    Button {
                        selection.wrappedValue = option
                        dismiss()
                    } label: {
                        HStack {
                            label(option).foregroundStyle(theme.colors.textPrimary)
                            Spacer()
                            if selection.wrappedValue == option {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(theme.colors.accent.text)
                                    .accessibilityHidden(true)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .accessibilityAddTraits(selection.wrappedValue == option ? .isSelected : [])
                }
            }
            .overlay {
                if filtered.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        SwiftForgeStrings.cancel
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .tint(theme.colors.accent.text)
    }

    private var filtered: [Value] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return options }
        return options.filter { searchText($0).localizedStandardContains(trimmed) }
    }
}

// MARK: - Previews

private struct PickerPreview: View {
    @State private var country = "Türkiye"
    @State private var size: String?
    @State private var zone: String?

    var body: some View {
        VStack(spacing: 16) {
            SwiftForgePicker("Country", selection: $country, options: ["Germany", "Japan", "Türkiye"]) { Text($0) }
            SwiftForgePicker(
                "Size", selection: $size, options: ["S", "M", "L"], prompt: Text("Choose a size"),
                state: .error("Choose a size.")
            ) { Text($0) }
            SwiftForgePicker(
                "Time zone", selection: $zone, options: TimeZone.knownTimeZoneIdentifiers, searchText: { $0 }
            ) { Text($0) }
            SwiftForgePicker("Disabled", selection: .constant("On"), options: ["On", "Off"]) { Text($0) }.disabled(true)
        }
        .padding()
    }
}

#Preview("Picker") { PickerPreview() }

#Preview("Dark, AX5") {
    PickerPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgePicker("Country", selection: .constant("Japan"), options: ["Germany", "Japan"]) { Text($0) }
    }
}
