//
//  SwiftForgeLayoutTokens.swift
//  SwiftForgeUI
//

import SwiftUI

/// The spacing scale: a 4-point rhythm for padding and gaps.
///
/// Spacing doesn't scale with Dynamic Type, matching Apple's own apps; text
/// and controls grow, the rhythm between them stays constant.
public struct SwiftForgeSpacing: Sendable, Hashable {

    /// 2 pt — badge padding, icon offsets.
    public var xxxs: CGFloat
    /// 4 pt — between an icon and its label, a field and its helper text.
    public var xxs: CGFloat
    /// 8 pt — inside compact components.
    public var xs: CGFloat
    /// 12 pt — inside components, between form fields.
    public var sm: CGFloat
    /// 16 pt — the most common step: card padding, screen margins.
    public var md: CGFloat
    /// 20 pt — between cards.
    public var lg: CGFloat
    /// 24 pt — between groups of content.
    public var xl: CGFloat
    /// 32 pt — between major groups.
    public var xxl: CGFloat
    /// 40 pt — between top-level sections.
    public var xxxl: CGFloat

    /// The horizontal inset from a screen's edges to its content.
    public var screenHorizontal: CGFloat
    /// Vertical spacing between sections of a screen.
    public var section: CGFloat
    /// Spacing between sibling components, such as fields in a form.
    public var component: CGFloat
    /// The default padding inside a card.
    public var cardPadding: CGFloat

    /// Creates a spacing scale.
    public init(
        xxxs: CGFloat, xxs: CGFloat, xs: CGFloat, sm: CGFloat, md: CGFloat, lg: CGFloat, xl: CGFloat, xxl: CGFloat,
        xxxl: CGFloat, screenHorizontal: CGFloat, section: CGFloat, component: CGFloat, cardPadding: CGFloat
    ) {
        self.xxxs = xxxs
        self.xxs = xxs
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.xxxl = xxxl
        self.screenHorizontal = screenHorizontal
        self.section = section
        self.component = component
        self.cardPadding = cardPadding
    }

    /// SwiftForgeUI's spacing scale.
    public static let standard = SwiftForgeSpacing(
        xxxs: 2, xxs: 4, xs: 8, sm: 12, md: 16, lg: 20, xl: 24, xxl: 32, xxxl: 40,
        screenHorizontal: 16, section: 24, component: 12, cardPadding: 16
    )
}

/// The corner-radius scale. Every rounded surface uses continuous corners.
public struct SwiftForgeRadius: Sendable, Hashable {

    /// Checkboxes and other tiny elements.
    public var xs: CGFloat
    /// Skeleton lines and small surfaces.
    public var sm: CGFloat
    /// A medium step of the base scale.
    public var md: CGFloat
    /// A large step of the base scale.
    public var lg: CGFloat
    /// An extra-large step of the base scale.
    public var xl: CGFloat
    /// The largest step of the base scale.
    public var xxl: CGFloat

    /// Buttons and text fields at regular and large control sizes.
    public var control: CGFloat
    /// Buttons and chips at small control size.
    public var controlSmall: CGFloat
    /// Cards, banners, and toasts.
    public var card: CGFloat
    /// Sheets and large modal surfaces.
    public var sheet: CGFloat

    /// How every rounded corner is drawn.
    public var cornerStyle: SwiftForgeCornerStyle

    /// Creates a radius scale.
    ///
    /// Use ``capsule`` for fully rounded ends and `0` for sharp corners.
    public init(
        xs: CGFloat, sm: CGFloat, md: CGFloat, lg: CGFloat, xl: CGFloat, xxl: CGFloat,
        control: CGFloat, controlSmall: CGFloat, card: CGFloat, sheet: CGFloat,
        cornerStyle: SwiftForgeCornerStyle = .continuous
    ) {
        self.xs = xs
        self.sm = sm
        self.md = md
        self.lg = lg
        self.xl = xl
        self.xxl = xxl
        self.control = control
        self.controlSmall = controlSmall
        self.card = card
        self.sheet = sheet
        self.cornerStyle = cornerStyle
    }

    /// The radius for a surface nested inside another, so their corners stay
    /// concentric: the outer radius minus the inset, never below zero.
    ///
    /// ```swift
    /// // An image inset 12 pt inside a card:
    /// .clipShape(.rect(cornerRadius: SwiftForgeRadius.concentric(outer: theme.radius.card, inset: 12)))
    /// ```
    public static func concentric(outer: CGFloat, inset: CGFloat) -> CGFloat {
        max(0, outer - inset)
    }

    /// Soft corners — the ``SwiftForgeTheme/forge`` theme.
    public static let standard = SwiftForgeRadius(
        xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 28,
        control: 12, controlSmall: 8, card: 16, sheet: 28
    )
}

/// Component dimensions.
///
/// Control heights are minimums: Dynamic Type grows a control past them.
public struct SwiftForgeSizes: Sendable, Hashable {

