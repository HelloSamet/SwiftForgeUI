//
//  SwiftForgeListRow.swift
//  SwiftForgeUI
//

import SwiftUI

/// A row with a title, an optional subtitle, and leading and trailing
/// content — for settings, contacts, files, and other lists.
///
/// ```swift
/// List {
///     SwiftForgeListRow("Notifications", subtitle: Text("Banners, sounds"), systemImage: "bell", accessory: .chevron)
///     SwiftForgeListRow("Version", value: Text("2.4.1"))
///     SwiftForgeListRow("Ada Lovelace", subtitle: Text("Online")) {
///         SwiftForgeAvatar(name: "Ada Lovelace")
///     } trailing: {
///         SwiftForgeBadge(count: 3)
///     }
/// }
/// ```
///
/// Rows work in a `List` and outside one. In a `List`, the separator starts
/// at the title, and SwiftUI's own `swipeActions`, `listRowSeparator(_:)`,
/// and `NavigationLink` behave as usual. Outside a `List`, make a row
/// tappable with a `Button` or `NavigationLink` styled
/// ``SwiftForgeRowButtonStyle`` (`.buttonStyle(.swiftForgeRow)`), and
/// separate rows with ``SwiftForgeDivider``.
///
/// The row is at least 44 pt tall; its vertical padding follows
/// ``SwiftForgeDensity``. At accessibility text sizes the trailing value
/// moves under the title instead of squeezing it.
///
/// VoiceOver reads the title, subtitle, and value as one element; controls
/// in the trailing slot, such as a toggle, stay separate. The leading slot
/// is decorative and hidden from VoiceOver — put anything a person needs to
/// hear in the title or subtitle.
public struct SwiftForgeListRow<Leading: View, Trailing: View>: View {

    /// A standard trailing indicator.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Accessory: Sendable, Hashable {
        /// Nothing.
        case none
        /// A forward chevron: the row opens something. Mirrors in right-to-left languages.
        case chevron
        /// A checkmark: the row is the selected choice. Adds the selected trait.
        case checkmark
    }

    private var title: Text
    private let subtitle: Text?
    private let value: Text?
    private let accessory: Accessory
    private let leading: Leading
    private let trailing: Trailing

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeDensity) private var density
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.isEnabled) private var isEnabled

    /// Creates a row with leading and trailing content.
    ///
    /// - Parameters:
    ///   - titleKey: The row's title.
    ///   - subtitle: Secondary text below the title.
    ///   - value: A value shown before the trailing content, such as a setting's current choice.
    ///   - accessory: A standard trailing indicator. Defaults to none.
    ///   - leading: Content before the title, such as a ``SwiftForgeIcon`` or ``SwiftForgeAvatar``.
    ///   - trailing: Content after the title, such as a badge or a toggle.
    public init(
        _ titleKey: LocalizedStringKey,
        subtitle: Text? = nil,
        value: Text? = nil,
        accessory: Accessory = .none,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = Text(titleKey)
        self.subtitle = subtitle
        self.value = value
        self.accessory = accessory
        self.leading = leading()
        self.trailing = trailing()
    }

    /// The content and behavior of the view.
    public var body: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            leading
                .foregroundStyle(theme.colors.accent.text)
                // Decorative content stops growing at the largest
                // non-accessibility size, leaving room for the title.
                .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
                .accessibilityHidden(true)
            texts
                .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
            trailing
            accessoryView
        }
        .padding(.vertical, density.rowPadding(in: theme.spacing))
        .frame(maxWidth: .infinity, minHeight: theme.sizes.minimumHitTarget, alignment: .leading)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .accessibilityAddTraits(accessory == .checkmark ? .isSelected : [])
    }

    /// The title and subtitle, with the value beside them — or below them at
    /// accessibility sizes. One VoiceOver element.
    private var texts: some View {
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: theme.spacing.xxxs))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: theme.spacing.xs))
        return layout {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                title
                    .font(theme.typography.font(theme.typography.body))
                    .foregroundStyle(theme.colors.textPrimary)
                if let subtitle {
                    subtitle
                        .font(theme.typography.font(theme.typography.subheadline))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: theme.spacing.xs)
            }
            if let value {
                value
                    .font(theme.typography.font(theme.typography.body))
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var accessoryView: some View {
        switch accessory {
        case .none:
            EmptyView()
        case .chevron:
            Image(systemName: "chevron.forward")
                .font(theme.typography.font(theme.typography.footnote).weight(.semibold))
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityHidden(true)
        case .checkmark:
            Image(systemName: "checkmark")
                .font(theme.typography.font(theme.typography.body).weight(.semibold))
                .foregroundStyle(theme.colors.accent.text)
                .accessibilityHidden(true)
        }
    }
}

