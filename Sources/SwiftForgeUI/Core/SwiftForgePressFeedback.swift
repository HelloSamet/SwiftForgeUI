//
//  SwiftForgePressFeedback.swift
//  SwiftForgeUI
//

import SwiftUI

extension SwiftForgePressEffect {

    /// Whether a pressed control sinks into its shadow, which then has to be
    /// hidden: only with ``sinkIntoShadow`` and a visible shadow.
    func sinks(isPressed: Bool, shadow: SwiftForgeShadow) -> Bool {
        isPressed && self == .sinkIntoShadow && shadow != .none
    }
}

/// The movement of a pressed control — scaling down, or sinking into its
/// shadow — shared by every pressable SwiftForgeUI component so they all
/// respond alike. Never moves anything with Reduce Motion on.
private struct SwiftForgePressFeedbackModifier: ViewModifier {

    let effect: SwiftForgePressEffect
    let isPressed: Bool
    let shadow: SwiftForgeShadow

    @Environment(\.swiftForgeTheme) private var theme
    @SwiftForgeAccessibilityContext private var accessibility

    func body(content: Content) -> some View {
        let moves = isPressed && !accessibility.reduceMotion
        content
            .scaleEffect(moves ? scale : 1)
            .offset(
                moves && effect.sinks(isPressed: isPressed, shadow: shadow) ? CGSize(width: shadow.x, height: shadow.y) : .zero
            )
            .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: isPressed)
    }

    private var scale: CGFloat {
        if case .scale(let scale) = effect { scale } else { 1 }
    }
}

extension View {

    /// Applies a pressed control's movement. Callers hide the shadow while
    /// ``SwiftForgePressEffect/sinks(isPressed:shadow:)`` is `true`.
    func swiftForgePressFeedback(_ effect: SwiftForgePressEffect, isPressed: Bool, shadow: SwiftForgeShadow = .none) -> some View
    {
        modifier(SwiftForgePressFeedbackModifier(effect: effect, isPressed: isPressed, shadow: shadow))
    }
}
