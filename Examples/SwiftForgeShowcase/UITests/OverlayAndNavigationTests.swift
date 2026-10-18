//
//  OverlayAndNavigationTests.swift
//  UITests
//
//  Toast timing, dialog blocking and actions, tab selection, and the
//  navigation header, against the `overlays` and `navigation` fixtures.
//

import XCTest

final class OverlayAndNavigationTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ fixture: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", fixture]
        app.launch()
        return app
    }

    @MainActor
    private func waitUntilGone(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: element)
        return XCTWaiter().wait(for: [gone], timeout: timeout) == .completed
    }

    // MARK: Toasts

    @MainActor
    func testToastAppearsAndLeavesOnItsOwn() {
        let app = launch("overlays")
        app.buttons["Show toast"].tap()
        let toast = app.staticTexts["Message sent"]
        XCTAssertTrue(toast.waitForExistence(timeout: 2))
        XCTAssertTrue(waitUntilGone(toast, timeout: 8))
    }

    @MainActor
    func testToastWithAnActionStaysUntilUsed() {
        let app = launch("overlays")
        app.buttons["Show undo toast"].tap()
        let toast = app.staticTexts["Conversation archived"]
        XCTAssertTrue(toast.waitForExistence(timeout: 2))
        // Longer than a short toast's 4 seconds.
        Thread.sleep(forTimeInterval: 6)
        XCTAssertTrue(toast.exists)
        app.buttons["Undo"].tap()
        XCTAssertTrue(waitUntilGone(toast, timeout: 2))
        XCTAssertEqual(app.staticTexts["log"].label, "undo:1 deleted:0 canceled:0")
    }

    // MARK: Dialog

    @MainActor
    func testTappingOutsideTheDialogCancelsItWithoutReachingTheContent() {
        let app = launch("overlays")
        let frame = app.buttons["Show toast"].frame
        app.buttons["Show dialog"].tap()
        XCTAssertTrue(app.staticTexts["Delete this draft?"].waitForExistence(timeout: 2))

        // A tap where the content's button is lands on the scrim: it runs the
        // cancel action, and the button behind never sees it.
        app.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: frame.midX, dy: frame.midY)).tap()
        XCTAssertTrue(waitUntilGone(app.staticTexts["Delete this draft?"], timeout: 2))
        XCTAssertEqual(app.staticTexts["log"].label, "undo:0 deleted:0 canceled:1")
        XCTAssertFalse(app.staticTexts["Message sent"].exists)
    }

    @MainActor
    func testCancelButtonClosesTheDialog() {
        let app = launch("overlays")
        app.buttons["Show dialog"].tap()
        app.buttons["Cancel"].tap()
        XCTAssertTrue(waitUntilGone(app.staticTexts["Delete this draft?"], timeout: 2))
        XCTAssertEqual(app.staticTexts["log"].label, "undo:0 deleted:0 canceled:1")
    }

    @MainActor
    func testDestructiveActionRunsAfterTheDialogCloses() {
        let app = launch("overlays")
        app.buttons["Show dialog"].tap()
        app.buttons["Delete"].tap()
        XCTAssertTrue(waitUntilGone(app.staticTexts["Delete this draft?"], timeout: 2))
        XCTAssertEqual(app.staticTexts["log"].label, "undo:0 deleted:1 canceled:0")
    }

    // MARK: Navigation

    @MainActor
    func testTabsReadBadgeAndPositionAndSelect() {
        let app = launch("navigation")
        let inbox = app.buttons["Inbox"]
        XCTAssertTrue(inbox.isSelected)
        XCTAssertEqual(inbox.value as? String, "3 new items, 1 of 3")
        app.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["Profile"].isSelected)
        XCTAssertEqual(app.staticTexts["tab"].label, "tab:profile")
    }

    @MainActor
    func testHeaderSetsTheNavigationTitle() {
        let app = launch("navigation")
        XCTAssertTrue(app.navigationBars["Inbox"].exists)
        XCTAssertTrue(app.staticTexts["12 unread"].exists)
    }
}
