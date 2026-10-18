//
//  SwiftForgeElevation.swift
//  SwiftForgeUI
//

import SwiftUI

/// A drop shadow token.
public struct SwiftForgeShadow: Sendable, Hashable {

    /// The shadow color. Adapts to appearance, so dark-mode shadows can be denser.
    public var color: SwiftForgeColor
    /// The blur radius.
    public var radius: CGFloat
    /// The horizontal offset.
    public var x: CGFloat
    /// The vertical offset.
    public var y: CGFloat

    /// Creates a shadow.
    public init(color: SwiftForgeColor, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }

    /// No shadow.
    public static let none = SwiftForgeShadow(color: .clear, radius: 0)
}

/// How far a surface sits above the canvas.
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgeElevationLevel: Sendable, Hashable, CaseIterable {
    /// Flush with the surface below; no shadow.
    case none
    /// Slightly lifted, such as buttons in themes with shadows.
    case low
    /// Elevated cards and menus.
    case medium
    /// Toasts and popovers.
    case high
}

/// The shadows a theme uses for each elevation level.
public struct SwiftForgeElevation: Sendable, Hashable {

    /// Slightly lifted surfaces.
    public var low: SwiftForgeShadow
    /// Elevated cards and menus.
    public var medium: SwiftForgeShadow
    /// Toasts and popovers.
    public var high: SwiftForgeShadow
    /// Whether raised surfaces also draw a hairline border, for themes that
    /// convey depth with lines rather than shadows.
    public var raisedSurfacesHaveBorder: Bool

    /// Creates an elevation set.
    public init(low: SwiftForgeShadow, medium: SwiftForgeShadow, high: SwiftForgeShadow, raisedSurfacesHaveBorder: Bool) {
        self.low = low
        self.medium = medium
        self.high = high
        self.raisedSurfacesHaveBorder = raisedSurfacesHaveBorder
    }

    /// The shadow for a level.
    public subscript(level: SwiftForgeElevationLevel) -> SwiftForgeShadow {
        switch level {
        case .none: .none
        case .low: low
        case .medium: medium
        case .high: high
        }
    }
}

private struct SwiftForgeShadowModifier: ViewModifier {

    let shadow: SwiftForgeShadow

    @Environment(\.colorScheme) private var colorScheme
    @SwiftForgeAccessibilityContext private var accessibility

    func body(content: Content) -> some View {
        let color = shadow.color.resolve(colorScheme: colorScheme, increasedContrast: accessibility.increasedContrast)
        content.shadow(color: Color(color), radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {

    /// Applies a shadow token, resolving its color for the current appearance.
    public func swiftForgeShadow(_ shadow: SwiftForgeShadow) -> some View {
        modifier(SwiftForgeShadowModifier(shadow: shadow))
    }
}
