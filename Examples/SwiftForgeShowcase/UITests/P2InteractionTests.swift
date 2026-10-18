//
//  P2InteractionTests.swift
//  UITests
//
//  The stepper, one-time code field, rating, accordion, bottom sheet, and tooltip,
//  against the `p2` fixture, and smoke tests of the example screens.
//

import XCTest

final class P2InteractionTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch(_ fixture: String = "p2") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", fixture]
        app.launch()
        return app
    }

    @MainActor
    private func state(_ app: XCUIApplication) -> String {
        app.staticTexts["state"].label
    }

    /// A point inside an element, `dx` points from its leading or trailing edge.
    @MainActor
    private func point(in element: XCUIElement, fromTrailing dx: CGFloat) -> XCUICoordinate {
        element.coordinate(withNormalizedOffset: CGVector(dx: 1, dy: 0.5)).withOffset(CGVector(dx: -dx, dy: 0))
    }

    // MARK: Stepper

    @MainActor
    func testStepperIsOneAdjustableElementWithItsValue() {
        let app = launch()
        let guests = app.steppers["Guests"]
        XCTAssertTrue(guests.exists)
        XCTAssertEqual(guests.value as? String, "2")
        XCTAssertGreaterThanOrEqual(guests.frame.height, 44)
        // The trailing button is +, the one before it −.
        point(in: guests, fromTrailing: 22).tap()
        XCTAssertTrue(state(app).contains("guests:3"), state(app))
        XCTAssertEqual(guests.value as? String, "3")
    }

    @MainActor
    func testHoldingAStepperButtonRepeats() {
        let app = launch()
        point(in: app.steppers["Guests"], fromTrailing: 22).press(forDuration: 2)
        // A tap alone would make it 3; holding keeps going, up to the 12 maximum.
        let guests = Int(state(app).split(separator: " ")[0].dropFirst("guests:".count)) ?? 0
        XCTAssertGreaterThan(guests, 4, state(app))
        XCTAssertLessThanOrEqual(guests, 12)
    }

    // MARK: One-time code

    @MainActor
    func testCodeFieldIsOneElementThatKeepsOnlyDigits() {
        let app = launch()
        let field = app.textFields["Verification code"]
        XCTAssertTrue(field.exists)
        XCTAssertEqual(field.value as? String, "0 of 6 digits entered")
        // The field covers the boxes, and no more.
        XCTAssertLessThan(field.frame.height, 100)
        field.tap()
        field.typeText("12a34567")
        XCTAssertTrue(state(app).contains("code:123456 "), state(app))
        XCTAssertEqual(field.value as? String, "6 of 6 digits entered")
    }

    // MARK: Rating

    @MainActor
    func testRatingReadsItsValueAndSetsItByTap() {
        let app = launch()
        let rating = app.otherElements["Your rating"]
        XCTAssertTrue(rating.exists)
        XCTAssertEqual(rating.value as? String, "3 of 5 stars")
        XCTAssertGreaterThanOrEqual(rating.frame.height, 44)
        // Each star is a 44-pt cell; the last one is the trailing cell.
        point(in: rating, fromTrailing: 22).tap()
        XCTAssertTrue(state(app).contains("stars:5"), state(app))
        XCTAssertEqual(rating.value as? String, "5 of 5 stars")
    }

    // MARK: Accordion

    @MainActor
    func testAccordionHeaderIsAButtonWithItsState() {
        let app = launch()
        let header = app.buttons["Shipping"]
        XCTAssertEqual(header.value as? String, "Collapsed")
        XCTAssertFalse(app.staticTexts["Ships in two days."].exists)
        header.tap()
        XCTAssertTrue(app.staticTexts["Ships in two days."].waitForExistence(timeout: 2))
        XCTAssertEqual(header.value as? String, "Expanded")
        XCTAssertTrue(state(app).contains("expanded:true"))
    }

    // MARK: Bottom sheet

    @MainActor
    func testBottomSheetOpensAndSwipesAway() {
        let app = launch()
        app.buttons["Open sheet"].tap()
        let content = app.staticTexts["Sheet content"]
        XCTAssertTrue(content.waitForExistence(timeout: 2))
        // Drag the sheet down from its top edge, past the bottom of the screen.
        let top = content.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0)).withOffset(CGVector(dx: 0, dy: -20))
        top.press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1)))
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: content)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: 3), .completed)
    }

    // MARK: Tooltip

    @MainActor
    func testTooltipOpensAsAPopoverAndClosesOnATapOutside() {
        let app = launch()
        let text = app.staticTexts["A 2% fee applies to card payments."]
        XCTAssertFalse(text.exists)
        app.buttons["About fees"].tap()
        XCTAssertTrue(text.waitForExistence(timeout: 2))
        // On an iPhone, a sheet would cover the screen's width; the popover stays narrower.
        XCTAssertLessThan(text.frame.width, app.frame.width - 32)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95)).tap()
        let gone = expectation(for: NSPredicate(format: "exists == false"), evaluatedWith: text)
        XCTAssertEqual(XCTWaiter().wait(for: [gone], timeout: 3), .completed)
    }

    // MARK: Example screens

    @MainActor
    func testSignInScreenSwitchesToSignUp() {
        let app = launch("authScreen")
        XCTAssertTrue(app.textFields["Email"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.secureTextFields["Password"].exists)
        XCTAssertFalse(app.switches["I agree to the Terms of Service"].exists)
        app.buttons["Create Account"].firstMatch.tap()
        XCTAssertTrue(app.switches["I agree to the Terms of Service"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSettingsScreenShowsItsControls() {
        let app = launch("settingsScreen")
        XCTAssertTrue(app.switches["Notifications"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.steppers["Backups to keep"].exists)
        XCTAssertTrue(app.sliders["Text size"].exists)
    }

    @MainActor
    func testInboxFiltersAndOpensAMessage() {
        let app = launch("inboxScreen")
        XCTAssertTrue(app.staticTexts["Alan Turing"].waitForExistence(timeout: 3))
        let unread = app.descendants(matching: .any).matching(identifier: "Unread").firstMatch
        unread.tap()
        XCTAssertTrue(unread.isSelected)
        XCTAssertFalse(app.staticTexts["Alan Turing"].exists)
        app.staticTexts["Grace Hopper"].tap()
        XCTAssertTrue(app.textFields["Reply"].waitForExistence(timeout: 2))
        XCTAssertFalse(app.buttons["Send"].isEnabled)
    }
}
