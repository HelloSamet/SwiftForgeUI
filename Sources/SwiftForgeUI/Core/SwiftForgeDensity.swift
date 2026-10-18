//
//  SwiftForgeDensity.swift
//  SwiftForgeUI
//

import SwiftUI

/// How tightly SwiftForgeUI components pack their content.
///
/// Density changes the space *inside and between* components — a list row's
/// vertical padding, the gap between chips — never text size or hit areas,
/// which always follow Dynamic Type and stay at least 44 × 44 pt.
///
/// ```swift
/// List(messages) { message in
///     SwiftForgeListRow(message.subject, subtitle: message.preview)
/// }
/// .swiftForgeDensity(.compact)
/// ```
///
/// - ``compact``: data-heavy screens such as inboxes and tables.
/// - ``regular``: the default.
/// - ``spacious``: onboarding and content with few items.
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgeDensity: String, Sendable, Hashable, CaseIterable {

    /// Less space, for data-heavy screens.
    case compact

    /// The default spacing.
    case regular

    /// More space, for screens with few items.
    case spacious

    /// The vertical padding inside a row-like component, such as a list row
    /// or a menu item: one step of `spacing` per density.
    public func rowPadding(in spacing: SwiftForgeSpacing) -> CGFloat {
        switch self {
        case .compact: spacing.xs
        case .regular: spacing.sm
        case .spacious: spacing.md
        }
    }

    /// The gap between sibling items in a group, such as chips or radio
    /// buttons.
    public func itemSpacing(in spacing: SwiftForgeSpacing) -> CGFloat {
        switch self {
        case .compact: spacing.xxs
        case .regular: spacing.xs
        case .spacious: spacing.sm
        }
    }
}

extension EnvironmentValues {

    /// The density of SwiftForgeUI components. Defaults to ``SwiftForgeDensity/regular``.
    @Entry public var swiftForgeDensity: SwiftForgeDensity = .regular
}

extension View {

    /// Sets how tightly SwiftForgeUI components beneath this view pack their content.
    ///
    /// Density never changes text size or shrinks a hit area below 44 × 44 pt.
    public func swiftForgeDensity(_ density: SwiftForgeDensity) -> some View {
        environment(\.swiftForgeDensity, density)
    }
}
