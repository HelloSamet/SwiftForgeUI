//
//  SwiftForgeComponentTokens.swift
//  SwiftForgeUI
//

import SwiftUI

/// How a control responds to being pressed.
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgePressEffect: Sendable, Hashable {

    /// Shrinks the control to a fraction of its size, such as `0.97`.
    case scale(CGFloat)

    /// Moves the control by its shadow's offset so it appears pressed into
    /// the page, and hides the shadow. Use with a hard, offset shadow.
    case sinkIntoShadow
}

/// Component-specific tokens: the third token layer, after primitive values
/// and semantic roles.
///
/// Components derive their appearance from semantic tokens — a button's
/// corners from ``SwiftForgeRadius/control``, its outline from
/// ``SwiftForgeBorders/thin``. Component tokens override that derivation for
/// one component only, which is what gives a theme its character:
///
/// ```swift
/// theme.components.button.cornerRadius = SwiftForgeRadius.capsule
/// theme.components.button.borderWidth = 2
/// theme.components.button.pressEffect = .sinkIntoShadow
/// ```
///
/// Optional tokens default to `nil`, meaning "derive from the semantic
/// tokens", so a theme that changes ``SwiftForgeTheme/radius`` still updates
/// every component it hasn't overridden. Tokens with no semantic equivalent
/// have concrete defaults.
public struct SwiftForgeComponentTokens: Sendable, Hashable {

    /// Buttons styled with ``SwiftForgeButtonStyle``, including icon buttons.
    public var button: SwiftForgeButtonTokens
    /// Cards and tappable cards.
    public var card: SwiftForgeCardTokens
    /// Surfaces drawn by ``SwiftUICore/View/swiftForgeSurface(_:shape:outlined:)``, cards, and overlays.
    public var surface: SwiftForgeSurfaceTokens
    /// ``SwiftForgeTextField`` and ``SwiftForgeSecureField``.
    public var field: SwiftForgeFieldTokens
    /// ``SwiftForgeToggleStyle``.
    public var toggle: SwiftForgeToggleTokens
    /// ``SwiftForgeBadge``.
    public var badge: SwiftForgeBadgeTokens
    /// ``SwiftForgeBanner``.
    public var banner: SwiftForgeBannerTokens
    /// ``SwiftForgeLinearProgressViewStyle`` and ``SwiftForgeCircularProgressViewStyle``.
    public var progress: SwiftForgeProgressTokens
    /// ``SwiftUICore/View/swiftForgeLoadingOverlay(isPresented:message:)``.
    public var loadingOverlay: SwiftForgeLoadingOverlayTokens
    /// Checkboxes (``SwiftForgeCheckboxToggleStyle``) and radio buttons (``SwiftForgeRadioGroup``).
    public var selectionControl: SwiftForgeSelectionControlTokens
    /// ``SwiftForgeChip``.
    public var chip: SwiftForgeChipTokens
    /// ``SwiftForgeSegmentedControl``.
    public var segmentedControl: SwiftForgeSegmentedControlTokens
    /// ``SwiftForgeSlider`` and ``SwiftForgeRangeSlider``.
    public var slider: SwiftForgeSliderTokens
    /// ``SwiftForgeAvatar`` and ``SwiftForgeAvatarGroup``.
    public var avatar: SwiftForgeAvatarTokens
    /// ``SwiftForgeEmptyState``.
    public var emptyState: SwiftForgeEmptyStateTokens
    /// ``SwiftForgeToast``.
    public var toast: SwiftForgeToastTokens
    /// ``SwiftForgeAlertDialog``.
    public var dialog: SwiftForgeDialogTokens
    /// ``SwiftForgeTabBar``.
    public var tabBar: SwiftForgeTabBarTokens
    /// Tooltips shown with ``SwiftUICore/View/swiftForgeTooltip(isPresented:content:)``.
    public var tooltip: SwiftForgeTooltipTokens

