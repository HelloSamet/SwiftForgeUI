//
//  SwiftForgeButtonStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// The SwiftForgeUI button style, for any native `Button`, `NavigationLink`,
/// `ShareLink`, or `Menu`.
///
/// ```swift
/// Button("Continue") { next() }
///     .buttonStyle(.swiftForge(.filled))
///     .controlSize(.large)
///
/// Button("Delete", role: .destructive) { delete() }
///     .buttonStyle(.swiftForge(.tinted))
/// ```
///
/// - **Variant** sets emphasis: ``Variant/filled`` for the one primary action
///   on a screen, ``Variant/tinted`` and ``Variant/outlined`` for secondary
///   actions, ``Variant/plain`` for low-emphasis actions.
/// - **Tone** defaults to the accent, or to danger for buttons with
///   `role: .destructive`.
/// - **Size** comes from SwiftUI's `controlSize(_:)`: `.small` (32 pt),
///   `.regular` (44 pt), `.large` (52 pt). The hit area is never smaller than
///   44 × 44 pt.
///
/// Buttons size to their content. Use ``SwiftUICore/View/swiftForgeFullWidth(_:)``
/// to fill the available width, ``SwiftUICore/View/swiftForgeLoading(_:)``
/// (or ``SwiftForgeButton``) to show an in-flight action, and
/// ``SwiftUICore/View/swiftForgeIconPlacement(_:)`` to put the icon after the title:
///
/// ```swift
/// Button("Continue", systemImage: "arrow.forward") { next() }
///     .buttonStyle(.swiftForge(.filled))
///     .swiftForgeIconPlacement(.trailing)
/// ```
public struct SwiftForgeButtonStyle: ButtonStyle {

    /// A button's level of emphasis.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Variant: String, Sendable, Hashable, CaseIterable {
        /// A solid background — the screen's primary action.
        case filled
        /// A light tinted background — a prominent secondary action.
        case tinted
        /// An outline — a secondary action beside a filled button.
        case outlined
        /// Text only — a low-emphasis action.
        case plain
    }

    /// The shape of an icon-only button.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum IconShape: Sendable, Hashable {
        /// A square with the theme's control radius.
        case roundedRectangle
        /// A circle.
        case circle
    }

    let variant: Variant
    let tone: SwiftForgeTone?
    let iconShape: IconShape?

    /// Creates a button style.
    ///
    /// - Parameters:
    ///   - variant: The level of emphasis. Defaults to ``Variant/filled``.
    ///   - tone: The color family. Defaults to the accent, or danger for
    ///     destructive buttons.
    public init(_ variant: Variant = .filled, tone: SwiftForgeTone? = nil) {
        self.init(variant: variant, tone: tone, iconShape: nil)
    }

    init(variant: Variant, tone: SwiftForgeTone?, iconShape: IconShape?) {
        self.variant = variant
        self.tone = tone
        self.iconShape = iconShape
    }

    /// Creates a view that represents the body of a styled control.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeButtonStyleBody(configuration: configuration, variant: variant, toneOverride: tone, iconShape: iconShape)
    }
}

extension ButtonStyle where Self == SwiftForgeButtonStyle {

    /// The SwiftForgeUI button style.
    ///
    /// - Parameters:
    ///   - variant: The level of emphasis. Defaults to ``SwiftForgeButtonStyle/Variant/filled``.
    ///   - tone: The color family. Defaults to the accent, or danger for
    ///     destructive buttons.
    public static func swiftForge(_ variant: SwiftForgeButtonStyle.Variant = .filled, tone: SwiftForgeTone? = nil) -> Self {
        SwiftForgeButtonStyle(variant, tone: tone)
    }

