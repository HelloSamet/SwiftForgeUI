//
//  SwiftForgeColor.swift
//  SwiftForgeUI
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// A color token that resolves to a different value for light mode, dark
/// mode, and their Increase Contrast variants.
///
/// `SwiftForgeColor` is a `ShapeStyle`, so it works anywhere SwiftUI accepts a
/// style — `foregroundStyle(_:)`, `background(_:)`, `fill(_:)`, `tint(_:)`:
///
/// ```swift
/// Text("Saved")
///     .foregroundStyle(theme.colors.success.text)
///     .background(theme.colors.success.subtle, in: .capsule)
/// ```
///
/// Built-in themes define every token with explicit values, which is what
/// lets ``SwiftForgeContrastAudit`` prove their contrast. To use a color from
/// your asset catalog instead, wrap it with ``init(_:)-(Color)``; the audit then
/// checks it in light and dark mode only.
public struct SwiftForgeColor: ShapeStyle, Hashable, Sendable {

    enum Storage: Hashable, Sendable {
        case adaptive(
            light: Color.Resolved,
            dark: Color.Resolved,
            lightHighContrast: Color.Resolved,
            darkHighContrast: Color.Resolved
        )
        case dynamic(Color)
    }

    let storage: Storage

    /// Creates a color token from resolved colors.
    ///
    /// - Parameters:
    ///   - light: The value in light mode.
    ///   - dark: The value in dark mode.
    ///   - lightHighContrast: The value in light mode with Increase Contrast on.
    ///     Defaults to `light`.
    ///   - darkHighContrast: The value in dark mode with Increase Contrast on.
    ///     Defaults to `dark`.
    public init(
        light: Color.Resolved,
        dark: Color.Resolved,
        lightHighContrast: Color.Resolved? = nil,
        darkHighContrast: Color.Resolved? = nil
    ) {
        storage = .adaptive(
            light: light,
            dark: dark,
            lightHighContrast: lightHighContrast ?? light,
            darkHighContrast: darkHighContrast ?? dark
        )
    }

    /// Creates a color token from opaque `0xRRGGBB` sRGB values.
    ///
    /// ```swift
    /// let brand = SwiftForgeColor(light: 0x5B3CC4, dark: 0x7B61E0)
    /// ```
    public init(light: UInt32, dark: UInt32, lightHighContrast: UInt32? = nil, darkHighContrast: UInt32? = nil) {
        self.init(
            light: Color.Resolved(swiftForgeHex: light),
            dark: Color.Resolved(swiftForgeHex: dark),
            lightHighContrast: lightHighContrast.map { Color.Resolved(swiftForgeHex: $0) },
            darkHighContrast: darkHighContrast.map { Color.Resolved(swiftForgeHex: $0) }
        )
    }

    /// Creates a color token with the same value in every appearance.
    ///
    /// - Parameters:
    ///   - hex: An sRGB value in `0xRRGGBB` form.
    ///   - opacity: The color's opacity, from 0 to 1.
    public init(hex: UInt32, opacity: Double = 1) {
        let resolved = Color.Resolved(swiftForgeHex: hex, opacity: Float(opacity))
        self.init(light: resolved, dark: resolved)
    }

    /// Wraps a SwiftUI color — for example an asset-catalog color that
    /// already adapts to appearance.
    ///
    /// SwiftUI resolves the color itself, so Increase Contrast variants come
    /// from the asset catalog, not from SwiftForgeUI's accessibility simulation.
    public init(_ color: Color) {
        storage = .dynamic(color)
    }

    /// Resolves the token for a color scheme and contrast setting.
    ///
    /// This is a pure function of its arguments for tokens created from
    /// explicit values, which makes token colors testable without rendering.
    public func resolve(colorScheme: ColorScheme, increasedContrast: Bool) -> Color.Resolved {
        switch storage {
        case let .adaptive(light, dark, lightHighContrast, darkHighContrast):
            switch (colorScheme, increasedContrast) {
            case (.dark, true): darkHighContrast
            case (.dark, false): dark
            case (_, true): lightHighContrast
            default: light
            }
        case let .dynamic(color):
            color.resolve(in: Self.environment(colorScheme: colorScheme))
        }
    }