extension SwiftForgeListRow where Leading == EmptyView, Trailing == EmptyView {

    /// Creates a row with a title, an optional subtitle and value, and a
    /// standard accessory.
    public init(
        _ titleKey: LocalizedStringKey,
        subtitle: Text? = nil,
        value: Text? = nil,
        accessory: Accessory = .none
    ) {
        self.init(
            titleKey, subtitle: subtitle, value: value, accessory: accessory, leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

extension SwiftForgeListRow where Leading == SwiftForgeIcon, Trailing == EmptyView {

    /// Creates a row with a leading SF Symbol in the accent color.
    ///
    /// - Parameters:
    ///   - titleKey: The row's title.
    ///   - subtitle: Secondary text below the title.
    ///   - systemImage: The symbol before the title.
    ///   - value: A value shown at the trailing edge.
    ///   - accessory: A standard trailing indicator.
    public init(
        _ titleKey: LocalizedStringKey,
        subtitle: Text? = nil,
        systemImage: String,
        value: Text? = nil,
        accessory: Accessory = .none
    ) {
        self.init(
            titleKey, subtitle: subtitle, value: value, accessory: accessory,
            leading: { SwiftForgeIcon(systemImage) }, trailing: { EmptyView() })
    }
}

extension SwiftForgeListRow {

    /// Creates a row with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        subtitle: Text? = nil,
        value: Text? = nil,
        accessory: Accessory = .none,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init("", subtitle: subtitle, value: value, accessory: accessory, leading: leading, trailing: trailing)
        self.title = Text(title)
    }
}

// MARK: - Row button style

/// A button style that makes a whole row tappable outside a `List`: the
/// row highlights while pressed and shows the focus ring.
///
/// ```swift
/// NavigationLink(value: Settings.notifications) {
///     SwiftForgeListRow("Notifications", systemImage: "bell", accessory: .chevron)
/// }
/// .buttonStyle(.swiftForgeRow)
/// ```
///
/// Inside a `List`, use SwiftUI's own row highlighting instead.
public struct SwiftForgeRowButtonStyle: ButtonStyle {

    /// Creates a row button style.
    public init() {}

    /// Creates a view that represents the body of a styled row.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeRowButton(configuration: configuration)
    }
}

extension ButtonStyle where Self == SwiftForgeRowButtonStyle {

    /// A style that makes a whole row tappable, with a pressed highlight.
    public static var swiftForgeRow: Self { SwiftForgeRowButtonStyle() }
}

private struct SwiftForgeRowButton: View {

    let configuration: ButtonStyleConfiguration

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        configuration.label
            .padding(.horizontal, theme.spacing.md)
            .background {
                if configuration.isPressed {
                    Rectangle().fill(theme.colors.pressedOverlay)
                }
            }
            .swiftForgeFocusRing(isFocused, cornerRadius: 0)
            .contentShape(Rectangle())
    }
}

// MARK: - Labeled content style

/// A `LabeledContent` style that lays out a label and its value as a
/// SwiftForgeUI row.
///
/// ```swift
/// Form {
///     LabeledContent("Version", value: "2.4.1")
///     LabeledContent("Storage") { Text("12.4 GB of 64 GB") }
/// }
/// .labeledContentStyle(.swiftForge)
/// ```
///
/// The value moves under the label at accessibility text sizes. VoiceOver
/// reads the label and value together, as for any `LabeledContent`.
public struct SwiftForgeLabeledContentStyle: LabeledContentStyle {

    /// Creates the labeled content style.
    public init() {}

    /// Creates a view that represents the body of labeled content.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeLabeledContentRow(configuration: configuration)
    }
}

extension LabeledContentStyle where Self == SwiftForgeLabeledContentStyle {