    /// The SwiftForgeUI style for icon-only buttons.
    ///
    /// Give the button a title — it becomes the VoiceOver label, the pointer
    /// tooltip, and the Voice Control name — and the style shows only the icon:
    ///
    /// ```swift
    /// Button("Close", systemImage: "xmark") { dismiss() }
    ///     .buttonStyle(.swiftForgeIcon(.tinted))
    /// ```
    ///
    /// - Parameters:
    ///   - variant: The level of emphasis. Defaults to ``SwiftForgeButtonStyle/Variant/plain``.
    ///   - tone: The color family. Defaults to the accent, or danger for
    ///     destructive buttons.
    ///   - shape: The button's shape. Defaults to a rounded square.
    public static func swiftForgeIcon(
        _ variant: SwiftForgeButtonStyle.Variant = .plain,
        tone: SwiftForgeTone? = nil,
        shape: SwiftForgeButtonStyle.IconShape = .roundedRectangle
    ) -> Self {
        SwiftForgeButtonStyle(variant: variant, tone: tone, iconShape: shape)
    }
}

// MARK: - Body

struct SwiftForgeButtonStyleBody: View {

    let configuration: ButtonStyleConfiguration
    let variant: SwiftForgeButtonStyle.Variant
    let toneOverride: SwiftForgeTone?
    let iconShape: SwiftForgeButtonStyle.IconShape?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @Environment(\.controlSize) private var controlSize
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.swiftForgeButtonIsLoading) private var isLoading
    @Environment(\.swiftForgeButtonFullWidth) private var isFullWidth
    @Environment(\.swiftForgeIconPlacement) private var iconPlacement
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        let size = SwiftForgeControlSize(controlSize)
        let height = theme.sizes.controlHeight(for: controlSize)
        let radius = cornerRadius(size: size, height: height)
        let shape = theme.radius.shape(radius)
        let isPressed = configuration.isPressed && !isLoading
        let visibleShadow = hasShadow ? shadow : .none
        let isSinking = pressEffect.sinks(isPressed: isPressed, shadow: visibleShadow)

        configuration.label
            .labelStyle(
                SwiftForgeButtonLabelStyle(isIconOnly: iconShape != nil, iconPlacement: iconPlacement, spacing: theme.spacing.xs)
            )
            .font(theme.typography.font(size == .small ? theme.typography.controlLabelSmall : theme.typography.controlLabel))
            .foregroundStyle(variant == .filled ? toneColors.onSolid : toneColors.text)
            .multilineTextAlignment(.center)
            .opacity(isLoading ? 0 : (variant == .plain && isPressed ? theme.opacity.pressedContent : 1))
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(size == .small ? .small : .regular)
                        .tint(resolved(variant == .filled ? toneColors.onSolid : toneColors.text))
                }
            }
            .padding(.horizontal, iconShape == nil ? horizontalPadding(size) : 0)
            .padding(.vertical, theme.spacing.xxs)
            .frame(minWidth: iconShape == nil ? nil : height, maxWidth: isFullWidth ? .infinity : nil, minHeight: height)
            .background {
                shape
                    .fill(background(isPressed: isPressed))
                    .swiftForgeShadow(hasShadow && !isSinking ? shadow : .none)
            }
            .overlay {
                if let border {
                    shape.strokeBorder(border.color, lineWidth: border.width)
                }
            }
            .overlay {
                if isPressed && (variant == .filled || variant == .tinted) {
                    shape.fill(theme.colors.pressedOverlay)
                }
            }
            .swiftForgeFocusRing(isFocused, cornerRadius: radius)
            .contentShape(shape)
            .swiftForgePressFeedback(pressEffect, isPressed: isPressed, shadow: visibleShadow)
            .frame(minWidth: theme.sizes.minimumHitTarget, minHeight: theme.sizes.minimumHitTarget)
            .contentShape(Rectangle())
            .opacity(isEnabled || isLoading ? 1 : theme.opacity.disabled)
            .accessibilityValue(isLoading ? SwiftForgeStrings.loading : Text(verbatim: ""))
    }

    private var tokens: SwiftForgeButtonTokens { theme.components.button }

    private var tone: SwiftForgeTone {
        toneOverride ?? (configuration.role == .destructive ? .danger : .accent)
    }

    private var toneColors: SwiftForgeToneColors { theme.colors[tone] }

    private var outlineColor: SwiftForgeColor {
        tokens.borderColor ?? (tone == .neutral ? theme.colors.borderStrong : toneColors.text)
    }

    /// Outline buttons always have a border; with a border width token,
    /// filled and tinted buttons do too.
    private var border: (width: CGFloat, color: SwiftForgeColor)? {
        switch variant {
        case .plain: nil
        case .outlined: (tokens.borderWidth ?? theme.borders.thin, outlineColor)
        case .filled, .tinted: tokens.borderWidth.map { ($0, outlineColor) }
        }
    }

    private var hasShadow: Bool { variant != .plain && tokens.elevation != .none }

    private var shadow: SwiftForgeShadow { theme.elevation[tokens.elevation] }

    private var pressEffect: SwiftForgePressEffect { tokens.pressEffect ?? .scale(theme.motion.pressedScale) }

    private func background(isPressed: Bool) -> SwiftForgeFill {
        switch variant {
        case .filled: toneColors.solidPaint
        case .tinted: .color(toneColors.subtle)
        // An elevated outline button sits on a surface, so its shadow reads
        // as a solid object rather than a second outline.
        case .outlined: .color(isPressed ? toneColors.subtle : (hasShadow ? theme.colors.surface : .clear))
        case .plain: .color(accessibility.showButtonShapes ? toneColors.subtle : .clear)
        }
    }

    private func cornerRadius(size: SwiftForgeControlSize, height: CGFloat) -> CGFloat {
        if iconShape == .circle { return height / 2 }
        if let cornerRadius = tokens.cornerRadius { return cornerRadius }
        return size == .small ? theme.radius.controlSmall : theme.radius.control
    }

    private func horizontalPadding(_ size: SwiftForgeControlSize) -> CGFloat {
        if variant == .plain { return theme.spacing.xs }
        switch size {
        case .small: return theme.spacing.sm
        case .regular: return theme.spacing.md
        case .large: return theme.spacing.lg
        }
    }

    private func resolved(_ color: SwiftForgeColor) -> Color {
        Color(color.resolve(colorScheme: colorScheme, increasedContrast: accessibility.increasedContrast))
    }
}