    /// Creates a set of component tokens. Every component defaults to
    /// deriving its appearance from the semantic tokens.
    public init(
        button: SwiftForgeButtonTokens = SwiftForgeButtonTokens(),
        card: SwiftForgeCardTokens = SwiftForgeCardTokens(),
        surface: SwiftForgeSurfaceTokens = SwiftForgeSurfaceTokens(),
        field: SwiftForgeFieldTokens = SwiftForgeFieldTokens(),
        toggle: SwiftForgeToggleTokens = SwiftForgeToggleTokens(),
        badge: SwiftForgeBadgeTokens = SwiftForgeBadgeTokens(),
        banner: SwiftForgeBannerTokens = SwiftForgeBannerTokens(),
        progress: SwiftForgeProgressTokens = SwiftForgeProgressTokens(),
        loadingOverlay: SwiftForgeLoadingOverlayTokens = SwiftForgeLoadingOverlayTokens(),
        selectionControl: SwiftForgeSelectionControlTokens = SwiftForgeSelectionControlTokens(),
        chip: SwiftForgeChipTokens = SwiftForgeChipTokens(),
        segmentedControl: SwiftForgeSegmentedControlTokens = SwiftForgeSegmentedControlTokens(),
        slider: SwiftForgeSliderTokens = SwiftForgeSliderTokens(),
        avatar: SwiftForgeAvatarTokens = SwiftForgeAvatarTokens(),
        emptyState: SwiftForgeEmptyStateTokens = SwiftForgeEmptyStateTokens(),
        toast: SwiftForgeToastTokens = SwiftForgeToastTokens(),
        dialog: SwiftForgeDialogTokens = SwiftForgeDialogTokens(),
        tabBar: SwiftForgeTabBarTokens = SwiftForgeTabBarTokens(),
        tooltip: SwiftForgeTooltipTokens = SwiftForgeTooltipTokens()
    ) {
        self.button = button
        self.card = card
        self.surface = surface
        self.field = field
        self.toggle = toggle
        self.badge = badge
        self.banner = banner
        self.progress = progress
        self.loadingOverlay = loadingOverlay
        self.selectionControl = selectionControl
        self.chip = chip
        self.segmentedControl = segmentedControl
        self.slider = slider
        self.avatar = avatar
        self.emptyState = emptyState
        self.toast = toast
        self.dialog = dialog
        self.tabBar = tabBar
        self.tooltip = tooltip
    }
}

/// Tokens for ``SwiftForgeButtonStyle``.
public struct SwiftForgeButtonTokens: Sendable, Hashable {

    /// The corner radius at every size, or `nil` for ``SwiftForgeRadius/control``
    /// and ``SwiftForgeRadius/controlSmall``. Use ``SwiftForgeRadius/capsule``
    /// for pill-shaped buttons.
    public var cornerRadius: CGFloat?

    /// The width of a border around filled, tinted, and outline buttons, or
    /// `nil` to outline only outline buttons, with ``SwiftForgeBorders/thin``.
    public var borderWidth: CGFloat?

    /// The border color, or `nil` for the tone's text color (the strong
    /// border color for neutral buttons). Must contrast 3:1 with surfaces.
    public var borderColor: SwiftForgeColor?

    /// The shadow under filled, tinted, and outline buttons. Plain buttons
    /// never have one.
    public var elevation: SwiftForgeElevationLevel

    /// The press feedback, or `nil` to scale by ``SwiftForgeMotion/pressedScale``.
    /// Never applied with Reduce Motion on.
    public var pressEffect: SwiftForgePressEffect?

    /// Creates button tokens.
    public init(
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil,
        elevation: SwiftForgeElevationLevel = .none,
        pressEffect: SwiftForgePressEffect? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.elevation = elevation
        self.pressEffect = pressEffect
    }
}

/// Tokens for ``SwiftForgeCard`` and ``SwiftForgeCardButtonStyle``.
public struct SwiftForgeCardTokens: Sendable, Hashable {

    /// The press feedback of tappable cards. Cards are large, so they press
    /// in less than controls do. Never applied with Reduce Motion on.
    public var pressEffect: SwiftForgePressEffect

    /// Creates card tokens.
    public init(pressEffect: SwiftForgePressEffect = .scale(0.98)) {
        self.pressEffect = pressEffect
    }
}

/// Tokens for themed surfaces: cards, raised panels, and overlays.
public struct SwiftForgeSurfaceTokens: Sendable, Hashable {

