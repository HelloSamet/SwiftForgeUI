//
//  InteractionTests.swift
//  UITests
//
//  Behavior that only a real tap can verify: SwiftUI offers no way to
//  simulate a button press in a unit test.
//

import XCTest

final class ButtonInteractionTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", "buttons"]
        app.launch()
        return app
    }

    @MainActor
    func testLoadingAndDisabledButtonsIgnoreTaps() {
        let app = launch()
        app.buttons["normal"].tap()
        app.buttons["loading"].tap()
        app.buttons["disabled"].tap()
        XCTAssertEqual(app.staticTexts["counts"].label, "normal:1 loading:0 disabled:0 async:0")
    }

    @MainActor
    func testLoadingButtonIsAnnouncedAsLoading() {
        let app = launch()
        let loading = app.buttons["loading"]
        XCTAssertEqual(loading.value as? String, "Loading")
        XCTAssertFalse(loading.isEnabled)
    }

    @MainActor
    func testAsyncButtonRunsItsActionOnceWhileInFlight() {
        let app = launch()
        let button = app.buttons["async"]
        button.tap()
        button.tap()
        button.tap()
        let counts = app.staticTexts["counts"]
        XCTAssertEqual(counts.label, "normal:0 loading:0 disabled:0 async:1")
        // After the action finishes, the button accepts taps again.
        let enabled = NSPredicate(format: "isEnabled == true")
        expectation(for: enabled, evaluatedWith: button)
        waitForExpectations(timeout: 3)
        button.tap()
        XCTAssertEqual(counts.label, "normal:0 loading:0 disabled:0 async:2")
    }

    @MainActor
    func testSmallButtonsKeepTheMinimumHitArea() {
        let app = launch()
        let frame = app.buttons["small"].frame
        XCTAssertGreaterThanOrEqual(frame.height, 44)
        XCTAssertGreaterThanOrEqual(frame.width, 44)
    }
}

final class FieldInteractionTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", "fields"]
        app.launch()
        return app
    }

    @MainActor
    func testTextFieldIsFoundByItsVisibleLabel() {
        let app = launch()
        XCTAssertTrue(app.textFields["Email"].exists)
        XCTAssertTrue(app.secureTextFields["Password"].exists)
    }

    @MainActor
    func testFieldsWithoutAPromptDontRepeatTheirLabel() {
        let app = launch()
        // The label is shown above the field; SwiftUI would otherwise repeat it as the placeholder.
        XCTAssertEqual(app.textFields["Email"].placeholderValue ?? "", "")
        XCTAssertEqual(app.secureTextFields["Password"].placeholderValue ?? "", "")
    }

    @MainActor
    func testRevealingThePasswordKeepsTextAndFocus() {
        let app = launch()
        let secure = app.secureTextFields["Password"]
        secure.tap()
        secure.typeText("hunter22")

        app.buttons["Show password"].tap()
        let plain = app.textFields["Password"]
        XCTAssertTrue(plain.waitForExistence(timeout: 2))
        XCTAssertEqual(plain.value as? String, "hunter22")

        // Typing continues in the same field without tapping it again.
        app.typeText("!")
        XCTAssertEqual(app.staticTexts["passwordEcho"].label, "hunter22!")

        app.buttons["Hide password"].tap()
        XCTAssertTrue(app.secureTextFields["Password"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testCharacterLimitTruncatesInput() {
        let app = launch()
        let code = app.textFields["Code"]
        code.tap()
        code.typeText("12345678")
        XCTAssertEqual(code.value as? String, "123456")
    }
}

final class ToggleInteractionTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testTappingTheRowTogglesAndDisabledTogglesIgnoreTaps() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", "toggles"]
        app.launch()

        let wifi = app.switches["Wi-Fi"]
        wifi.tap()
        XCTAssertEqual(wifi.value as? String, "1")
        app.switches["Locked"].tap()
        XCTAssertEqual(app.staticTexts["state"].label, "wifi:true locked:false")

        wifi.tap()
        XCTAssertEqual(app.staticTexts["state"].label, "wifi:false locked:false")
    }
}