/// Lays out button labels with the theme's icon spacing and the icon on
/// either side, or shows only the icon for icon buttons while keeping the
/// title as the accessibility label.
struct SwiftForgeButtonLabelStyle: LabelStyle {

    let isIconOnly: Bool
    let iconPlacement: SwiftForgeIconPlacement
    let spacing: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        if isIconOnly {
            // The system icon-only style keeps the title as the accessibility
            // label, tooltip, and Voice Control name; drawing the icon alone
            // would leave the button unlabeled.
            Label(configuration).labelStyle(.iconOnly)
        } else {
            HStack(spacing: spacing) {
                if iconPlacement == .leading {
                    configuration.icon
                }
                configuration.title
                if iconPlacement == .trailing {
                    configuration.icon
                }
            }
        }
    }
}

// MARK: - Loading and layout modifiers

extension EnvironmentValues {
    @Entry var swiftForgeButtonIsLoading = false
    @Entry var swiftForgeButtonFullWidth = false
}

extension View {

    /// Shows a SwiftForgeUI button's in-flight state.
    ///
    /// While `isLoading` is `true`, the button shows a progress indicator in
    /// place of its label without changing size, ignores taps, keyboard, and
    /// VoiceOver activation, and reports "Loading" as its accessibility value.
    /// It doesn't dim like a disabled button.
    ///
    /// ```swift
    /// Button("Pay") { pay() }
    ///     .buttonStyle(.swiftForge(.filled))
    ///     .swiftForgeLoading(isPaying)
    /// ```
    ///
    /// Apply it to the button itself: it disables everything beneath it.
    /// To have the button manage this state for an `async` action, use
    /// ``SwiftForgeButton`` instead.
    public func swiftForgeLoading(_ isLoading: Bool) -> some View {
        environment(\.swiftForgeButtonIsLoading, isLoading)
            .disabled(isLoading)
    }

