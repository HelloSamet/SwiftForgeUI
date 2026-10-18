//
//  SwiftForgeTheme+Forge.swift
//  SwiftForgeUI
//
//  ContrastAuditTests checks every color pair below in all four appearances.
//

import SwiftUI

// MARK: - Shared status tones

private enum StatusTones {

    typealias P = Palette

    static let info = SwiftForgeToneColors(
        solid: SwiftForgeColor(
            light: P.Blue.s600, dark: P.Blue.s550, lightHighContrast: P.Blue.s700, darkHighContrast: P.Blue.s350),
        onSolid: SwiftForgeColor(light: P.white, dark: P.white, lightHighContrast: P.white, darkHighContrast: P.black),
        text: SwiftForgeColor(
            light: P.Blue.s600, dark: P.Blue.s400, lightHighContrast: P.Blue.s700, darkHighContrast: P.Blue.s300),
        subtle: SwiftForgeColor(
            light: P.Blue.s50, dark: P.Blue.s950, lightHighContrast: P.Blue.s100, darkHighContrast: P.Blue.s900)
    )

    static let success = SwiftForgeToneColors(
        solid: SwiftForgeColor(
            light: P.Green.s600, dark: P.Green.s650, lightHighContrast: P.Green.s800, darkHighContrast: P.Green.s400),
        onSolid: SwiftForgeColor(light: P.white, dark: P.white, lightHighContrast: P.white, darkHighContrast: P.black),
        text: SwiftForgeColor(
            light: P.Green.s700, dark: P.Green.s450, lightHighContrast: P.Green.s800, darkHighContrast: P.Green.s300),
        subtle: SwiftForgeColor(
            light: P.Green.s50, dark: P.Green.s950, lightHighContrast: P.Green.s100, darkHighContrast: P.Green.s900)
    )

    static let warning = SwiftForgeToneColors(
        solid: SwiftForgeColor(
            light: P.Amber.s350, dark: P.Amber.s300, lightHighContrast: P.Amber.s500, darkHighContrast: P.Amber.s250),
        onSolid: SwiftForgeColor(light: P.black, dark: P.black),
        text: SwiftForgeColor(
            light: P.Amber.s700, dark: P.Amber.s300, lightHighContrast: P.Amber.s800, darkHighContrast: P.Amber.s200),
        subtle: SwiftForgeColor(
            light: P.Amber.s50, dark: P.Amber.s950, lightHighContrast: P.Amber.s100, darkHighContrast: P.Amber.s900)
    )

    static let danger = SwiftForgeToneColors(
        solid: SwiftForgeColor(light: P.Red.s600, dark: P.Red.s550, lightHighContrast: P.Red.s700, darkHighContrast: P.Red.s350),
        onSolid: SwiftForgeColor(light: P.white, dark: P.white, lightHighContrast: P.white, darkHighContrast: P.black),
        text: SwiftForgeColor(light: P.Red.s650, dark: P.Red.s300, lightHighContrast: P.Red.s750, darkHighContrast: P.Red.s200),
        subtle: SwiftForgeColor(light: P.Red.s50, dark: P.Red.s950, lightHighContrast: P.Red.s100, darkHighContrast: P.Red.s900)
    )
}

extension SwiftForgeTheme {

    // MARK: - Forge

    /// The default theme: balanced, modern, and neutral — the reference the
    /// other themes are measured against.
    ///
    /// iOS-native grays with a blue accent tuned to meet WCAG AA with white
    /// text. Depth comes from shadows in light mode and lighter surfaces in
    /// dark mode. Corners are soft (12 pt controls, 16 pt cards).
    public static let forge: SwiftForgeTheme = {
        typealias P = Palette
        return SwiftForgeTheme(
            id: "forge",
            displayName: "Forge",
            colors: SwiftForgeColors(
                canvas: SwiftForgeColor(light: P.Gray.s50, dark: P.black),
                surface: SwiftForgeColor(light: P.white, dark: P.Gray.s900),
                surfaceRaised: SwiftForgeColor(light: P.white, dark: P.Gray.s800),
                fillMuted: SwiftForgeColor(light: P.Gray.s100, dark: P.Gray.s700),
                textPrimary: SwiftForgeColor(light: P.black, dark: P.white),
                textSecondary: SwiftForgeColor(
                    light: P.Gray.s500, dark: P.Gray.s300, lightHighContrast: P.Gray.s700, darkHighContrast: P.Gray.s200),
                borderSubtle: SwiftForgeColor(
                    light: P.Gray.s200, dark: P.Gray.s750, lightHighContrast: P.Gray.s400, darkHighContrast: P.Gray.s400),
                borderStrong: SwiftForgeColor(
                    light: P.Gray.s450, dark: P.Gray.s400, lightHighContrast: P.Gray.s550, darkHighContrast: P.Gray.s300),
                focusRing: StatusTones.info.text,
                pressedOverlay: SharedTokens.pressedOverlay,
                accent: StatusTones.info,
                neutral: SwiftForgeToneColors(
                    solid: SwiftForgeColor(
                        light: P.Gray.s600, dark: P.Gray.s300, lightHighContrast: P.Gray.s800, darkHighContrast: P.Gray.s200),
                    onSolid: SwiftForgeColor(light: P.white, dark: P.black),
                    text: SwiftForgeColor(
                        light: P.Gray.s500, dark: P.Gray.s300, lightHighContrast: P.Gray.s700, darkHighContrast: P.Gray.s200),
                    subtle: SwiftForgeColor(light: P.Gray.s100, dark: P.Gray.s700)
                ),
                info: StatusTones.info,
                success: StatusTones.success,
                warning: StatusTones.warning,
                danger: StatusTones.danger
            ),
            radius: .standard,
            elevation: SwiftForgeElevation(
                low: SwiftForgeShadow(color: SharedTokens.shadowColor(light: 0.08, dark: 0.40), radius: 3, y: 1),
                medium: SwiftForgeShadow(color: SharedTokens.shadowColor(light: 0.10, dark: 0.50), radius: 12, y: 4),
                high: SwiftForgeShadow(color: SharedTokens.shadowColor(light: 0.16, dark: 0.60), radius: 32, y: 12),
                raisedSurfacesHaveBorder: false
            )
        )
    }()
}
