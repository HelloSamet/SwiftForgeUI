//
//  SwiftForgeTheme+BuiltIn.swift
//  SwiftForgeUI
//
//  The list of built-in themes and the tokens they share. Each theme lives in
//  its own file; its colors are documented, with contrast ratios, under
//  docs/design/themes/.
//

import SwiftUI

/// Tokens shared by several built-in themes.
enum SharedTokens {

    /// The layer drawn over a pressed control: black in light mode, white in dark mode.
    static let pressedOverlay = SwiftForgeColor(
        light: Color.Resolved(swiftForgeHex: Palette.black, opacity: 0.10),
        dark: Color.Resolved(swiftForgeHex: Palette.white, opacity: 0.14)
    )

    /// A black shadow with a different opacity in each color scheme.
    static func shadowColor(light: Float, dark: Float) -> SwiftForgeColor {
        SwiftForgeColor(
            light: Color.Resolved(swiftForgeHex: Palette.black, opacity: light),
            dark: Color.Resolved(swiftForgeHex: Palette.black, opacity: dark)
        )
    }

    /// A shadow in one hue with a different opacity in each color scheme.
    static func shadowColor(light: UInt32, _ lightOpacity: Float, dark: UInt32, _ darkOpacity: Float) -> SwiftForgeColor {
        SwiftForgeColor(
            light: Color.Resolved(swiftForgeHex: light, opacity: lightOpacity),
            dark: Color.Resolved(swiftForgeHex: dark, opacity: darkOpacity)
        )
    }

    /// No shadows: depth comes from borders and surface color alone.
    static let flat = SwiftForgeElevation(low: .none, medium: .none, high: .none, raisedSurfacesHaveBorder: true)
}

extension SwiftForgeTheme {

    /// The built-in themes, for theme pickers and catalogs. ``forge`` comes first.
    public static let builtIn: [SwiftForgeTheme] = [
        .forge, .midnight, .aurora, .paper, .neoBrutal, .mono, .ocean, .sunset,
    ]
}