    /// The minimum size of any interactive element's hit area.
    ///
    /// Never smaller than ``accessibleHitTarget`` (Apple's 44 × 44 pt): lower
    /// values are raised to it, so no theme can shrink a hit area below the
    /// accessibility minimum. Dense themes shrink a control's *visual* height
    /// instead.
    public var minimumHitTarget: CGFloat {
        didSet { minimumHitTarget = max(minimumHitTarget, Self.accessibleHitTarget) }
    }

    /// Apple's minimum hit area, 44 pt.
    public static let accessibleHitTarget: CGFloat = 44

    /// The visual height of small controls. Their hit area still meets ``minimumHitTarget``.
    public var controlHeightSmall: CGFloat
    /// The height of regular controls.
    public var controlHeightRegular: CGFloat
    /// The height of large controls.
    public var controlHeightLarge: CGFloat

    /// The base size of icons in small controls, scaled with Dynamic Type.
    public var iconSmall: CGFloat
    /// The base size of icons in regular controls, scaled with Dynamic Type.
    public var iconRegular: CGFloat
    /// The base size of icons in large controls, scaled with Dynamic Type.
    public var iconLarge: CGFloat

    /// Creates a size set.
    public init(
        minimumHitTarget: CGFloat,
        controlHeightSmall: CGFloat,
        controlHeightRegular: CGFloat,
        controlHeightLarge: CGFloat,
        iconSmall: CGFloat,
        iconRegular: CGFloat,
        iconLarge: CGFloat
    ) {
        self.minimumHitTarget = max(minimumHitTarget, Self.accessibleHitTarget)
        self.controlHeightSmall = controlHeightSmall
        self.controlHeightRegular = controlHeightRegular
        self.controlHeightLarge = controlHeightLarge
        self.iconSmall = iconSmall
        self.iconRegular = iconRegular
        self.iconLarge = iconLarge
    }

    /// The visual height for a SwiftUI control size: `.mini` and `.small`
    /// map to small, `.regular` to regular, `.large` and `.extraLarge` to large.
    public func controlHeight(for controlSize: ControlSize) -> CGFloat {
        switch SwiftForgeControlSize(controlSize) {
        case .small: controlHeightSmall
        case .regular: controlHeightRegular
        case .large: controlHeightLarge
        }
    }

    /// SwiftForgeUI's sizes.
    public static let standard = SwiftForgeSizes(
        minimumHitTarget: 44,
        controlHeightSmall: 32,
        controlHeightRegular: 44,
        controlHeightLarge: 52,
        iconSmall: 16,
        iconRegular: 20,
        iconLarge: 24
    )
}

/// SwiftForgeUI's three control sizes, mapped from SwiftUI's `ControlSize`.
enum SwiftForgeControlSize: Sendable, Hashable {
    case small, regular, large

    init(_ controlSize: ControlSize) {
        switch controlSize {
        case .mini, .small: self = .small
        case .large, .extraLarge: self = .large
        default: self = .regular
        }
    }
}

/// Line widths.
public struct SwiftForgeBorders: Sendable, Hashable {

    /// Text field and outline button outlines.
    public var thin: CGFloat
    /// Focus rings and selected outlines.
    public var thick: CGFloat
    /// The gap between a control and its focus ring.
    public var focusRingOffset: CGFloat

    /// Creates a border set. Hairlines are always one physical pixel and
    /// aren't configurable.
    public init(thin: CGFloat, thick: CGFloat, focusRingOffset: CGFloat) {
        self.thin = thin
        self.thick = thick
        self.focusRingOffset = focusRingOffset
    }

    /// SwiftForgeUI's borders.
    public static let standard = SwiftForgeBorders(thin: 1, thick: 2, focusRingOffset: 2)
}

/// Opacity values for interaction states.
public struct SwiftForgeOpacity: Sendable, Hashable {

    /// Applied to a whole disabled control. Disabled content is exempt from
    /// WCAG contrast requirements.
    public var disabled: Double
    /// The content opacity of a plain button while pressed.
    public var pressedContent: Double
    /// The opacity of the scrim behind a loading overlay.
    public var scrim: Double
    /// The scrim opacity when Reduce Transparency is on.
    public var scrimReducedTransparency: Double
    /// The opacity at the center of the band that sweeps across loading
    /// placeholders: the placeholder fades toward the background there.
    public var skeletonPulse: Double

    /// Creates an opacity set.
    public init(
        disabled: Double,
        pressedContent: Double,
        scrim: Double,
        scrimReducedTransparency: Double,
        skeletonPulse: Double
    ) {
        self.disabled = disabled
        self.pressedContent = pressedContent
        self.scrim = scrim
        self.scrimReducedTransparency = scrimReducedTransparency
        self.skeletonPulse = skeletonPulse
    }

    /// SwiftForgeUI's opacities.
    public static let standard = SwiftForgeOpacity(
        disabled: 0.38,
        pressedContent: 0.6,
        scrim: 0.72,
        scrimReducedTransparency: 0.95,
        skeletonPulse: 0.45
    )
}
