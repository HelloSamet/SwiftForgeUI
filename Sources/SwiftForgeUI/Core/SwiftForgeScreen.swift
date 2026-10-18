//
//  SwiftForgeScreen.swift
//  SwiftForgeUI
//

import SwiftUI

private struct SwiftForgeScreenModifier: ViewModifier {

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content
            .contentMargins(.horizontal, theme.spacing.screenHorizontal, for: .scrollContent)
            .background(theme.colors.canvas)
    }
}

extension View {

    /// Lays out a scrolling screen on the theme's canvas, with the theme's
    /// screen margins.
    ///
    /// ```swift
    /// ScrollView {
    ///     VStack(alignment: .leading, spacing: theme.spacing.section) {
    ///         SwiftForgeNavigationHeader("Inbox")
    ///         MessageList()
    ///     }
    /// }
    /// .swiftForgeScreen()
    /// ```
    ///
    /// The canvas fills the screen behind the safe area, and scroll views in
    /// this view inset their content by ``SwiftForgeSpacing/screenHorizontal``
    /// — their scroll indicators stay at the edge. For a `List` or `Form`,
    /// use ``SwiftUICore/View/swiftForgeListStyle()`` instead, which keeps the
    /// list's own margins.
    public func swiftForgeScreen() -> some View {
        modifier(SwiftForgeScreenModifier())
    }
}

// MARK: - Previews

#Preview("Screen") {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                SwiftForgeNavigationHeader("Inbox", subtitle: Text("12 unread"))
                ForEach(0..<8, id: \.self) { SwiftForgeListRow("Message \($0)") }
            }
        }
        .swiftForgeScreen()
    }
    .swiftForgeTheme(.midnight)
}