    /// Makes SwiftForgeUI buttons beneath this view fill the available width.
    ///
    /// ```swift
    /// VStack {
    ///     Button("Create Account") { }.buttonStyle(.swiftForge(.filled))
    ///     Button("Sign In") { }.buttonStyle(.swiftForge(.outlined))
    /// }
    /// .swiftForgeFullWidth()
    /// ```
    public func swiftForgeFullWidth(_ isFullWidth: Bool = true) -> some View {
        environment(\.swiftForgeButtonFullWidth, isFullWidth)
    }
}

// MARK: - Previews

#Preview("Variants") {
    VStack(spacing: 12) {
        ForEach(SwiftForgeButtonStyle.Variant.allCases, id: \.self) { variant in
            HStack {
                Button(variant.rawValue.capitalized) {}.buttonStyle(.swiftForge(variant))
                Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge(variant))
                Button("Share", systemImage: "square.and.arrow.up") {}.buttonStyle(.swiftForgeIcon(variant))
            }
        }
    }
    .padding()
}

#Preview("Sizes and icons") {
    VStack(spacing: 12) {
        Button("Small") {}.controlSize(.small)
        Button("Regular") {}
        Button("Large") {}.controlSize(.large)
        Button("Full width") {}.controlSize(.large).swiftForgeFullWidth()
        Button("Leading icon", systemImage: "plus") {}
        Button("Trailing icon", systemImage: "arrow.forward") {}.swiftForgeIconPlacement(.trailing)
    }
    .buttonStyle(.swiftForge(.filled))
    .padding()
}

#Preview("States") {
    VStack(spacing: 12) {
        Button("Disabled") {}.disabled(true)
        Button("Loading") {}.swiftForgeLoading(true)
        Button("Tinted loading") {}.buttonStyle(.swiftForge(.tinted)).swiftForgeLoading(true)
    }
    .buttonStyle(.swiftForge(.filled))
    .padding()
}

#Preview("Midnight, dark") {
    VStack(spacing: 12) {
        ForEach(SwiftForgeButtonStyle.Variant.allCases, id: \.self) { variant in
            Button(variant.rawValue.capitalized) {}.buttonStyle(.swiftForge(variant))
        }
    }
    .padding()
    .background(SwiftForgeTheme.midnight.colors.canvas)
    .swiftForgeTheme(.midnight)
    .preferredColorScheme(.dark)
}

#Preview("AX5 + RTL") {
    VStack(spacing: 12) {
        Button("Continue to payment", systemImage: "arrow.forward") {}.buttonStyle(.swiftForge(.filled))
        Button("Cancel") {}.buttonStyle(.swiftForge(.outlined))
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility5)
    .environment(\.layoutDirection, .rightToLeft)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("Filled") {}.buttonStyle(.swiftForge(.filled))
                Button("Tinted") {}.buttonStyle(.swiftForge(.tinted))
                Button("Outlined") {}.buttonStyle(.swiftForge(.outlined))
                Button("Share", systemImage: "square.and.arrow.up") {}.buttonStyle(.swiftForgeIcon(.tinted))
            }
            HStack {
                Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge(.filled))
                Button("Plain") {}.buttonStyle(.swiftForge(.plain))
                Button("Disabled") {}.buttonStyle(.swiftForge()).disabled(true)
                Button("Pay") {}.buttonStyle(.swiftForge()).swiftForgeLoading(true)
            }
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("Filled") {}.buttonStyle(.swiftForge(.filled))
                Button("Tinted") {}.buttonStyle(.swiftForge(.tinted))
                Button("Outlined") {}.buttonStyle(.swiftForge(.outlined))
                Button("Share", systemImage: "square.and.arrow.up") {}.buttonStyle(.swiftForgeIcon(.tinted))
            }
            HStack {
                Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge(.filled))
                Button("Plain") {}.buttonStyle(.swiftForge(.plain))
                Button("Disabled") {}.buttonStyle(.swiftForge()).disabled(true)
                Button("Pay") {}.buttonStyle(.swiftForge()).swiftForgeLoading(true)
            }
        }
    }
}
