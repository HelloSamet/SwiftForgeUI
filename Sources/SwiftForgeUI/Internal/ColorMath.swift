//
//  ColorMath.swift
//  SwiftForgeUI
//

import SwiftUI

extension Color.Resolved {

    /// Creates an sRGB color from a `0xRRGGBB` literal.
    init(swiftForgeHex hex: UInt32, opacity: Float = 1) {
        self.init(
            colorSpace: .sRGB,
            red: Float((hex >> 16) & 0xFF) / 255,
            green: Float((hex >> 8) & 0xFF) / 255,
            blue: Float(hex & 0xFF) / 255,
            opacity: opacity
        )
    }

    static let swiftForgeWhite = Color.Resolved(swiftForgeHex: 0xFFFFFF)
    static let swiftForgeBlack = Color.Resolved(swiftForgeHex: 0x000000)
}

/// WCAG 2.x color math. Components are gamma-encoded sRGB, as stored by
/// `Color.Resolved.red/green/blue`.
enum WCAG {

    static func relativeLuminance(_ color: Color.Resolved) -> Double {
        func linearize(_ component: Float) -> Double {
            let value = min(max(Double(component), 0), 1)
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(color.red)
            + 0.7152 * linearize(color.green)
            + 0.0722 * linearize(color.blue)
    }

    /// The contrast ratio between two colors, from 1 to 21. A translucent
    /// foreground is composited over the background first.
    static func contrastRatio(_ foreground: Color.Resolved, _ background: Color.Resolved) -> Double {
        let opaqueBackground = composite(background, over: .swiftForgeWhite)
        let opaqueForeground = composite(foreground, over: opaqueBackground)
        let lighter = max(relativeLuminance(opaqueForeground), relativeLuminance(opaqueBackground))
        let darker = min(relativeLuminance(opaqueForeground), relativeLuminance(opaqueBackground))
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// Source-over compositing in gamma-encoded sRGB, matching how browsers
    /// and design tools evaluate contrast for translucent colors.
    static func composite(_ top: Color.Resolved, over bottom: Color.Resolved) -> Color.Resolved {
        let alpha = min(max(top.opacity, 0), 1)
        guard alpha < 1 else { return top }
        func mix(_ a: Float, _ b: Float) -> Float { a * alpha + b * (1 - alpha) }
        return Color.Resolved(
            colorSpace: .sRGB,
            red: mix(top.red, bottom.red),
            green: mix(top.green, bottom.green),
            blue: mix(top.blue, bottom.blue),
            opacity: 1
        )
    }

    /// Linear interpolation from `start` (t = 0) to `end` (t = 1) in sRGB.
    static func mix(_ start: Color.Resolved, _ end: Color.Resolved, _ t: Float) -> Color.Resolved {
        func lerp(_ a: Float, _ b: Float) -> Float { a + (b - a) * t }
        return Color.Resolved(
            colorSpace: .sRGB,
            red: lerp(start.red, end.red),
            green: lerp(start.green, end.green),
            blue: lerp(start.blue, end.blue),
            opacity: lerp(start.opacity, end.opacity)
        )
    }
}
