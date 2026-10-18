import SwiftUI
import Testing

@testable import SwiftForgeUI

@Suite("Token scales")
struct TokenScaleTests {

    @Test("Spacing increases monotonically with distinct steps", arguments: SwiftForgeTheme.builtIn)
    func spacingIsMonotonic(theme: SwiftForgeTheme) {
        let s = theme.spacing
        let scale = [s.xxxs, s.xxs, s.xs, s.sm, s.md, s.lg, s.xl, s.xxl, s.xxxl]
        #expect(scale == scale.sorted())
        #expect(Set(scale).count == scale.count)
    }

    @Test("The standard spacing scale follows an even-point rhythm")
    func standardSpacingRhythm() {
        let s = SwiftForgeSpacing.standard
        let scale = [s.xxxs, s.xxs, s.xs, s.sm, s.md, s.lg, s.xl, s.xxl, s.xxxl]
        #expect(scale.allSatisfy { $0.truncatingRemainder(dividingBy: 2) == 0 })
    }

    @Test("Radius scales increase monotonically", arguments: SwiftForgeTheme.builtIn.map(\.radius))
    func radiusIsMonotonic(radius: SwiftForgeRadius) {
        let scale = [radius.xs, radius.sm, radius.md, radius.lg, radius.xl, radius.xxl]
        #expect(scale == scale.sorted())
        #expect(radius.controlSmall <= radius.control)
        #expect(radius.control <= radius.card)
        #expect(radius.card <= radius.sheet)
    }

    @Test("Concentric radius subtracts the inset and never goes negative")
    func concentricRadius() {
        #expect(SwiftForgeRadius.concentric(outer: 16, inset: 12) == 4)
        #expect(SwiftForgeRadius.concentric(outer: 8, inset: 12) == 0)
    }

    @Test("Control sizes map to SwiftForgeUI heights")
    func controlHeights() {
        let sizes = SwiftForgeSizes.standard
        #expect(sizes.controlHeight(for: .mini) == sizes.controlHeightSmall)
        #expect(sizes.controlHeight(for: .small) == sizes.controlHeightSmall)
        #expect(sizes.controlHeight(for: .regular) == sizes.controlHeightRegular)
        #expect(sizes.controlHeight(for: .large) == sizes.controlHeightLarge)
        #expect(sizes.controlHeight(for: .extraLarge) == sizes.controlHeightLarge)
        #expect(sizes.minimumHitTarget >= 44)
        #expect(sizes.controlHeightRegular >= sizes.minimumHitTarget)
    }

    @Test("Elevation shadows grow with each level", arguments: SwiftForgeTheme.builtIn)
    func elevationGrows(theme: SwiftForgeTheme) {
        let levels = SwiftForgeElevationLevel.allCases.map { theme.elevation[$0].radius }
        #expect(levels == levels.sorted())
        #expect(theme.elevation[.none] == .none)
    }

    @Test("Disabled opacity is low enough to read as disabled but keeps content visible")
    func opacities() {
        let opacity = SwiftForgeOpacity.standard
        #expect(opacity.disabled > 0.2 && opacity.disabled < 0.5)
        #expect(opacity.scrimReducedTransparency > opacity.scrim)
        #expect(opacity.skeletonPulse > 0 && opacity.skeletonPulse < 1)
    }
}

@Suite("Typography")
struct TypographyTests {

    @Test("Every role is anchored to a Dynamic Type text style")
    func rolesUseTextStyles() {
        let t = SwiftForgeTypography.standard
        #expect(t.body.textStyle == .body)
        #expect(t.controlLabel.textStyle == .body && t.controlLabel.weight == .semibold)
        #expect(t.fieldHelper.textStyle == .footnote)
        // caption2 only partially scales according to Apple's accessibility audit.
        #expect(t.badge.textStyle == .caption)
    }

