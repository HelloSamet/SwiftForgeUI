//
//  SwiftForgeSelectionIndicator.swift
//  SwiftForgeUI
//
//  The box of a checkbox and the ring of a radio button.
//

import SwiftUI

/// The three states of a selection control.
enum SwiftForgeSelectionState: Sendable, Hashable {
    case off, on, mixed
}

/// A checkbox's box or a radio button's ring, sized by the selection
/// control tokens and scaled with body text so it stays aligned with the
/// first line of its label.
struct SwiftForgeSelectionIndicator: View {

    enum Shape: Sendable, Hashable { case checkbox, radio }

    let shape: Shape
    let state: SwiftForgeSelectionState
    let tone: SwiftForgeTone
    var isPressed = false
    var isFocused = false

    @Environment(\.swiftForgeTheme) private var theme
    @SwiftForgeAccessibilityContext private var accessibility
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    var body: some View {
        let size = tokens.size * scale
        let outline = theme.radius.shape(cornerRadius(size: size))
        ZStack {
            outline.fill(fill)
            outline.strokeBorder(borderColor, lineWidth: borderWidth)
            mark(size: size)
            if isPressed {
                outline.fill(theme.colors.pressedOverlay)
            }
        }
        .frame(width: size, height: size)
        .swiftForgeFocusRing(isFocused, cornerRadius: cornerRadius(size: size))
        .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: state)
        .accessibilityHidden(true)
    }

    private var tokens: SwiftForgeSelectionControlTokens { theme.components.selectionControl }
    private var colors: SwiftForgeToneColors { theme.colors[tone] }
    private var borderWidth: CGFloat { tokens.borderWidth ?? theme.borders.thick }

    private func cornerRadius(size: CGFloat) -> CGFloat {
        switch shape {
        case .checkbox: tokens.checkboxCornerRadius ?? theme.radius.xs
        case .radio: size / 2
        }
    }

    /// A checked box fills with the tone; a radio ring stays on the surface
    /// and shows a dot instead.
    private var fill: SwiftForgeFill {
        shape == .checkbox && state != .off ? colors.solidPaint : .color(theme.colors.surface)
    }

    /// The outline contrasts 3:1 with the surface in every state: the strong
    /// border color when off, the tone's text color when on.
    private var borderColor: SwiftForgeColor {
        state == .off ? tokens.borderColor ?? theme.colors.borderStrong : tokens.borderColor ?? colors.text
    }

    @ViewBuilder
    private func mark(size: CGFloat) -> some View {
        switch (shape, state) {
        case (_, .off):
            EmptyView()
        case (.checkbox, .on), (.checkbox, .mixed):
            Image(systemName: state == .on ? "checkmark" : "minus")
                .font(.system(size: size * Self.glyphScale, weight: .bold))
                .foregroundStyle(colors.onSolid)
                .transition(.opacity)
        case (.radio, _):
            Circle()
                .fill(colors.text)
                .frame(width: size * Self.dotScale, height: size * Self.dotScale)
                .transition(.opacity)
        }
    }

    /// The glyph and the dot are proportional to the control so every theme's
    /// size keeps the same balance.
    private static let glyphScale: CGFloat = 0.6  // swiftforge-lint: allow (proportion, not a size)
    private static let dotScale: CGFloat = 0.45  // swiftforge-lint: allow (proportion, not a size)
}
