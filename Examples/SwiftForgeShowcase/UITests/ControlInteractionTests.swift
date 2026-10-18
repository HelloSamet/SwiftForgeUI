//
//  ControlInteractionTests.swift
//  UITests
//
//  Taps, adjustments, and VoiceOver semantics of the selection and input
//  controls, against the `controls` fixture, whose state is mirrored in a
//  label.
//

import XCTest

final class ControlInteractionTests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func launch() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", "controls"]
        app.launch()
        return app
    }

    @MainActor
    private func state(_ app: XCUIApplication) -> String {
        app.staticTexts["state"].label
    }

    @MainActor
    private func element(_ app: XCUIApplication, _ label: String) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    // MARK: Checkbox

    @MainActor
    func testCheckboxReadsItsStateAndToggles() {
        let app = launch()
        let terms = element(app, "Terms")
        // Toggles report off, on, and mixed as 0, 1, and 2; VoiceOver speaks them.
        XCTAssertEqual(terms.value as? String, "0")
        terms.tap()
        XCTAssertEqual(terms.value as? String, "1")
        XCTAssertTrue(state(app).contains("terms:true"))
    }

    @MainActor
    func testMixedCheckboxTurnsEverythingOn() {
        let app = launch()
        let all = element(app, "All toppings")
        XCTAssertEqual(all.value as? String, "2")
        all.tap()
        XCTAssertTrue(state(app).contains("toppings:11"))
        XCTAssertEqual(all.value as? String, "1")
    }

    // MARK: Radio group and segmented control

    @MainActor
    func testRadioOptionsReadSelectionAndPosition() {
        let app = launch()
        let express = app.buttons["Express"]
        XCTAssertEqual(express.value as? String, "2 of 3")
        XCTAssertFalse(express.isSelected)
        express.tap()
        XCTAssertTrue(express.isSelected)
        XCTAssertTrue(state(app).contains("delivery:Express"))
    }

    @MainActor
    func testSegmentsReadSelectionAndPosition() {
        let app = launch()
        let month = app.buttons["Month"]
        XCTAssertEqual(month.value as? String, "3 of 3")
        month.tap()
        XCTAssertTrue(month.isSelected)
        XCTAssertTrue(state(app).contains("period:Month"))
    }

    // MARK: Chips

    @MainActor
    func testChipsToggleAndRemove() {
        let app = launch()
        let thai = element(app, "Thai")
        thai.tap()
        XCTAssertTrue(thai.isSelected)
        XCTAssertTrue(state(app).contains("cuisines:Thai"))

        let remove = app.buttons["Remove Ada Lovelace"]
        XCTAssertTrue(remove.exists)
        remove.tap()
        XCTAssertTrue(state(app).contains("recipients:1"))
    }

    // MARK: Sliders

    @MainActor
    func testSliderIsAStandardAdjustableSlider() {
        let app = launch()
        let volume = app.sliders["Volume"]
        XCTAssertTrue(volume.exists)
        XCTAssertEqual(volume.value as? String, "40")
        // The slider is drawn by SwiftUI, so drag its thumb rather than
        // using `adjust(toNormalizedSliderPosition:)`, which needs UIKit's
        // scrubber geometry. The thumb (24 pt) sits at 40% of the track,
        // whose 44-pt hit area is the element's bottom edge.
        let frame = volume.frame
        func point(_ fraction: CGFloat) -> XCUICoordinate {
            app.coordinate(withNormalizedOffset: .zero).withOffset(
                CGVector(dx: frame.minX + 12 + fraction * (frame.width - 24), dy: frame.maxY - 22))
        }
        point(0.4).press(forDuration: 0.1, thenDragTo: point(0.8))
        XCTAssertTrue(state(app).contains("volume:80"), state(app))
    }

    @MainActor
    func testRangeSliderThumbsAreSeparateElementsThatDrag() {
        let app = launch()
        let minimum = element(app, "Price, Minimum")
        let maximum = element(app, "Price, Maximum")
        XCTAssertTrue(minimum.exists && maximum.exists)
        XCTAssertEqual(minimum.value as? String, "100")
        XCTAssertEqual(maximum.value as? String, "300")
        // Thumbs keep a 44-pt hit area.
        XCTAssertGreaterThanOrEqual(minimum.frame.width, 44)

        // Dragging the lower thumb right moves only the lower bound.
        let start = minimum.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 60, dy: 0)))
        XCTAssertTrue(state(app).contains("-300"), state(app))
        XCTAssertFalse(state(app).contains("price:100-"), state(app))
    }

    // MARK: Search and picker

    @MainActor
    func testSearchRunsAfterTypingPauses() {
        let app = launch()
        let field = app.searchFields["Search"]
        XCTAssertTrue(field.exists)
        field.tap()
        field.typeText("ada")
        let searched = NSPredicate(format: "label CONTAINS 'searched:ada'")
        expectation(for: searched, evaluatedWith: app.staticTexts["state"])
        waitForExpectations(timeout: 3)
    }

    @MainActor
    func testPickerReadsTheChoiceAsItsValue() {
        let app = launch()
        // XCUITest also lists the field's visible label, which VoiceOver skips.
        let picker = app.buttons["Country"]
        XCTAssertEqual(picker.value as? String, "Japan")
        picker.tap()
        app.buttons["Türkiye"].tap()
        XCTAssertTrue(state(app).contains("country:Türkiye"))
    }
}
