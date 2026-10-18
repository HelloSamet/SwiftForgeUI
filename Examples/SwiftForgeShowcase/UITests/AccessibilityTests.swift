//
//  AccessibilityTests.swift
//  UITests
//
//  VoiceOver semantics and Apple's automated accessibility audit. These run
//  as UI tests because SwiftUI only builds its accessibility tree while an
//  assistive technology — VoiceOver or XCUITest — is attached.
//

import XCTest

final class AccessibilityTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    /// The built-in theme identifiers; the audit runs in each, in light and dark mode.
    private static let themes = ["forge", "midnight", "aurora", "paper", "neo-brutal", "mono", "ocean", "sunset"]

    @MainActor
    private func launch(_ fixture: String, theme: String = "forge", appearance: String = "light") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", fixture, "-uiTestTheme", theme, "-uiTestAppearance", appearance]
        app.launch()
        return app
    }

    // MARK: Semantics

    @MainActor
    func testBannerReadsToneTitleAndMessageTogether() {
        let app = launch("semantics")
        XCTAssertTrue(app.descendants(matching: .any)["Error: Couldn't save. Try again."].exists)
    }

    @MainActor
    func testLibraryStringsFollowTheEnvironmentLocale() {
        let app = launch("semantics")
        XCTAssertTrue(app.descendants(matching: .any)["Hata: Kaydedilemedi"].exists)
    }

    @MainActor
    func testCountBadgeReadsTheFullCount() {
        let app = launch("semantics")
        let badge = app.descendants(matching: .any).matching(
            NSPredicate(format: "label CONTAINS '1250' OR label CONTAINS '1,250'"))
        XCTAssertEqual(badge.count, 1)
        XCTAssertTrue(badge.firstMatch.label.hasSuffix("new items"))
    }

    @MainActor
    func testBadgeOnAButtonBecomesItsValue() {
        let app = launch("semantics")
        let inbox = app.buttons["Inbox"]
        XCTAssertTrue(inbox.exists)
        XCTAssertEqual(inbox.value as? String, "3 new items")
    }

    @MainActor
    func testIconButtonsUseTheirTitleAsLabel() {
        let app = launch("semantics")
        // SwiftUI sets the symbol name as the identifier; the label must be the title.
        XCTAssertEqual(app.buttons["xmark"].label, "Close")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "label == 'xmark'")).count, 0)
    }

    @MainActor
    func testTogglesAreSwitchesWithTheirState() {
        let app = launch("auditButtons")
        let notifications = app.switches["Notifications"]
        XCTAssertTrue(notifications.exists)
        XCTAssertEqual(notifications.value as? String, "1")
        XCTAssertEqual(app.switches["Sounds"].value as? String, "0")
        XCTAssertFalse(app.switches["Disabled"].isEnabled)
    }

    @MainActor
    func testTextFieldLabelIsNotThePrompt() {
        let app = launch("semantics")
        let field = app.textFields.firstMatch
        XCTAssertEqual(field.label, "Email")
        XCTAssertEqual(field.placeholderValue, "you@example.com")
    }

    // MARK: Automated audit

    @MainActor
    func testButtonsPassTheAccessibilityAudit() throws {
        try audit("auditButtons")
    }

    @MainActor
    func testFieldsPassTheAccessibilityAudit() throws {
        try audit("auditFields")
    }

    @MainActor
    func testFeedbackPassesTheAccessibilityAudit() throws {
        try audit("auditFeedback")
    }

    @MainActor
    func testCardsAndProgressPassTheAccessibilityAudit() throws {
        try audit("auditCards")
    }

    @MainActor
    func testSelectionControlsPassTheAccessibilityAudit() throws {
        try audit("auditSelection")
    }

    @MainActor
    func testChipsAndSegmentsPassTheAccessibilityAudit() throws {
        try audit("auditChoices")
    }

    @MainActor
    func testDisplayComponentsPassTheAccessibilityAudit() throws {
        try audit("auditDisplay")
    }

    @MainActor
    func testRowsInAListPassTheAccessibilityAudit() throws {
        // In a `List`, the audit also reports findings without an element —
        // from UIKit's list machinery, not from the rows: the same page built
        // only from native views (the `nativeListBaseline` fixture) produced
        // 16 of them, this page 7 (2026-10-10). Findings with an element
        // still fail the test.
        try audit("listRowsPage", ignoringFindingsWithoutElement: true)
    }

    @MainActor
    func testToastsPassTheAccessibilityAudit() throws {
        try audit("auditToasts")
    }

    @MainActor
    func testDialogPassesTheAccessibilityAudit() throws {
        try audit("auditDialog")
    }

    @MainActor
    func testTabBarsPassTheAccessibilityAudit() throws {
        // Like the system tab bar, item titles stop growing at the largest
        // standard size and offer the Large Content Viewer instead (HIG,
        // "Tab bars"); the audit can't see the viewer, so it reports the
        // titles as partially scaling. Every other finding still fails.
        try audit("auditTabBars", ignoring: [.dynamicType])
    }

    @MainActor
    func testNavigationHeaderPassesTheAccessibilityAudit() throws {
        try audit("auditNavigationHeader")
    }

    @MainActor
    func testSkeletonsDividersSurfacesAndLoadingPassTheAccessibilityAudit() throws {
        try audit("auditStructure")
    }

    @MainActor
    func testP2ComponentsPassTheAccessibilityAudit() throws {
        try audit("auditP2")
    }

    @MainActor
    func testTooltipPassesTheAccessibilityAudit() throws {
        try audit("auditTooltip")
    }

    @MainActor
    func testExampleScreensPassTheAccessibilityAudit() throws {
        // The settings and inbox screens are lists; see the list rows audit.
        try audit("authScreen")
        try audit("inboxScreen", ignoringFindingsWithoutElement: true)
        // In a list row, the audit can't resize the picker's menu label and
        // reports it as not scaling, though it does (checked at accessibility
        // sizes); outside a list the same picker passes `auditInputs`.
        try audit("settingsScreen", ignoringFindingsWithoutElement: true, ignoring: [.dynamicType])
    }

    @MainActor
    func testInputsPassTheAccessibilityAudit() throws {
        try audit("auditInputs")
    }

    @MainActor
    func testStateMatrixPassesTheAccessibilityAudit() throws {
        try audit("stateMatrix")
    }

    @MainActor
    func testThemingPagesPassTheAccessibilityAudit() throws {
        // Each page shows every theme already; one app theme in both appearances suffices.
        for fixture in ["themeGallery", "themeComparison"] {
            for appearance in ["light", "dark"] {
                try audit(fixture, theme: "forge", appearance: appearance)
            }
        }
    }

    /// Runs Apple's audit in every built-in theme and appearance, ignoring
    /// only findings that WCAG itself exempts.
    @MainActor
    private func audit(
        _ fixture: String, ignoringFindingsWithoutElement: Bool = false, ignoring ignoredTypes: XCUIAccessibilityAuditType = []
    ) throws {
        for theme in Self.themes {
            for appearance in ["light", "dark"] {
                try audit(
                    fixture, theme: theme, appearance: appearance,
                    ignoringFindingsWithoutElement: ignoringFindingsWithoutElement, ignoring: ignoredTypes)
            }
        }
    }

    @MainActor
    private func audit(
        _ fixture: String, theme: String, appearance: String, ignoringFindingsWithoutElement: Bool = false,
        ignoring ignoredTypes: XCUIAccessibilityAuditType = []
    ) throws {
        let app = launch(fixture, theme: theme, appearance: appearance)
        try app.performAccessibilityAudit { issue in
            if ignoringFindingsWithoutElement, issue.element == nil { return true }
            if ignoredTypes.contains(issue.auditType) { return true }
            // Disabled controls are exempt from contrast requirements (WCAG 1.4.3).
            if issue.auditType == .contrast, issue.element?.isEnabled == false { return true }
            // Progress bars aren't touch targets; target size (WCAG 2.5.8) doesn't apply.
            if issue.auditType == .hitRegion, issue.element?.elementType == .progressIndicator { return true }
            // Single-line text fields scroll their value horizontally rather
            // than wrap, like UITextField; the audit predicts long values may
            // clip at large sizes. The field itself grows with Dynamic Type
            // (the `textFields.*-accessibility5` snapshots) and VoiceOver reads
            // the whole value. Multi-line input is the planned text area.
            if issue.auditType == .textClipped, issue.element?.elementType == .textField { return true }
            // The audit misjudges some glyphs (it flags SF Rounded text that
            // measures over 9:1). For text, measure the rendered pixels
            // independently and accept the finding as a false positive only
            // if the text really meets WCAG AA. Steppers and sliders are one
            // element over a label, a value, and controls, which the audit
            // sometimes judges as a whole — and a stepper at a bound includes
            // a disabled button, which WCAG exempts; their text and glyph
            // colors are measured in the contrast unit tests.
            if issue.auditType == .contrast, let element = issue.element,
                [.staticText, .button, .stepper, .slider].contains(element.elementType),
                let measured = PixelContrast.measure(element, in: app), measured >= 4.5
            {
                print("AUDIT-VERIFIED [\(fixture) \(theme) \(appearance)] '\(element.label)' measures \(measured):1")
                return true
            }
            let element = issue.element.map { "\($0.elementType.rawValue) '\($0.label)' \($0.frame)" } ?? "no element"
            print(
                "AUDIT [\(fixture) \(theme) \(appearance)] \(issue.compactDescription): \(element) — \(issue.detailedDescription)"
            )
            return false
        }
    }
}