    /// The border width, or `nil` for one physical pixel.
    public var borderWidth: CGFloat?

    /// The border color, or `nil` for ``SwiftForgeColors/borderSubtle``.
    public var borderColor: SwiftForgeColor?

    /// Whether every surface above the canvas draws its border, not only
    /// outlined and raised ones. Surfaces always draw it with Increase Contrast on.
    public var bordersEverySurface: Bool

    /// Fills that replace a level's flat color, such as a material for raised
    /// surfaces. Levels without an entry use their color from ``SwiftForgeColors``.
    public var fills: [SwiftForgeSurfaceLevel: SwiftForgeFill]

    /// Creates surface tokens.
    public init(
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil,
        bordersEverySurface: Bool = false,
        fills: [SwiftForgeSurfaceLevel: SwiftForgeFill] = [:]
    ) {
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.bordersEverySurface = bordersEverySurface
        self.fills = fills
    }
}

/// Tokens for ``SwiftForgeTextField`` and ``SwiftForgeSecureField``.
public struct SwiftForgeFieldTokens: Sendable, Hashable {

    /// How a text field marks its input area.
    ///
    /// Cases are added only in major releases, so you can switch over it
    /// exhaustively.
    public enum Style: Sendable, Hashable {
        /// A background with an outline on every side. The default.
        case outlined
        /// A background with a line along the bottom edge.
        case filled
        /// Only a line along the bottom edge, with text aligned to the label.
        case underlined
    }

    /// How the input area is drawn. Every style draws its line in
    /// ``SwiftForgeColors/borderStrong``, which contrasts 3:1 with surfaces, so
    /// the field is identifiable without its background.
    public var style: Style

    /// The corner radius, or `nil` for ``SwiftForgeRadius/control``. Underlined
    /// fields have no corners.
    public var cornerRadius: CGFloat?

    /// The input area's background, or `nil` for ``SwiftForgeColors/surface``
    /// (outlined) and ``SwiftForgeColors/fillMuted`` (filled). Text must
    /// contrast 4.5:1 with it.
    public var background: SwiftForgeColor?

    /// Creates text field tokens.
    public init(style: Style = .outlined, cornerRadius: CGFloat? = nil, background: SwiftForgeColor? = nil) {
        self.style = style
        self.cornerRadius = cornerRadius
        self.background = background
    }
}

/// Tokens for ``SwiftForgeToggleStyle``.
///
/// The switch's track is ``SwiftForgeToneColors/solid`` when on and
/// ``SwiftForgeColors/fillMuted`` with a ``SwiftForgeColors/borderStrong``
/// outline when off. The thumb is ``SwiftForgeToneColors/onSolid`` when on
/// and the neutral tone's solid color when off, so its position — not its
/// color — tells the state, and both contrast with their track.
public struct SwiftForgeToggleTokens: Sendable, Hashable {

    /// The track's width.
    public var trackWidth: CGFloat
    /// The track's height.
    public var trackHeight: CGFloat
    /// The gap between the thumb and the track's edge.
    public var thumbInset: CGFloat
    /// The track's corner radius. The thumb's corners stay concentric.
    public var cornerRadius: CGFloat
    /// A border drawn around the track in both states, or `nil` to outline
    /// only the off track, with ``SwiftForgeBorders/thin``.
    public var borderWidth: CGFloat?
    /// The border color, or `nil` for ``SwiftForgeColors/borderStrong``.
    public var borderColor: SwiftForgeColor?
    /// The thumb's shadow. Themes with hard offset shadows usually set `.none`,
    /// since an offset shadow would cover the track.
    public var thumbElevation: SwiftForgeElevationLevel

    /// Creates toggle tokens. The defaults match the size of the system switch.
    public init(
        trackWidth: CGFloat = 51,
        trackHeight: CGFloat = 31,
        thumbInset: CGFloat = 2,
        cornerRadius: CGFloat = SwiftForgeRadius.capsule,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil,
        thumbElevation: SwiftForgeElevationLevel = .low
    ) {
        self.trackWidth = trackWidth
        self.trackHeight = trackHeight
        self.thumbInset = thumbInset
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.thumbElevation = thumbElevation
    }
}

