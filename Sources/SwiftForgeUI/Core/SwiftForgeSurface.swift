//
//  SwiftForgeSurface.swift
//  SwiftForgeUI
//

import SwiftUI

/// How far a surface sits above the screen, which determines its color,
/// shadow, and border.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeSurfaceLevel: Sendable, Hashable, CaseIterable {
    /// The screen background.
    case canvas
    /// Content on the canvas: cards, list cells.
    case surface
    /// An elevated surface: prominent cards, menus.
    case raised
    /// A floating surface: toasts, popovers.
    case overlay

    var elevation: SwiftForgeElevationLevel {
        switch self {
        case .canvas, .surface: .none
        case .raised: .medium
        case .overlay: .high
        }
    }
}

/// The corner treatment of a surface.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeSurfaceShape: Sendable, Hashable {
    /// The theme's card radius.
    case card
    /// The theme's control radius.
    case control
    /// The theme's sheet radius.
    case sheet
    /// Square corners.
    case rectangle

    func cornerRadius(in theme: SwiftForgeTheme) -> CGFloat {
        switch self {
        case .card: theme.radius.card
        case .control: theme.radius.control
        case .sheet: theme.radius.sheet
        case .rectangle: 0
        }
    }
}

struct SwiftForgeSurfaceModifier: ViewModifier {

    let level: SwiftForgeSurfaceLevel
    let shape: SwiftForgeSurfaceShape
    let isOutlined: Bool
    /// Hides the shadow while a tappable card sinks into it.
    var hidesShadow = false
    /// Replaces the shape's corner radius, for components with their own
    /// corner token, such as toasts and dialogs.
    var cornerRadius: CGFloat? = nil

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.displayScale) private var displayScale
    @SwiftForgeAccessibilityContext private var accessibility

    func body(content: Content) -> some View {
        let themedShape = theme.radius.shape(cornerRadius ?? shape.cornerRadius(in: theme))
        content
            .background {
                themedShape
                    .fill(fill)
                    .swiftForgeShadow(hidesShadow ? .none : theme.elevation[level.elevation])
            }
            .overlay {
                if hasBorder {
                    themedShape.strokeBorder(tokens.borderColor ?? theme.colors.borderSubtle, lineWidth: borderWidth)
                }
            }
    }

    private var tokens: SwiftForgeSurfaceTokens { theme.components.surface }

    /// One physical pixel unless the theme sets a width.
    private var borderWidth: CGFloat { tokens.borderWidth ?? 1 / displayScale }

    private var fill: SwiftForgeFill {
        if let fill = tokens.fills[level] { return fill }
        return switch level {
        case .canvas: .color(theme.colors.canvas)
        case .surface: .color(theme.colors.surface)
        case .raised, .overlay: .color(theme.colors.surfaceRaised)
        }
    }

    private var hasBorder: Bool {
        if isOutlined { return true }
        if level == .canvas { return false }
        if accessibility.increasedContrast || tokens.bordersEverySurface { return true }
        return theme.elevation.raisedSurfacesHaveBorder && (level == .raised || level == .overlay)
    }
}

extension View {

    /// Places this view on a themed surface: background color, corner
    /// radius, shadow, and — when needed — a hairline border.
    ///
    /// ```swift
    /// VStack { … }
    ///     .padding()
    ///     .swiftForgeSurface(.raised)
    /// ```
    ///
    /// Surfaces gain a border with Increase Contrast on, so their edges never
    /// rely on a shadow alone. The shadow is drawn behind the background
    /// shape only, never behind the content.
    ///
    /// - Parameters:
    ///   - level: How far the surface sits above the screen. Defaults to ``SwiftForgeSurfaceLevel/surface``.
    ///   - shape: The corner treatment. Defaults to ``SwiftForgeSurfaceShape/card``.
    ///   - outlined: Whether to always draw a hairline border.
    public func swiftForgeSurface(
        _ level: SwiftForgeSurfaceLevel = .surface,
        shape: SwiftForgeSurfaceShape = .card,
        outlined: Bool = false
    ) -> some View {
        modifier(SwiftForgeSurfaceModifier(level: level, shape: shape, isOutlined: outlined))
    }
}