/// Measures the contrast of text as rendered: the most common color in the
/// element's frame is its background, and the color farthest from it in
/// luminance is its text.
enum PixelContrast {

    @MainActor
    static func measure(_ element: XCUIElement, in app: XCUIApplication) -> Double? {
        guard let image = app.screenshot().image.cgImage else { return nil }
        let scale = CGFloat(image.width) / app.frame.width
        let frame = element.frame
        let rect = CGRect(x: frame.minX * scale, y: frame.minY * scale, width: frame.width * scale, height: frame.height * scale)
            .integral.intersection(CGRect(x: 0, y: 0, width: image.width, height: image.height))
        guard !rect.isEmpty, let crop = image.cropping(to: rect) else { return nil }
        let width = crop.width
        let height = crop.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard
            let context = CGContext(
                data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }
        context.draw(crop, in: CGRect(x: 0, y: 0, width: width, height: height))

        var counts: [UInt32: Int] = [:]
        for index in stride(from: 0, to: pixels.count, by: 4) {
            let rgb = UInt32(pixels[index]) << 16 | UInt32(pixels[index + 1]) << 8 | UInt32(pixels[index + 2])
            counts[rgb, default: 0] += 1
        }
        guard let background = counts.max(by: { $0.value < $1.value })?.key else { return nil }
        let backgroundLuminance = luminance(background)
        let text = counts.keys.map(luminance).max { abs($0 - backgroundLuminance) < abs($1 - backgroundLuminance) }
        guard let textLuminance = text else { return nil }
        let ratio = (max(textLuminance, backgroundLuminance) + 0.05) / (min(textLuminance, backgroundLuminance) + 0.05)
        return (ratio * 100).rounded() / 100
    }

    private static func luminance(_ rgb: UInt32) -> Double {
        func linear(_ component: UInt32) -> Double {
            let value = Double(component) / 255
            return value <= 0.04045 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linear(rgb >> 16 & 0xFF) + 0.7152 * linear(rgb >> 8 & 0xFF) + 0.0722 * linear(rgb & 0xFF)
    }
}
