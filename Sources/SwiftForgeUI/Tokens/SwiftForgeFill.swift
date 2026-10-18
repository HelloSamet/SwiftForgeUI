//
//  SwiftForgeFill.swift
//  SwiftForgeUI
//

import SwiftUI

/// A system material a ``SwiftForgeFill`` can blur content with.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeMaterial: Sendable, Hashable, CaseIterable {
    /// The most translucent material.
    case ultraThin
    /// A translucent material.
    case thin
    /// A material with average translucency.
    case regular
    /// A mostly opaque material.
    case thick
    /// The most opaque material.
    case ultraThick

    var material: Material {
        switch self {
        case .ultraThin: .ultraThinMaterial
        case .thin: .thinMaterial
        case .regular: .regularMaterial
        case .thick: .thickMaterial
        case .ultraThick: .ultraThickMaterial
        }
    }
}

/// How a theme paints an area: a color, a gradient, or a translucent material.
///
/// Fills let a theme give surfaces and filled controls more character than a
/// flat color while staying accessible:
///
/// ```swift
/// theme.colors.accent.solidFill = .linearGradient([violet, teal])
/// theme.components.surface.fills[.raised] = .material(.thin, fallback: theme.colors.surfaceRaised)
/// ```
///
/// A fill is a `ShapeStyle`, so it works wherever a color does. Each color in
/// a fill adapts to light mode, dark mode, and Increase Contrast. A material
/// is replaced by its opaque `fallback` when Reduce Transparency is on, and
/// ``SwiftForgeContrastAudit`` checks text against the fallback, because the
/// content behind a material is unknown.
public struct SwiftForgeFill: ShapeStyle, Sendable, Hashable {

    enum Storage: Sendable, Hashable {
        case color(SwiftForgeColor)
        case linearGradient([SwiftForgeColor], startPoint: UnitPoint, endPoint: UnitPoint)
        case material(SwiftForgeMaterial, fallback: SwiftForgeColor)
    }

    let storage: Storage

    /// A flat color.
    public static func color(_ color: SwiftForgeColor) -> SwiftForgeFill {
        SwiftForgeFill(storage: .color(color))
    }

    /// A linear gradient through evenly spaced colors.
    ///
    /// - Parameters:
    ///   - colors: Two or more colors, from the start point to the end point.
    ///   - startPoint: Where the gradient starts. Defaults to the top-leading corner.
    ///   - endPoint: Where the gradient ends. Defaults to the bottom-trailing corner.
    public static func linearGradient(
        _ colors: [SwiftForgeColor],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) -> SwiftForgeFill {
        SwiftForgeFill(storage: .linearGradient(colors, startPoint: startPoint, endPoint: endPoint))
    }

    /// A translucent material that blurs what's behind it.
    ///
    /// - Parameters:
    ///   - material: The material's thickness.
    ///   - fallback: The opaque color shown with Reduce Transparency on, and
    ///     the color text contrast is verified against.
    public static func material(_ material: SwiftForgeMaterial, fallback: SwiftForgeColor) -> SwiftForgeFill {
        SwiftForgeFill(storage: .material(material, fallback: fallback))
    }

    /// Resolves the fill in a SwiftUI environment. SwiftUI calls this when the
    /// fill is used as a `ShapeStyle`.
    public func resolve(in environment: EnvironmentValues) -> AnyShapeStyle {
        switch storage {
        case .color(let color):
            AnyShapeStyle(color)
        case let .linearGradient(colors, startPoint, endPoint):
            AnyShapeStyle(
                LinearGradient(
                    colors: colors.map { Color($0.resolve(in: environment)) },
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
        case let .material(material, fallback):
            environment.swiftForgeReduceTransparency ? AnyShapeStyle(fallback) : AnyShapeStyle(material.material)
        }
    }

    /// The colors text drawn on this fill must contrast with: every gradient
    /// stop and the points between them, or a material's fallback.
    var contrastSamples: [SwiftForgeColor] {
        switch storage {
        case .color(let color):
            return [color]
        case .material(_, let fallback):
            return [fallback]
        case .linearGradient(let colors, _, _):
            guard colors.count > 1 else { return colors }
            var samples: [SwiftForgeColor] = []
            for (start, end) in zip(colors, colors.dropFirst()) {
                samples.append(start)
                for t: Float in [0.25, 0.5, 0.75] {
                    if let mixed = start.mixed(with: end, t) { samples.append(mixed) }
                }
            }
            samples.append(colors[colors.count - 1])
            return samples
        }
    }
}