    /// Resolves the token in a SwiftUI environment. SwiftUI calls this when
    /// the token is used as a `ShapeStyle`.
    public func resolve(in environment: EnvironmentValues) -> Color.Resolved {
        switch storage {
        case .adaptive:
            resolve(colorScheme: environment.colorScheme, increasedContrast: environment.swiftForgeIncreasedContrast)
        case let .dynamic(color):
            color.resolve(in: environment)
        }
    }

    /// Returns this token with its opacity multiplied by `opacity` in every
    /// appearance.
    public func withOpacity(_ opacity: Double) -> SwiftForgeColor {
        switch storage {
        case let .adaptive(light, dark, lightHighContrast, darkHighContrast):
            func scaled(_ color: Color.Resolved) -> Color.Resolved {
                var copy = color
                copy.opacity *= Float(opacity)
                return copy
            }
            return SwiftForgeColor(
                light: scaled(light),
                dark: scaled(dark),
                lightHighContrast: scaled(lightHighContrast),
                darkHighContrast: scaled(darkHighContrast)
            )
        case let .dynamic(color):
            return SwiftForgeColor(color.opacity(opacity))
        }
    }

    /// The color `t` of the way from this token to `other` in every
    /// appearance, or `nil` if either wraps a SwiftUI `Color`.
    func mixed(with other: SwiftForgeColor, _ t: Float) -> SwiftForgeColor? {
        guard case let .adaptive(l1, d1, lh1, dh1) = storage, case let .adaptive(l2, d2, lh2, dh2) = other.storage else {
            return nil
        }
        return SwiftForgeColor(
            light: WCAG.mix(l1, l2, t),
            dark: WCAG.mix(d1, d2, t),
            lightHighContrast: WCAG.mix(lh1, lh2, t),
            darkHighContrast: WCAG.mix(dh1, dh2, t)
        )
    }

    /// Whether the token defines explicit values for every appearance, so its
    /// contrast can be verified without rendering.
    public var isExplicit: Bool {
        if case .adaptive = storage { true } else { false }
    }

    /// A SwiftUI `Color` that adapts to light and dark mode and Increase
    /// Contrast, for APIs that require a `Color` rather than a `ShapeStyle`.
    ///
    /// Prefer using the token directly as a `ShapeStyle`: unlike the token,
    /// this color does not follow ``SwiftUICore/View/swiftForgeAccessibilitySimulation(increasedContrast:reduceMotion:reduceTransparency:differentiateWithoutColor:)``.
    public var color: Color {
        switch storage {
        case .dynamic(let color):
            return color
        case .adaptive:
            #if canImport(UIKit)
            let token = self
            return Color(
                uiColor: UIColor { traits in
                    let resolved = token.resolve(
                        colorScheme: traits.userInterfaceStyle == .dark ? .dark : .light,
                        increasedContrast: traits.accessibilityContrast == .high
                    )
                    return UIColor(
                        red: CGFloat(resolved.red),
                        green: CGFloat(resolved.green),
                        blue: CGFloat(resolved.blue),
                        alpha: CGFloat(resolved.opacity)
                    )
                }
            )
            #else
            return Color(resolve(colorScheme: .light, increasedContrast: false))
            #endif
        }
    }

    private static func environment(colorScheme: ColorScheme) -> EnvironmentValues {
        var environment = EnvironmentValues()
        environment.colorScheme = colorScheme
        return environment
    }
}

extension SwiftForgeColor {

    /// Opaque white in every appearance.
    public static let white = SwiftForgeColor(hex: 0xFFFFFF)

    /// Opaque black in every appearance.
    public static let black = SwiftForgeColor(hex: 0x000000)

    /// Fully transparent in every appearance.
    public static let clear = SwiftForgeColor(hex: 0x000000, opacity: 0)
}
