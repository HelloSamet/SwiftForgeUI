//
//  SwiftForgeListStyle.swift
//  SwiftForgeUI
//

import SwiftUI

private struct SwiftForgeListStyleModifier: ViewModifier {

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(theme.colors.canvas)
    }
}

/// A list row's background: the theme's surface color.
private struct SwiftForgeListRowBackground: View {
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        Rectangle().fill(theme.colors.surface)
    }
}

extension View {

    /// Draws a `List` or `Form` on the theme's canvas instead of the system's
    /// grouped background.
    ///
    /// SwiftUI only lets rows set their own background, so also apply
    /// ``SwiftUICore/View/swiftForgeListRowBackground()`` to each section:
    ///
    /// ```swift
    /// List {
    ///     Section { SwiftForgeListRow("Wi-Fi", value: Text("Home")) }
    ///         .swiftForgeListRowBackground()
    /// }
    /// .swiftForgeListStyle()
    /// ```
    ///
    /// SwiftForgeUI's text colors are checked for contrast against the
    /// theme's canvas and surfaces, not the system's list colors, so style
    /// every list that shows SwiftForgeUI content in a theme other than
    /// ``SwiftForgeTheme/forge``.
    public func swiftForgeListStyle() -> some View {
        modifier(SwiftForgeListStyleModifier())
    }

    /// Sets the background of the list rows in this section or row to the
    /// theme's surface color. Use with ``SwiftUICore/View/swiftForgeListStyle()``.
    public func swiftForgeListRowBackground() -> some View {
        listRowBackground(SwiftForgeListRowBackground())
    }
}
