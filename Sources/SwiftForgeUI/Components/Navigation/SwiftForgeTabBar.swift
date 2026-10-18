//
//  SwiftForgeTabBar.swift
//  SwiftForgeUI
//

import SwiftUI

/// An item in a ``SwiftForgeTabBar``.
public struct SwiftForgeTabItem<Value: Hashable & Sendable>: Identifiable, Sendable {

    /// The value the tab bar's selection takes when this item is chosen.
    public let value: Value
    let title: SwiftForgeText
    let systemImage: String
    let selectedSystemImage: String?
    /// A count shown on the item, or `nil` for none.
    public var badge: Int?

    /// The item's identity: its value.
    public var id: Value { value }

    /// Creates a tab item.
    ///
    /// - Parameters:
    ///   - title: The item's title, shown under its symbol.
    ///   - systemImage: The item's SF Symbol.
    ///   - selectedSystemImage: The symbol while selected. Defaults to the
    ///     `.fill` variant of `systemImage`, if it has one.
    ///   - value: The selection value for this item.
    ///   - badge: A count to show on the item.
    public init(
        _ title: LocalizedStringResource, systemImage: String, selectedSystemImage: String? = nil, value: Value,
        badge: Int? = nil
    ) {
        self.title = SwiftForgeText(title)
        self.systemImage = systemImage
        self.selectedSystemImage = selectedSystemImage
        self.value = value
        self.badge = badge
    }

    /// The symbol to show: the selected variant when selected.
    func symbol(isSelected: Bool) -> String {
        guard isSelected else { return systemImage }
        if let selectedSystemImage { return selectedSystemImage }
        let filled = systemImage + ".fill"
        #if canImport(UIKit)
        return UIImage(systemName: filled) == nil ? systemImage : filled
        #else
        return systemImage
        #endif
    }
}

/// A bottom tab bar in the theme's style, for apps that draw their own
/// navigation chrome.
///
/// ```swift
/// @State private var tab = Tab.home
///
/// var body: some View {
///     content(for: tab)
///         .safeAreaInset(edge: .bottom, spacing: 0) {
///             SwiftForgeTabBar(selection: $tab, items: [
///                 SwiftForgeTabItem("Home", systemImage: "house", value: .home),
///                 SwiftForgeTabItem("Inbox", systemImage: "tray", value: .inbox, badge: unread),
///                 SwiftForgeTabItem("Profile", systemImage: "person", value: .profile),
///             ])
///         }
/// }
/// ```
///
/// Items share the width; the selected one shows its filled symbol and the
/// accent color, so selection doesn't rely on color alone. The bar extends
/// into the bottom safe area.
///
/// Like the system tab bar, item titles stop growing at the largest
/// standard text size; at accessibility sizes, touching and holding an
/// item shows it in the Large Content Viewer. VoiceOver reads each item
/// with its badge, state, and position — "Inbox, 3 new items, selected,
/// button, 2 of 3" — and the arrow keys aren't needed: Tab and Full
/// Keyboard Access move between items.
///
/// - Do: use three to five items for the app's top-level sections.
/// - Don't: replace `TabView` on iPad, where it adapts to a sidebar; use the
///   system's tab view there and theme it with `tint`.
///
/// The bar's appearance comes from the ``SwiftForgeTabBarStyle`` in the
/// environment.
public struct SwiftForgeTabBar<Value: Hashable & Sendable>: View {

    @Binding private var selection: Value
    private let items: [SwiftForgeTabItem<Value>]

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeTabBarStyle) private var style

    /// Creates a tab bar.
    ///
    /// - Parameters:
    ///   - selection: The selected item's value.
    ///   - items: The items, in display order.
    public init(selection: Binding<Value>, items: [SwiftForgeTabItem<Value>]) {
        _selection = selection
        self.items = items
    }

    /// The content and behavior of the view.
    public var body: some View {
        let parts = style.resolved()
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let isSelected = item.value == selection
                Button {
                    selection = item.value
                } label: {
                    Label {
                        item.title.text
                    } icon: {
                        Image(systemName: item.symbol(isSelected: isSelected))
                    }
                }
                .buttonStyle(
                    SwiftForgeTabItemButtonStyle(
                        isSelected: isSelected, badge: item.badge, makeItem: parts.item,
                        height: theme.components.tabBar.height)
                )
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityValue(accessibilityValue(item: item, index: index))
                .accessibilityShowsLargeContentViewer {
                    Image(systemName: item.symbol(isSelected: isSelected))
                    item.title.text
                }
            }
        }
        .dynamicTypeSize(...DynamicTypeSize.xxLarge)
        .background(alignment: .top) {
            parts.background.ignoresSafeArea(edges: .bottom)
        }
        .swiftForgeHaptic(trigger: selection) { _, _ in .selection }
        .accessibilityElement(children: .contain)
    }

    private func accessibilityValue(item: SwiftForgeTabItem<Value>, index: Int) -> Text {
        let position = SwiftForgeStrings.position(index + 1, of: items.count)
        guard let badge = item.badge, badge > 0 else { return position }
        return SwiftForgeStrings.badgeCount(badge) + Text(verbatim: ", ") + position
    }
}