/// Tokens for ``SwiftForgeBadge``.
public struct SwiftForgeBadgeTokens: Sendable, Hashable {

    /// The corner radius of text and count badges. Defaults to a capsule.
    public var cornerRadius: CGFloat
    /// A border around text and count badges, or `nil` for none.
    public var borderWidth: CGFloat?
    /// The border color, or `nil` for the tone's text color.
    public var borderColor: SwiftForgeColor?
    /// The minimum diameter of a regular count badge at the default text
    /// size. Scales with Dynamic Type.
    public var countDiameter: CGFloat
    /// The minimum diameter of a small count badge (`controlSize(.small)`).
    public var countDiameterSmall: CGFloat
    /// The minimum diameter of a large count badge (`controlSize(.large)`).
    public var countDiameterLarge: CGFloat
    /// The diameter of a dot badge at the default text size. Scales with
    /// Dynamic Type.
    public var dotDiameter: CGFloat

    /// Creates badge tokens.
    public init(
        cornerRadius: CGFloat = SwiftForgeRadius.capsule,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil,
        countDiameter: CGFloat = 18,
        countDiameterSmall: CGFloat = 16,
        countDiameterLarge: CGFloat = 24,
        dotDiameter: CGFloat = 8
    ) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.countDiameter = countDiameter
        self.countDiameterSmall = countDiameterSmall
        self.countDiameterLarge = countDiameterLarge
        self.dotDiameter = dotDiameter
    }
}

/// Tokens for ``SwiftForgeBanner``.
public struct SwiftForgeBannerTokens: Sendable, Hashable {

    /// The corner radius, or `nil` for ``SwiftForgeRadius/card``.
    public var cornerRadius: CGFloat?
    /// A border in the tone's text color, or `nil` for none.
    public var borderWidth: CGFloat?
    /// The title's text style, or `nil` for the theme's ``SwiftForgeTypography/subheadline`` in semibold.
    public var title: SwiftForgeTextStyle?

    /// Creates banner tokens.
    public init(cornerRadius: CGFloat? = nil, borderWidth: CGFloat? = nil, title: SwiftForgeTextStyle? = nil) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.title = title
    }
}

/// Tokens for the SwiftForgeUI progress styles.
public struct SwiftForgeProgressTokens: Sendable, Hashable {

    /// The bar's thickness at small and regular control sizes.
    public var barHeight: CGFloat
    /// The bar's thickness at large control size.
    public var barHeightLarge: CGFloat
    /// The bar's corner radius. Defaults to a capsule.
    public var barCornerRadius: CGFloat
    /// The ring's diameter at small, regular, and large control sizes, at the
    /// default text size. Grows with Dynamic Type.
    public var ringDiameters: SwiftForgeControlSizeValues
    /// The ring's line width at small and regular control sizes.
    public var ringLineWidth: CGFloat
    /// The ring's line width at large control size.
    public var ringLineWidthLarge: CGFloat

    /// Creates progress tokens.
    public init(
        barHeight: CGFloat = 4,
        barHeightLarge: CGFloat = 8,
        barCornerRadius: CGFloat = SwiftForgeRadius.capsule,
        ringDiameters: SwiftForgeControlSizeValues = SwiftForgeControlSizeValues(small: 24, regular: 32, large: 48),
        ringLineWidth: CGFloat = 4,
        ringLineWidthLarge: CGFloat = 6
    ) {
        self.barHeight = barHeight
        self.barHeightLarge = barHeightLarge
        self.barCornerRadius = barCornerRadius
        self.ringDiameters = ringDiameters
        self.ringLineWidth = ringLineWidth
        self.ringLineWidthLarge = ringLineWidthLarge
    }
}

/// A value for each SwiftForgeUI control size.
public struct SwiftForgeControlSizeValues: Sendable, Hashable {
    /// The value for `.mini` and `.small` controls.
    public var small: CGFloat
    /// The value for `.regular` controls.
    public var regular: CGFloat
    /// The value for `.large` and `.extraLarge` controls.
    public var large: CGFloat

