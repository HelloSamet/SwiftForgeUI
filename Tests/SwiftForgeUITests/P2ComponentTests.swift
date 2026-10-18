import SwiftUI
import Testing

@testable import SwiftForgeUI

/// Logic and layout of the P2 components. Visuals are in the hosted
/// `P2SnapshotTests`; VoiceOver adjustment and taps in the UI tests.
@MainActor
@Suite("P2 components")
struct P2ComponentTests {

    @Test(
        "One-time codes keep only digits, up to the length",
        arguments: [
            ("12a3", 6, "123"), ("1234567", 6, "123456"), ("12 34-56", 6, "123456"), ("", 4, ""), ("٣٤٥", 4, "٣٤٥"),
        ] as [(String, Int, String)]
    )
    func otpSanitizing(input: String, length: Int, expected: String) {
        #expect(SwiftForgeOTPField.sanitized(input, length: length) == expected)
    }

    @Test(
        "Stars round to the nearest half",
        arguments: [
            (4.5, ["star.fill", "star.fill", "star.fill", "star.fill", "star.leadinghalf.filled"]),
            (2.2, ["star.fill", "star.fill", "star", "star", "star"]),
            (2.3, ["star.fill", "star.fill", "star.leadinghalf.filled", "star", "star"]),
            (0, ["star", "star", "star", "star", "star"]),
        ] as [(Double, [String])]
    )
    func starSymbols(value: Double, expected: [String]) {
        #expect((0..<5).map { SwiftForgeRating.symbol(for: value, at: $0) } == expected)
    }

    @Test("Interactive stars keep a 44-pt hit area; read-only stars follow the text")
    func ratingHitArea() {
        let interactive = RenderedView(SwiftForgeRating("Rating", value: .constant(3)))
        #expect(interactive.size.height >= 44)
        #expect(interactive.size.width >= 5 * 44)
        let readOnly = RenderedView(SwiftForgeRating(value: 3))
        #expect(readOnly.size.height < 44)
    }

    @Test("A stepper row is at least 44 pt tall")
    func stepperHeight() {
        let rendered = RenderedView(
            SwiftForgeStepper("Guests", value: .constant(2), in: 1...5) { Text($0, format: .number) }, width: 300)
        #expect(rendered.size.height >= 44)
    }

    @Test("An accordion's header is at least 44 pt tall and its content shows only when expanded")
    func accordion() {
        func height(_ isExpanded: Bool) -> CGFloat {
            RenderedView(
                DisclosureGroup("Shipping", isExpanded: .constant(isExpanded)) {
                    Color.clear.frame(height: 100)
                }
                .disclosureGroupStyle(.swiftForge),
                width: 300
            ).size.height
        }
        #expect(height(false) >= 44)
        #expect(height(true) >= height(false) + 100)
    }
}
