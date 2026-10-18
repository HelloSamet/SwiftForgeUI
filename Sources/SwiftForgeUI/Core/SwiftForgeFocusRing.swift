//
//  SwiftForgeFocusRing.swift
//  SwiftForgeUI
//

import SwiftUI

private struct SwiftForgeFocusRingModifier: ViewModifier {

    let isVisible: Bool
    let cornerRadius: CGFloat

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content.overlay {
            if isVisible {
                let offset = theme.borders.focusRingOffset
                theme.radius.shape(cornerRadius + offset)
                    .strokeBorder(theme.colors.focusRing, lineWidth: theme.borders.thick)
                    .padding(-(offset + theme.borders.thick))
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
        }
    }
}

extension View {

    /// Draws the theme's keyboard focus ring around this view.
    ///
    /// SwiftForgeUI controls draw this ring when they have keyboard focus —
    /// with a hardware keyboard, Full Keyboard Access, or on visionOS — so
    /// people can always see where focus is. Use it in your own styles to
    /// match them:
    ///
    /// ```swift
    /// struct PillButtonStyle: ButtonStyle {
    ///     func makeBody(configuration: Configuration) -> some View {
    ///         PillButton(configuration: configuration)
    ///     }
    /// }
    ///
    /// struct PillButton: View {
    ///     let configuration: ButtonStyleConfiguration
    ///     @Environment(\.isFocused) private var isFocused
    ///     @Environment(\.swiftForgeTheme) private var theme
    ///
    ///     var body: some View {
    ///         configuration.label
    ///             .padding(theme.spacing.sm)
    ///             .background(theme.colors.accent.subtle, in: .capsule)
    ///             .swiftForgeFocusRing(isFocused, cornerRadius: SwiftForgeRadius.capsule)
    ///     }
    /// }
    /// ```
    ///
    /// The ring sits ``SwiftForgeBorders/focusRingOffset`` outside the view,
    /// drawn ``SwiftForgeBorders/thick`` in ``SwiftForgeColors/focusRing``,
    /// which contrasts 3:1 with every surface. Its corners stay concentric
    /// with the view's.
    ///
    /// - Parameters:
    ///   - isVisible: Whether to draw the ring, typically the `isFocused`
    ///     environment value.
    ///   - cornerRadius: The corner radius of the view the ring surrounds.
    public func swiftForgeFocusRing(_ isVisible: Bool, cornerRadius: CGFloat) -> some View {
        modifier(SwiftForgeFocusRingModifier(isVisible: isVisible, cornerRadius: cornerRadius))
    }
}