    /// Creates a value for each control size.
    public init(small: CGFloat, regular: CGFloat, large: CGFloat) {
        self.small = small
        self.regular = regular
        self.large = large
    }

    subscript(size: SwiftForgeControlSize) -> CGFloat {
        switch size {
        case .small: small
        case .regular: regular
        case .large: large
        }
    }
}

/// Tokens for ``SwiftUICore/View/swiftForgeLoadingOverlay(isPresented:message:)``.
public struct SwiftForgeLoadingOverlayTokens: Sendable, Hashable {

    /// The scrim's color before ``SwiftForgeOpacity/scrim`` is applied, or
    /// `nil` for ``SwiftForgeColors/canvas``.
    public var scrim: SwiftForgeColor?

    /// Creates loading overlay tokens.
    public init(scrim: SwiftForgeColor? = nil) {
        self.scrim = scrim
    }
}

/// Tokens for checkboxes and radio buttons.
///
/// An unchecked box or ring is outlined in ``SwiftForgeColors/borderStrong``,
/// which contrasts 3:1 with surfaces; a checked one fills with the tone's
/// solid color and shows a glyph in ``SwiftForgeToneColors/onSolid``, so the
/// state never relies on color alone.
public struct SwiftForgeSelectionControlTokens: Sendable, Hashable {

    /// The side of a checkbox and the diameter of a radio button at the
    /// default text size. Scales with Dynamic Type; the hit area is always
    /// at least ``SwiftForgeSizes/minimumHitTarget``.
    public var size: CGFloat
    /// The checkbox's corner radius, or `nil` for ``SwiftForgeRadius/xs``.
    public var checkboxCornerRadius: CGFloat?
    /// The outline width, or `nil` for ``SwiftForgeBorders/thick``.
    public var borderWidth: CGFloat?
    /// The unchecked outline color, or `nil` for ``SwiftForgeColors/borderStrong``.
    /// Must contrast 3:1 with surfaces.
    public var borderColor: SwiftForgeColor?

    /// Creates selection control tokens.
    public init(
        size: CGFloat = 22,
        checkboxCornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil
    ) {
        self.size = size
        self.checkboxCornerRadius = checkboxCornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
}

/// Tokens for ``SwiftForgeChip``.
///
/// An unselected chip is outlined in ``SwiftForgeColors/borderStrong`` on the
/// surface color; a selected one fills with the tone's subtle color, outlines
/// in the tone's text color, and shows a checkmark.
public struct SwiftForgeChipTokens: Sendable, Hashable {

    /// The corner radius, or `nil` for ``SwiftForgeRadius/controlSmall``.
    /// Use ``SwiftForgeRadius/capsule`` for pill-shaped chips.
    public var cornerRadius: CGFloat?
    /// The outline width, or `nil` for ``SwiftForgeBorders/thin``.
    public var borderWidth: CGFloat?
    /// The unselected outline color, or `nil` for ``SwiftForgeColors/borderStrong``.
    /// Must contrast 3:1 with surfaces.
    public var borderColor: SwiftForgeColor?
    /// The visual height, or `nil` for ``SwiftForgeSizes/controlHeightSmall``.
    /// The hit area is always at least ``SwiftForgeSizes/minimumHitTarget``.
    public var height: CGFloat?

    /// Creates chip tokens.
    public init(
        cornerRadius: CGFloat? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil,
        height: CGFloat? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.borderColor = borderColor
        self.height = height
    }
}

/// Tokens for ``SwiftForgeSegmentedControl``.
///
/// The track is ``SwiftForgeColors/fillMuted``; the selected segment sits on
/// an indicator of ``SwiftForgeColors/surfaceRaised`` and its title is
/// semibold, so selection doesn't rely on color alone.
public struct SwiftForgeSegmentedControlTokens: Sendable, Hashable {

    /// The track's corner radius, or `nil` for ``SwiftForgeRadius/control``.
    /// The indicator's corners stay concentric.
    public var cornerRadius: CGFloat?
    /// The gap between the indicator and the track's edge.
    public var indicatorInset: CGFloat
    /// The indicator's shadow.
    public var indicatorElevation: SwiftForgeElevationLevel
    /// A border around the track and the indicator, or `nil` for none. The
    /// indicator is outlined in ``SwiftForgeColors/borderStrong`` with
    /// Increase Contrast on even without one.
    public var borderWidth: CGFloat?
    /// The border color, or `nil` for ``SwiftForgeColors/borderStrong``.
    public var borderColor: SwiftForgeColor?