    @Test("Custom fonts fall back to the nearest provided face")
    func customFontFaces() {
        let family = SwiftForgeFontFamily.custom(regular: "Brand-Regular", bold: "Brand-Bold")
        guard case let .custom(regular, medium, semibold, bold) = family.storage else {
            Issue.record("expected a custom family")
            return
        }
        #expect(regular == "Brand-Regular")
        #expect(medium == "Brand-Regular")
        #expect(semibold == "Brand-Bold")
        #expect(bold == "Brand-Bold")
    }

    @Test("Default point sizes match Apple's Large text size")
    func pointSizes() {
        #expect(SwiftForgeFontFamily.defaultPointSize(for: .body) == 17)
        #expect(SwiftForgeFontFamily.defaultPointSize(for: .largeTitle) == 34)
        #expect(SwiftForgeFontFamily.defaultPointSize(for: .caption2) == 11)
    }

    @Test("weight(_:) returns a modified copy")
    func weightCopy() {
        let style = SwiftForgeTypography.standard.body
        #expect(style.weight(.bold).weight == .bold)
        #expect(style.weight == .regular)
    }
}

@Suite("Motion and haptics")
struct MotionTests {

    @Test("Reduce Motion replaces springs with a short ease")
    func reduceMotion() {
        let token = SwiftForgeMotionToken(duration: 0.45, bounce: 0.15)
        #expect(token.animation(reduceMotion: true) == .easeInOut(duration: 0.2))
        #expect(token.animation(reduceMotion: false) == .spring(duration: 0.45, bounce: 0.15))
        #expect(SwiftForgeMotionToken(duration: 0.1).animation(reduceMotion: true) == .easeInOut(duration: 0.1))
    }

    @Test("Motion tokens are ordered from fast to emphasized")
    func ordering() {
        let motion = SwiftForgeMotion.standard
        #expect(motion.fast.duration < motion.standard.duration)
        #expect(motion.standard.duration < motion.emphasized.duration)
        #expect(motion.pressedScale < 1 && motion.pressedScale > 0.9)
    }

    @Test("Haptics play only for enabled events")
    func haptics() {
        #expect(SwiftForgeHaptics.standard.plays(.error))
        #expect(!SwiftForgeHaptics.disabled.plays(.error))
        let selectionOnly = SwiftForgeHaptics(events: [.selection])
        #expect(selectionOnly.plays(.selection))
        #expect(!selectionOnly.plays(.success))
        #expect(SwiftForgeHaptics.standard.feedback(for: .error) == .error)
        #expect(SwiftForgeHaptics.disabled.feedback(for: .error) == nil)
    }
}

@Suite("Field state")
struct FieldStateTests {

    @Test("Only states with messages carry one")
    func messages() {
        #expect(SwiftForgeFieldState.normal.message == nil)
        #expect(SwiftForgeFieldState.helper("Helper").message != nil)
        #expect(SwiftForgeFieldState.success("Done").message != nil)
        #expect(SwiftForgeFieldState.error("Wrong").message != nil)
    }

    @Test("Validation states map to tones; guidance doesn't")
    func tones() {
        #expect(SwiftForgeFieldState.normal.tone == nil)
        #expect(SwiftForgeFieldState.helper("Helper").tone == nil)
        #expect(SwiftForgeFieldState.success("Done").tone == .success)
        #expect(SwiftForgeFieldState.error("Wrong").tone == .danger)
    }

    @Test("Each state has a distinct icon, so meaning doesn't rely on color")
    func icons() {
        let icons: [SwiftForgeFieldState] = [.helper("a"), .success("b"), .error("c")]
        #expect(Set(icons.map(\.iconName)).count == 3)
    }

    @Test("Equality compares case and message")
    func equality() {
        #expect(SwiftForgeFieldState.error("Required") == .error("Required"))
        #expect(SwiftForgeFieldState.error("Required") != .error("Invalid"))
        #expect(SwiftForgeFieldState.error("Required") != .success("Required"))
    }
}
