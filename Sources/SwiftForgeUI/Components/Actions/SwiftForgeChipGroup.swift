//
//  SwiftForgeChipGroup.swift
//  SwiftForgeUI
//

import SwiftUI

/// A titled set of selectable chips that wraps onto as many rows as it needs.
///
/// Bind a set to let people choose any number of chips, such as filters:
///
/// ```swift
/// SwiftForgeChipGroup("Cuisine", selection: $cuisines, options: Cuisine.allCases) { cuisine in
///     Label(cuisine.name, systemImage: cuisine.symbol)
/// }
/// ```
///
/// Bind an optional value to let people choose at most one; tapping the
/// selected chip clears the choice:
///
/// ```swift
/// SwiftForgeChipGroup("Price", selection: $priceRange, options: PriceRange.allCases) { range in
///     Text(range.title)
/// }
/// ```
///
/// Chips flow in rows following the reading direction; the gap between them
/// follows ``SwiftForgeDensity``. VoiceOver reads the title as a heading and
/// each chip as a toggle with its state and position, such as "Thai,
/// selected, 2 of 6".
public struct SwiftForgeChipGroup<Value: Hashable, Label: View>: View {

    private var title: Text
    private let options: [Value]
    private let isSelected: (Value) -> Bool
    private let toggle: (Value) -> Void
    private let tone: SwiftForgeTone
    private let label: (Value) -> Label

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeDensity) private var density

    /// Creates a chip group that allows any number of selected chips.
    ///
    /// - Parameters:
    ///   - titleKey: The group's title, shown above the chips.
    ///   - selection: The selected options.
    ///   - options: The options, in display order.
    ///   - tone: The color of selected chips. Defaults to the accent.
    ///   - label: A label for each option, typically a `Label` or `Text`.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Set<Value>>,
        options: [Value],
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(
            title: Text(titleKey), options: options, isSelected: { selection.wrappedValue.contains($0) },
            toggle: { option in
                if selection.wrappedValue.contains(option) {
                    selection.wrappedValue.remove(option)
                } else {
                    selection.wrappedValue.insert(option)
                }
            },
            tone: tone, label: label)
    }

    /// Creates a chip group that allows at most one selected chip.
    ///
    /// - Parameters:
    ///   - titleKey: The group's title, shown above the chips.
    ///   - selection: The selected option, or `nil` for none.
    ///   - options: The options, in display order.
    ///   - tone: The color of the selected chip. Defaults to the accent.
    ///   - label: A label for each option, typically a `Label` or `Text`.
    public init(
        _ titleKey: LocalizedStringKey,
        selection: Binding<Value?>,
        options: [Value],
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(
            title: Text(titleKey), options: options, isSelected: { selection.wrappedValue == $0 },
            toggle: { option in selection.wrappedValue = selection.wrappedValue == option ? nil : option },
            tone: tone, label: label)
    }

    init(
        title: Text, options: [Value], isSelected: @escaping (Value) -> Bool, toggle: @escaping (Value) -> Void,
        tone: SwiftForgeTone, label: @escaping (Value) -> Label
    ) {
        self.title = title
        self.options = options
        self.isSelected = isSelected
        self.toggle = toggle
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
            // Chips keep a 44-pt hit area around a shorter outline, which
            // already separates the rows.
            SwiftForgeFlowLayout(horizontalSpacing: density.itemSpacing(in: theme.spacing), verticalSpacing: 0) {
                ForEach(Array(options.enumerated()), id: \.element) { index, option in
                    SwiftForgeChip(
                        isSelected: Binding(get: { isSelected(option) }, set: { _ in toggle(option) }),
                        tone: tone
                    ) {
                        label(option)
                    }
                    .accessibilityValue(SwiftForgeStrings.position(index + 1, of: options.count))
                }
            }
        }
        .accessibilityElement(children: .contain)
    }
}

extension SwiftForgeChipGroup {

    /// Creates a chip group with a title that isn't localized, allowing any
    /// number of selected chips.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Set<Value>>,
        options: [Value],
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(LocalizedStringKey(""), selection: selection, options: options, tone: tone, label: label)
        self.title = Text(title)
    }

    /// Creates a chip group with a title that isn't localized, allowing at
    /// most one selected chip.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Value?>,
        options: [Value],
        tone: SwiftForgeTone = .accent,
        @ViewBuilder label: @escaping (Value) -> Label
    ) {
        self.init(LocalizedStringKey(""), selection: selection, options: options, tone: tone, label: label)
        self.title = Text(title)
    }
}

// MARK: - Previews

private struct ChipPreview: View {
    @State private var cuisines: Set<String> = ["Thai", "Turkish"]
    @State private var price: String? = "$$"
    @State private var vegan = true
    @State private var recipients = ["Ada Lovelace", "Grace Hopper"]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SwiftForgeChipGroup(
                "Cuisine", selection: $cuisines, options: ["Italian", "Thai", "Turkish", "Mexican", "Japanese", "Indian"]
            ) { Text($0) }
            SwiftForgeChipGroup("Price", selection: $price, options: ["$", "$$", "$$$"]) { Text($0) }
            HStack {
                SwiftForgeChip("Vegan", systemImage: "leaf", isSelected: $vegan)
                SwiftForgeChip("Add to calendar", systemImage: "calendar.badge.plus", action: {})
            }
            HStack {
                ForEach(recipients, id: \.self) { name in
                    SwiftForgeChip(name, onRemove: { recipients.removeAll { $0 == name } })
                }
            }
            SwiftForgeChip("Disabled", isSelected: .constant(true)).disabled(true)
        }
        .padding()
    }
}

#Preview("Chips") { ChipPreview() }

#Preview("Dark, AX3, RTL") {
    ChipPreview()
        .environment(\.dynamicTypeSize, .accessibility3)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeChipGroup("Cuisine", selection: .constant(Set(["Thai"])), options: ["Italian", "Thai", "Turkish"]) {
            Text($0)
        }
    }
}