/// A tab item's button: the style's item view, filling its share of the
/// bar, with the focus ring.
private struct SwiftForgeTabItemButtonStyle: ButtonStyle {

    let isSelected: Bool
    let badge: Int?
    let makeItem: (SwiftForgeTabItemConfiguration) -> AnyView  // swiftforge-lint: allow (ADR-0015)
    let height: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        // The icon-only style keeps the title as the icon's label; hide it so
        // the item is read once.
        let icon = configuration.label.labelStyle(.iconOnly).accessibilityHidden(true)
        let title = configuration.label.labelStyle(.titleOnly)
        return SwiftForgeTabItemButton(
            item: makeItem(
                SwiftForgeTabItemConfiguration(
                    icon: .init(content: AnyView(icon)),  // swiftforge-lint: allow (ADR-0015)
                    title: .init(content: AnyView(title)),  // swiftforge-lint: allow (ADR-0015)
                    isSelected: isSelected,
                    isPressed: configuration.isPressed,
                    badge: badge)),
            height: height)
    }
}

private struct SwiftForgeTabItemButton: View {

    let item: AnyView  // swiftforge-lint: allow (ADR-0015)
    let height: CGFloat

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isFocused) private var isFocused

    var body: some View {
        item
            .frame(maxWidth: .infinity, minHeight: max(height, theme.sizes.minimumHitTarget))
            .contentShape(Rectangle())
            .swiftForgeFocusRing(isFocused, cornerRadius: theme.radius.control)
    }
}

// MARK: - Style

/// A type that draws a ``SwiftForgeTabBar``: its background and each item.
///
/// The tab bar keeps layout, selection, badges' accessibility, and the
/// Large Content Viewer; a style decides how the background and items look:
///
/// ```swift
/// struct PillTabBarStyle: SwiftForgeTabBarStyle {
///     @Environment(\.swiftForgeTheme) private var theme
///
///     func makeBackground() -> some View {
///         theme.colors.surfaceRaised
///     }
///
///     func makeItem(configuration: ItemConfiguration) -> some View {
///         VStack(spacing: theme.spacing.xxxs) {
///             configuration.icon
///             configuration.title.font(theme.typography.font(theme.typography.caption1))
///         }
///         .padding(.vertical, theme.spacing.xxs)
///         .padding(.horizontal, theme.spacing.sm)
///         .background(configuration.isSelected ? theme.colors.accent.subtle : .clear, in: .capsule)
///         .foregroundStyle(configuration.isSelected ? theme.colors.accent.text : theme.colors.textSecondary)
///     }
/// }
/// ```
@MainActor
@preconcurrency
public protocol SwiftForgeTabBarStyle: DynamicProperty {

    /// The bar's background.
    associatedtype Background: View
    /// An item.
    associatedtype Item: View

    /// The properties of an item.
    typealias ItemConfiguration = SwiftForgeTabItemConfiguration

    /// Creates the bar's background. It extends into the bottom safe area.
    @ViewBuilder func makeBackground() -> Background

    /// Creates an item.
    @ViewBuilder func makeItem(configuration: ItemConfiguration) -> Item
}

/// The properties of a tab bar item, passed to a ``SwiftForgeTabBarStyle``.
public struct SwiftForgeTabItemConfiguration {

    /// A type-erased part of an item.
    public struct Part: View {
        let content: AnyView  // swiftforge-lint: allow (ADR-0015)
        /// The content and behavior of the view.
        public var body: some View { content }
    }

    /// The item's symbol — the filled variant when selected.
    public let icon: Part
    /// The item's title.
    public let title: Part
    /// Whether the item is selected.
    public let isSelected: Bool
    /// Whether the item is being pressed.
    public let isPressed: Bool
    /// The item's count, or `nil` for none. Read by VoiceOver whatever the style draws.
    public let badge: Int?
}

struct SwiftForgeResolvedTabBarStyle {
    let background: AnyView  // swiftforge-lint: allow (ADR-0015)
    let item: (SwiftForgeTabItemConfiguration) -> AnyView  // swiftforge-lint: allow (ADR-0015)
}

extension SwiftForgeTabBarStyle {

