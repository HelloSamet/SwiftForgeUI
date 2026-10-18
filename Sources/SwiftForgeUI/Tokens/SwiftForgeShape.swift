//
//  SwiftForgeShape.swift
//  SwiftForgeUI
//

import SwiftUI

/// How a theme draws rounded corners.
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgeCornerStyle: Sendable, Hashable {
    /// Apple's continuous ("squircle") corners.
    case continuous
    /// Circular arcs, as on the web and in most design tools.
    case circular

    var rounded: RoundedCornerStyle {
        switch self {
        case .continuous: .continuous
        case .circular: .circular
        }
    }
}

/// The shape SwiftForgeUI components draw a themed corner radius with.
///
/// A radius of ``SwiftForgeRadius/capsule`` draws a capsule, and a radius of
/// zero draws sharp corners, so a theme changes every component's silhouette
/// by changing its ``SwiftForgeRadius`` tokens. Use it in your own components
/// to follow the theme the same way:
///
/// ```swift
/// content
///     .background(theme.colors.surface, in: theme.radius.shape(theme.radius.card))
/// ```
///
/// Radii larger than half the shape's shorter side are clamped, so changes
/// between a rounded rectangle and a capsule animate smoothly.
public struct SwiftForgeShape: InsettableShape {

    /// A finite stand-in for an infinite radius while animating.
    private static let capsuleRadius: CGFloat = 10_000

    /// The corner radius before insetting.
    public var cornerRadius: CGFloat
    /// The corner style.
    public var style: SwiftForgeCornerStyle
    private var inset: CGFloat = 0

    /// Creates a shape.
    ///
    /// - Parameters:
    ///   - cornerRadius: The radius, or ``SwiftForgeRadius/capsule``.
    ///   - style: The corner style. Defaults to continuous.
    public init(cornerRadius: CGFloat, style: SwiftForgeCornerStyle = .continuous) {
        self.cornerRadius = cornerRadius
        self.style = style
    }

    /// The radius and inset, for animation.
    public var animatableData: AnimatablePair<CGFloat, CGFloat> {
        get { AnimatablePair(cornerRadius.isFinite ? cornerRadius : Self.capsuleRadius, inset) }
        set {
            cornerRadius = newValue.first
            inset = newValue.second
        }
    }

    /// The shape is symmetric, so — like `RoundedRectangle` — it isn't
    /// mirrored in right-to-left layouts, which would shift its strokes by a
    /// fraction of a pixel.
    public var layoutDirectionBehavior: LayoutDirectionBehavior { .fixed }

    /// Describes this shape as a path within a rectangular frame of reference.
    public func path(in rect: CGRect) -> Path {
        let insetRect = rect.insetBy(dx: inset, dy: inset)
        let maximum = min(insetRect.width, insetRect.height) / 2
        let radius = min(max(0, cornerRadius - inset), maximum)
        return RoundedRectangle(cornerRadius: radius, style: style.rounded).path(in: insetRect)
    }

    /// Returns this shape inset by `amount`, with its radius reduced so the
    /// corners stay concentric.
    public func inset(by amount: CGFloat) -> SwiftForgeShape {
        var copy = self
        copy.inset += amount
        return copy
    }
}

extension SwiftForgeRadius {

    /// A radius that turns a shape into a capsule, whatever its size.
    public static let capsule = CGFloat.infinity

    /// The theme's shape for a radius from this scale.
    public func shape(_ cornerRadius: CGFloat) -> SwiftForgeShape {
        SwiftForgeShape(cornerRadius: cornerRadius, style: cornerStyle)
    }
}
