//
//  SwiftForgeAccessibility.swift
//  SwiftForgeUI
//

import SwiftUI

/// Accessibility settings to simulate for SwiftForgeUI components, for use in
/// previews, snapshot tests, and in-app design catalogs.
///
/// SwiftUI exposes `colorSchemeContrast`, `accessibilityReduceMotion`, and
/// `accessibilityReduceTransparency` as read-only environment values, so they
/// can't be overridden to preview how a screen behaves under those settings.
/// SwiftForgeUI components read these settings through
/// ``SwiftForgeAccessibilityContext``, which combines the system values with
/// this simulation.
///
/// A simulation can only *turn a setting on*. It never turns off a setting the
/// person using the device has enabled.
public struct SwiftForgeAccessibilitySimulation: Sendable, Hashable {

    /// Whether to render as if Increase Contrast is on.
    public var increasedContrast: Bool

    /// Whether to render as if Reduce Motion is on.
    public var reduceMotion: Bool

    /// Whether to render as if Reduce Transparency is on.
    public var reduceTransparency: Bool

    /// Whether to render as if Differentiate Without Color is on.
    public var differentiateWithoutColor: Bool

    /// Creates a simulation. Every setting defaults to `false`, which defers to
    /// the system value.
    public init(
        increasedContrast: Bool = false,
        reduceMotion: Bool = false,
        reduceTransparency: Bool = false,
        differentiateWithoutColor: Bool = false
    ) {
        self.increasedContrast = increasedContrast
        self.reduceMotion = reduceMotion
        self.reduceTransparency = reduceTransparency
        self.differentiateWithoutColor = differentiateWithoutColor
    }
}

extension EnvironmentValues {

    /// The accessibility settings SwiftForgeUI components simulate in this
    /// part of the view hierarchy. See ``SwiftForgeAccessibilitySimulation``.
    @Entry public var swiftForgeAccessibilitySimulation = SwiftForgeAccessibilitySimulation()

    /// Whether colors should resolve to their high-contrast variants: the
    /// system setting or the SwiftForgeUI simulation.
    var swiftForgeIncreasedContrast: Bool {
        colorSchemeContrast == .increased || swiftForgeAccessibilitySimulation.increasedContrast
    }

    /// Whether translucent materials should be replaced by opaque colors: the
    /// system setting or the SwiftForgeUI simulation.
    var swiftForgeReduceTransparency: Bool {
        accessibilityReduceTransparency || swiftForgeAccessibilitySimulation.reduceTransparency
    }
}

extension View {

    /// Simulates accessibility settings for SwiftForgeUI components beneath this
    /// view — for previews, snapshot tests, and design catalogs.
    ///
    /// ```swift
    /// #Preview("Increased contrast") {
    ///     SettingsScreen()
    ///         .swiftForgeAccessibilitySimulation(increasedContrast: true)
    /// }
    /// ```
    ///
    /// Simulation only adds to the system settings: passing `false` never
    /// disables a setting the person has turned on.
    ///
    /// - Parameters:
    ///   - increasedContrast: Render high-contrast color variants and surface borders.
    ///   - reduceMotion: Replace movement with crossfades and stop looping animations.
    ///   - reduceTransparency: Replace translucent materials and scrims with opaque surfaces.
    ///   - differentiateWithoutColor: Add shapes and glyphs wherever color alone shows a state.
    public func swiftForgeAccessibilitySimulation(
        increasedContrast: Bool = false,
        reduceMotion: Bool = false,
        reduceTransparency: Bool = false,
        differentiateWithoutColor: Bool = false
    ) -> some View {
        transformEnvironment(\.swiftForgeAccessibilitySimulation) { simulation in
            simulation.increasedContrast = simulation.increasedContrast || increasedContrast
            simulation.reduceMotion = simulation.reduceMotion || reduceMotion
            simulation.reduceTransparency = simulation.reduceTransparency || reduceTransparency
            simulation.differentiateWithoutColor = simulation.differentiateWithoutColor || differentiateWithoutColor
        }
    }
}

/// The accessibility settings a SwiftForgeUI component should honor, combining
/// the system settings with any ``SwiftForgeAccessibilitySimulation``.
public struct SwiftForgeAccessibilityValues: Sendable, Hashable {

    /// Increase Contrast is on (system or simulated).
    public var increasedContrast: Bool

    /// Reduce Motion is on (system or simulated).
    public var reduceMotion: Bool

    /// Reduce Transparency is on (system or simulated).
    public var reduceTransparency: Bool

    /// Button Shapes is on.
    public var showButtonShapes: Bool

    /// Differentiate Without Color is on.
    public var differentiateWithoutColor: Bool
}

/// Reads the accessibility settings a SwiftForgeUI component honors.
///
/// Use it in your own components built on SwiftForgeUI tokens so they respond
/// to ``SwiftUICore/View/swiftForgeAccessibilitySimulation(increasedContrast:reduceMotion:reduceTransparency:differentiateWithoutColor:)``
/// the same way built-in components do:
///
/// ```swift
/// struct PulsingDot: View {
///     @SwiftForgeAccessibilityContext private var accessibility
///
///     var body: some View {
///         Circle().scaleEffect(accessibility.reduceMotion ? 1 : pulse)
///     }
/// }
/// ```
@MainActor
@propertyWrapper
public struct SwiftForgeAccessibilityContext: DynamicProperty {

    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityShowButtonShapes) private var showButtonShapes
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.swiftForgeAccessibilitySimulation) private var simulation

    /// Creates the property wrapper.
    public init() {}

    /// The combined accessibility settings.
    public var wrappedValue: SwiftForgeAccessibilityValues {
        SwiftForgeAccessibilityValues(
            increasedContrast: colorSchemeContrast == .increased || simulation.increasedContrast,
            reduceMotion: reduceMotion || simulation.reduceMotion,
            reduceTransparency: reduceTransparency || simulation.reduceTransparency,
            showButtonShapes: showButtonShapes,
            differentiateWithoutColor: differentiateWithoutColor || simulation.differentiateWithoutColor
        )
    }
}