    /// Creates segmented control tokens.
    public init(
        cornerRadius: CGFloat? = nil,
        indicatorInset: CGFloat = 2,
        indicatorElevation: SwiftForgeElevationLevel = .low,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil
    ) {
        self.cornerRadius = cornerRadius
        self.indicatorInset = indicatorInset
        self.indicatorElevation = indicatorElevation
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
}

/// Tokens for ``SwiftForgeSlider`` and ``SwiftForgeRangeSlider``.
///
/// The thumb and the filled part of the track are the tone's text color;
/// the empty part is ``SwiftForgeColors/fillMuted`` outlined in
/// ``SwiftForgeColors/borderStrong``. Every part contrasts at least 3:1 with
/// the surface.
public struct SwiftForgeSliderTokens: Sendable, Hashable {

    /// The track's thickness.
    public var trackHeight: CGFloat
    /// The thumb's visual diameter. Its hit area is always at least
    /// ``SwiftForgeSizes/minimumHitTarget``.
    public var thumbDiameter: CGFloat
    /// The thumb's corner radius. Defaults to a circle.
    public var thumbCornerRadius: CGFloat
    /// The width of an outline around the thumb, or `nil` for none.
    public var thumbBorderWidth: CGFloat?
    /// The thumb's outline color, or `nil` for ``SwiftForgeColors/borderStrong``.
    public var thumbBorderColor: SwiftForgeColor?
    /// The thumb's shadow.
    public var thumbElevation: SwiftForgeElevationLevel

    /// Creates slider tokens.
    public init(
        trackHeight: CGFloat = 4,
        thumbDiameter: CGFloat = 24,
        thumbCornerRadius: CGFloat = SwiftForgeRadius.capsule,
        thumbBorderWidth: CGFloat? = nil,
        thumbBorderColor: SwiftForgeColor? = nil,
        thumbElevation: SwiftForgeElevationLevel = .low
    ) {
        self.trackHeight = trackHeight
        self.thumbDiameter = thumbDiameter
        self.thumbCornerRadius = thumbCornerRadius
        self.thumbBorderWidth = thumbBorderWidth
        self.thumbBorderColor = thumbBorderColor
        self.thumbElevation = thumbElevation
    }
}

/// Tokens for ``SwiftForgeAvatar`` and ``SwiftForgeAvatarGroup``.
///
/// Initials are set in the tone's text color on its subtle color, which
/// contrast 4.5:1 in every built-in theme. The status dot and the group's
/// overlap are outlined in the surface color so neighbors stay distinct.
public struct SwiftForgeAvatarTokens: Sendable, Hashable {

    /// The diameter at small, regular, and large control sizes, at the
    /// default text size. Avatars don't grow with Dynamic Type; their
    /// initials shrink to fit instead.
    public var diameters: SwiftForgeControlSizeValues
    /// The corner radius. Defaults to a circle.
    public var cornerRadius: CGFloat
    /// The width of the ring that separates overlapping avatars and the
    /// status dot from what's behind them.
    public var ringWidth: CGFloat
    /// The share of the diameter each avatar in a group overlaps the previous one.
    public var groupOverlap: Double
    /// A border around every avatar, or `nil` for none.
    public var borderWidth: CGFloat?
    /// The border color, or `nil` for ``SwiftForgeColors/borderStrong``.
    public var borderColor: SwiftForgeColor?

    /// Creates avatar tokens.
    public init(
        diameters: SwiftForgeControlSizeValues = SwiftForgeControlSizeValues(small: 28, regular: 40, large: 64),
        cornerRadius: CGFloat = SwiftForgeRadius.capsule,
        ringWidth: CGFloat = 2,
        groupOverlap: Double = 0.3,
        borderWidth: CGFloat? = nil,
        borderColor: SwiftForgeColor? = nil
    ) {
        self.diameters = diameters
        self.cornerRadius = cornerRadius
        self.ringWidth = ringWidth
        self.groupOverlap = groupOverlap
        self.borderWidth = borderWidth
        self.borderColor = borderColor
    }
}

/// Tokens for ``SwiftForgeEmptyState``.
public struct SwiftForgeEmptyStateTokens: Sendable, Hashable {

