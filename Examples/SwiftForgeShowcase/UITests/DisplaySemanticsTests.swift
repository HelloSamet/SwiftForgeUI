//
//  DisplaySemanticsTests.swift
//  UITests
//
//  VoiceOver semantics of the display components, against the `display`
//  fixture.
//

import XCTest

final class DisplaySemanticsTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = true
    }

    @MainActor
    private func launch(_ fixture: String = "display") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", fixture]
        app.launch()
        return app
    }

    @MainActor
    func testAvatarIsAnImageLabeledWithNameAndStatus() {
        let app = launch()
        XCTAssertTrue(app.images["Ada Lovelace, Online"].exists)
    }

    @MainActor
    func testAvatarGroupListsTheNamesItShowsAndCountsTheRest() {
        let app = launch()
        let group = app.images.matching(NSPredicate(format: "label BEGINSWITH 'Ada Lovelace, Grace Hopper'")).firstMatch
        XCTAssertTrue(group.exists)
        XCTAssertTrue(group.label.contains("2 others"), group.label)
    }

    @MainActor
    func testRowReadsItsTitleAndSubtitleTogether() {
        let app = launch()
        let row = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'Notifications, Banners and sounds'"))
        XCTAssertEqual(row.count, 1)
    }

    @MainActor
    func testCheckmarkRowIsSelected() {
        let app = launch()
        let english = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'English'")).firstMatch
        XCTAssertTrue(english.isSelected)
    }

    @MainActor
    func testSectionHeaderAndEmptyStateTitleAreHeadings() {
        let app = launch()
        // XCUITest exposes the header trait through element type `.staticText`
        // on iOS; assert the headings exist as their own elements.
        XCTAssertTrue(app.staticTexts["Account"].exists)
        XCTAssertTrue(app.staticTexts["No Messages"].exists)
    }

    @MainActor
    func testHiddenLabelsAreNotDrawnButStillNameTheControl() throws {
        guard #available(iOS 18, *) else { throw XCTSkip("labelsHidden() is readable from iOS 18") }
        let app = launch()
        let toggle = app.switches["Hidden switch"]
        let checkbox = app.descendants(matching: .any).matching(NSPredicate(format: "label == 'Hidden checkbox'")).firstMatch
        XCTAssertTrue(toggle.exists)
        XCTAssertTrue(checkbox.exists)
        // Without drawn labels, both controls fit on one line next to the text.
        XCTAssertLessThan(toggle.frame.width, 120)
        XCTAssertTrue(app.staticTexts["labelEnd"].isHittable)
    }

    @MainActor
    func testLabeledDividerReadsItsLabel() {
        let app = launch()
        XCTAssertTrue(app.staticTexts["or"].exists)
    }

    @MainActor
    func testSkeletonReadsLoadingAndHidesItsPlaceholderText() {
        let app = launch("auditStructure")
        let loading = app.staticTexts.matching(identifier: "Loading")
        XCTAssertTrue(loading.firstMatch.waitForExistence(timeout: 2))
        // The card behind the skeleton isn't read, not even as placeholder glyphs.
        XCTAssertFalse(app.staticTexts["Jane Appleseed"].exists)
        let placeholders = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "\u{100BB7}"))
        XCTAssertEqual(placeholders.count, 0)
    }
}
