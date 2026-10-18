//
//  ScrollPerformanceTests.swift
//  UITests
//
//  The 500-row stress page (cards, list rows with avatars, chips, ratings,
//  steppers, toggles, and shimmering skeletons) scrolls itself to the end
//  and back while a display link measures main-thread hitches, per
//  ADR-0009. The same page built from native controls is the baseline.
//
//  The test stays idle while the page scrolls: each XCUITest query
//  snapshots the app's accessibility tree on the main thread, which would
//  itself cause hitches. Simulator hitches vary too much run to run to gate
//  a build, so this is a measurement, run on demand in Release:
//
//    TEST_RUNNER_SWIFTFORGE_PERF=1 xcodebuild test -configuration Release \
//      ENABLE_TESTABILITY=YES -only-testing:UITests/ScrollPerformanceTests …
//
//  The < 5 ms/s budget is for an iPhone 12-class device, measured with
//  Instruments.
//

import XCTest

final class ScrollPerformanceTests: XCTestCase {

    override func setUpWithError() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["SWIFTFORGE_PERF"] == "1",
            "Set TEST_RUNNER_SWIFTFORGE_PERF=1 to measure scrolling performance.")
    }

    @MainActor
    private func report(_ fixture: String, kind: Int?) -> String {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTestFixture", fixture] + (kind.map { ["-stressKind", "\($0)"] } ?? [])
        app.launch()
        // Two passes, each 1 s of settling and 12 s of scrolling.
        Thread.sleep(forTimeInterval: 30)
        let report = app.staticTexts["frames"].label
        app.terminate()
        return report
    }

    @MainActor
    func testScrollingTheStressPage() {
        // nil mixes every kind of row: 0 cards, 1 list rows with avatars,
        // 2 chip groups, 3 ratings, steppers, and toggles.
        for kind in [nil, 0, 1, 2, 3] as [Int?] {
            let rows = kind.map { "kind \($0)" } ?? "mixed"
            print("PERF [\(rows)] native     \(report("stressNative", kind: kind))")
            print("PERF [\(rows)] SwiftForge \(report("stress", kind: kind))")
        }
    }
}