    /// The SwiftForgeUI row style for `LabeledContent`.
    public static var swiftForge: Self { SwiftForgeLabeledContentStyle() }
}

private struct SwiftForgeLabeledContentRow: View {

    let configuration: LabeledContentStyleConfiguration

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeDensity) private var density
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: theme.spacing.xxxs))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: theme.spacing.xs))
        layout {
            configuration.label
                .font(theme.typography.font(theme.typography.body))
                .foregroundStyle(theme.colors.textPrimary)
            if !dynamicTypeSize.isAccessibilitySize {
                Spacer(minLength: theme.spacing.xs)
            }
            configuration.content
                .font(theme.typography.font(theme.typography.body))
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(dynamicTypeSize.isAccessibilitySize ? .leading : .trailing)
        }
        .padding(.vertical, density.rowPadding(in: theme.spacing))
        .frame(maxWidth: .infinity, minHeight: theme.sizes.minimumHitTarget, alignment: .leading)
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] }
    }
}

// MARK: - Section header

/// A titled header for a group of rows or cards, with an optional action
/// such as "See All".
///
/// ```swift
/// SwiftForgeSectionHeader("Recent Orders") {
///     Button("See All") { showAllOrders() }
/// }
/// ```
///
/// The title is a VoiceOver heading, so the rotor can jump between
/// sections. In a `List` section header it keeps its own case and font
/// instead of the system's small capitals.
public struct SwiftForgeSectionHeader<Action: View>: View {

    private var title: Text
    private let action: Action

    @Environment(\.swiftForgeTheme) private var theme

    /// Creates a section header with a trailing action.
    ///
    /// - Parameters:
    ///   - titleKey: The section's title.
    ///   - action: A trailing button, styled as a small plain button.
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder action: () -> Action) {
        title = Text(titleKey)
        self.action = action()
    }

    /// The content and behavior of the view.
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            title
                .font(theme.typography.font(theme.typography.headline))
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
            action
                .buttonStyle(.swiftForge(.plain))
                .controlSize(.small)
        }
        .textCase(nil)
    }
}

extension SwiftForgeSectionHeader where Action == EmptyView {

    /// Creates a section header.
    public init(_ titleKey: LocalizedStringKey) {
        self.init(titleKey) { EmptyView() }
    }

    /// Creates a section header with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S) {
        self.init("") { EmptyView() }
        self.title = Text(title)
    }
}

// MARK: - Previews

private struct ListRowPreview: View {
    @State private var wifi = true

    var body: some View {
        List {
            Section {
                SwiftForgeListRow(
                    "Notifications", subtitle: Text("Banners, sounds, badges"), systemImage: "bell", accessory: .chevron)
                SwiftForgeListRow("Wi-Fi", systemImage: "wifi", value: Text("Home"), accessory: .chevron)
                SwiftForgeListRow("Dark Mode") {
                    SwiftForgeIcon("moon")
                } trailing: {
                    Toggle("Dark Mode", isOn: $wifi).labelsHidden().toggleStyle(.swiftForge)
                }
                SwiftForgeListRow("Ada Lovelace", subtitle: Text("Online")) {
                    SwiftForgeAvatar(name: "Ada Lovelace", status: .online)
                } trailing: {
                    SwiftForgeBadge(count: 3)
                }
                .swipeActions { Button("Delete", role: .destructive) {} }
            } header: {
                SwiftForgeSectionHeader("Settings") { Button("Edit") {} }
            }
            Section {
                LabeledContent("Version", value: "2.4.1")
                LabeledContent("Storage") { Text("12.4 GB of 64 GB") }
            }
            .labeledContentStyle(.swiftForge)
        }
    }
}

#Preview("In a list") { ListRowPreview() }

#Preview("AX5") {
    ListRowPreview().environment(\.dynamicTypeSize, .accessibility5)
}

#Preview("Outside a list") {
    VStack(spacing: 0) {
        Button {
        } label: {
            SwiftForgeListRow("Privacy", systemImage: "hand.raised", accessory: .chevron)
        }
        SwiftForgeDivider(inset: .leading(52))
        Button {
        } label: {
            SwiftForgeListRow("English", accessory: .checkmark)
        }
    }
    .buttonStyle(.swiftForgeRow)
    .swiftForgeSurface()
    .padding()
}