    func resolved() -> SwiftForgeResolvedTabBarStyle {
        SwiftForgeResolvedTabBarStyle(
            background: AnyView(SwiftForgeStyleHost(style: self) { $0.makeBackground() }),  // swiftforge-lint: allow (ADR-0015)
            item: { configuration in
                let host = SwiftForgeStyleHost(style: self) { $0.makeItem(configuration: configuration) }
                return AnyView(host)  // swiftforge-lint: allow (ADR-0015)
            }
        )
    }
}

/// The default tab bar style: the overlay surface's fill with a hairline on
/// top; items in the accent color when selected.
public struct SwiftForgeAutomaticTabBarStyle: SwiftForgeTabBarStyle {

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.displayScale) private var displayScale

    /// Creates the default tab bar style.
    nonisolated public init() {}

    /// Creates the bar's background.
    public func makeBackground() -> some View {
        Rectangle()
            .fill(fill)
            .overlay(alignment: .top) {
                let hairline = 1 / displayScale  // swiftforge-lint: allow (one physical pixel)
                Rectangle()
                    .fill(theme.components.surface.borderColor ?? theme.colors.borderSubtle)
                    .frame(height: theme.components.surface.borderWidth ?? hairline)
            }
    }

    /// Creates an item: its symbol above its title, with a count badge.
    public func makeItem(configuration: ItemConfiguration) -> some View {
        VStack(spacing: theme.spacing.xxxs) {
            configuration.icon
                .font(.system(size: theme.components.tabBar.iconSize))
                // Symbols differ in height; a fixed box keeps every title on one line.
                .frame(height: theme.components.tabBar.iconSize)
                .overlay(alignment: .topTrailing) {
                    if let badge = configuration.badge, badge > 0 {
                        SwiftForgeBadge(count: badge)
                            .controlSize(.small)
                            .accessibilityHidden(true)
                            .alignmentGuide(.top) { $0.height / 2 }
                            .alignmentGuide(.trailing) { $0.width / 2 }
                    }
                }
            configuration.title
                .font(theme.typography.font(theme.typography.caption1.weight(configuration.isSelected ? .semibold : .medium)))
                .lineLimit(1)
        }
        .foregroundStyle(configuration.isSelected ? theme.colors.accent.text : theme.colors.textSecondary)
        .opacity(configuration.isPressed ? theme.opacity.pressedContent : 1)
        .padding(.vertical, theme.spacing.xxs)
    }

    /// The overlay surface's fill: a material where the theme sets one,
    /// which turns opaque with Reduce Transparency on.
    private var fill: SwiftForgeFill {
        theme.components.surface.fills[.overlay] ?? .color(theme.colors.surfaceRaised)
    }
}

extension SwiftForgeTabBarStyle where Self == SwiftForgeAutomaticTabBarStyle {

    /// The default tab bar style, drawn from the theme's tokens.
    public static var automatic: Self { SwiftForgeAutomaticTabBarStyle() }
}

private struct SwiftForgeTabBarStyleKey: EnvironmentKey {
    // Computed: styles aren't `Sendable`, like SwiftUI's own styles.
    static var defaultValue: any SwiftForgeTabBarStyle { SwiftForgeAutomaticTabBarStyle() }
}

extension EnvironmentValues {
    var swiftForgeTabBarStyle: any SwiftForgeTabBarStyle {
        get { self[SwiftForgeTabBarStyleKey.self] }
        set { self[SwiftForgeTabBarStyleKey.self] = newValue }
    }
}

extension View {

    /// Sets the style of SwiftForgeUI tab bars beneath this view.
    public func swiftForgeTabBarStyle<S: SwiftForgeTabBarStyle>(_ style: S) -> some View {
        environment(\.swiftForgeTabBarStyle, style)
    }
}

// MARK: - Previews

private enum PreviewTab: Hashable, Sendable { case home, inbox, search, profile }

private struct TabBarPreview: View {
    @State private var tab = PreviewTab.inbox

    var body: some View {
        Color.clear
            .safeAreaInset(edge: .bottom, spacing: 0) {
                SwiftForgeTabBar(
                    selection: $tab,
                    items: [
                        SwiftForgeTabItem("Home", systemImage: "house", value: .home),
                        SwiftForgeTabItem("Inbox", systemImage: "tray", value: .inbox, badge: 3),
                        SwiftForgeTabItem("Search", systemImage: "magnifyingglass", value: .search),
                        SwiftForgeTabItem("Profile", systemImage: "person", value: .profile),
                    ])
            }
    }
}

#Preview("Tab bar") { TabBarPreview() }

#Preview("Aurora, dark") {
    TabBarPreview().swiftForgeTheme(.aurora).preferredColorScheme(.dark)
}