    /// The symbol's size at the default text size. Scales with Dynamic Type.
    public var iconSize: CGFloat
    /// The widest the text may grow, so lines stay readable on iPad.
    public var maxContentWidth: CGFloat

    /// Creates empty state tokens.
    public init(iconSize: CGFloat = 48, maxContentWidth: CGFloat = 420) {
        self.iconSize = iconSize
        self.maxContentWidth = maxContentWidth
    }
}

/// Tokens for ``SwiftForgeToast``.
///
/// Toasts sit on the overlay surface (``SwiftForgeSurfaceLevel/overlay``),
/// so they take its fill, shadow, and border.
public struct SwiftForgeToastTokens: Sendable, Hashable {

    /// The corner radius, or `nil` for ``SwiftForgeRadius/card``.
    public var cornerRadius: CGFloat?
    /// The widest a toast grows, so it doesn't span an iPad screen.
    public var maxWidth: CGFloat
    /// How long a ``SwiftForgeToast/DisplayDuration/short`` toast stays, in seconds.
    public var shortDuration: Double
    /// How long a ``SwiftForgeToast/DisplayDuration/long`` toast stays, in seconds.
    public var longDuration: Double

    /// Creates toast tokens.
    public init(cornerRadius: CGFloat? = nil, maxWidth: CGFloat = 560, shortDuration: Double = 4, longDuration: Double = 8) {
        self.cornerRadius = cornerRadius
        self.maxWidth = maxWidth
        self.shortDuration = shortDuration
        self.longDuration = longDuration
    }
}

/// Tokens for ``SwiftForgeAlertDialog``.
///
/// Dialogs sit on the overlay surface over a scrim of
/// ``SwiftForgeOpacity/scrim``.
public struct SwiftForgeDialogTokens: Sendable, Hashable {

    /// The corner radius, or `nil` for ``SwiftForgeRadius/sheet``.
    public var cornerRadius: CGFloat?
    /// The dialog's width at the default text size; it grows with Dynamic
    /// Type up to the screen's width.
    public var width: CGFloat
    /// The scrim's color before ``SwiftForgeOpacity/scrim`` applies, or `nil`
    /// for ``SwiftForgeColors/canvas``.
    public var scrim: SwiftForgeColor?

    /// Creates dialog tokens.
    public init(cornerRadius: CGFloat? = nil, width: CGFloat = 320, scrim: SwiftForgeColor? = nil) {
        self.cornerRadius = cornerRadius
        self.width = width
        self.scrim = scrim
    }
}

/// Tokens for ``SwiftForgeTabBar``.
///
/// The bar is filled like the overlay surface — a material where the theme
/// sets one, opaque with Reduce Transparency — with a hairline along its top.
/// Selected items use the accent's text color and a filled symbol.
public struct SwiftForgeTabBarTokens: Sendable, Hashable {

    /// The bar's height above the bottom safe area, like the system's 49 pt.
    public var height: CGFloat
    /// The base size of item symbols.
    public var iconSize: CGFloat

    /// Creates tab bar tokens.
    public init(height: CGFloat = 49, iconSize: CGFloat = 24) {
        self.height = height
        self.iconSize = iconSize
    }
}

/// Tokens for tooltips shown with ``SwiftUICore/View/swiftForgeTooltip(isPresented:content:)``.
///
/// A tooltip is a system popover filled like the overlay surface — a
/// material where the theme sets one, opaque with Reduce Transparency — with
/// text in ``SwiftForgeColors/textPrimary``. The popover's shape and arrow
/// are the system's.
public struct SwiftForgeTooltipTokens: Sendable, Hashable {

    /// The widest a tooltip's text runs before it wraps.
    public var maxWidth: CGFloat

    /// Creates tooltip tokens.
    public init(maxWidth: CGFloat = 280) {
        self.maxWidth = maxWidth
    }
}
