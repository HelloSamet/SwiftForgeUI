import SwiftUI
import Testing

@testable import SwiftForgeUI

private struct Note: Identifiable, Equatable {
    let id: Int
}

@Suite("Presentation queue")
struct PresentationQueueTests {

    @Test("The first item shows at once; later ones wait in order")
    func fifo() {
        var queue = SwiftForgePresentationQueue<Note>()
        #expect(queue.isEmpty)
        queue.enqueue(Note(id: 1))
        queue.enqueue(Note(id: 2))
        queue.enqueue(Note(id: 3))
        #expect(queue.current == Note(id: 1))
        #expect(queue.pending == [Note(id: 2), Note(id: 3)])

        queue.dismiss(id: 1)
        #expect(queue.current == Note(id: 2))
        queue.dismiss(id: 2)
        queue.dismiss(id: 3)
        #expect(queue.isEmpty)
    }

    @Test("Repeating an item that's shown or waiting doesn't stack a copy")
    func deduplicates() {
        var queue = SwiftForgePresentationQueue<Note>()
        queue.enqueue(Note(id: 1))
        queue.enqueue(Note(id: 2))
        queue.enqueue(Note(id: 1))
        queue.enqueue(Note(id: 2))
        #expect(queue.pending == [Note(id: 2)])
    }

    @Test("Dismissing a waiting item removes it without touching the current one")
    func dismissPending() {
        var queue = SwiftForgePresentationQueue<Note>()
        [1, 2, 3].forEach { queue.enqueue(Note(id: $0)) }
        let dismissedWaiting = queue.dismiss(id: 2)
        #expect(dismissedWaiting)
        #expect(queue.current == Note(id: 1))
        #expect(queue.pending == [Note(id: 3)])
        let dismissedUnknown = queue.dismiss(id: 42)
        #expect(!dismissedUnknown)
    }

    @Test("Dismissing everything empties the queue")
    func dismissAll() {
        var queue = SwiftForgePresentationQueue<Note>()
        [1, 2].forEach { queue.enqueue(Note(id: $0)) }
        queue.dismissAll()
        #expect(queue.isEmpty)
    }

    @Test("Presentations time out unless they stay or offer an action; VoiceOver doubles the time")
    func timing() {
        let four = Duration.seconds(4)
        #expect(
            SwiftForgePresentationTiming.autoDismissDelay(duration: four, hasAction: false, isVoiceOverRunning: false) == four)
        #expect(
            SwiftForgePresentationTiming.autoDismissDelay(duration: four, hasAction: false, isVoiceOverRunning: true)
                == .seconds(8))
        #expect(SwiftForgePresentationTiming.autoDismissDelay(duration: four, hasAction: true, isVoiceOverRunning: false) == nil)
        #expect(SwiftForgePresentationTiming.autoDismissDelay(duration: nil, hasAction: false, isVoiceOverRunning: false) == nil)
    }
}

@MainActor
@Suite("Overlay layer")
struct OverlayLayerTests {

    private let theme = SwiftForgeTheme.forge
    private let marker = Color(red: 1, green: 0, blue: 0)

    private func screen(_ item: Note?, kind: SwiftForgeOverlayKind) -> some View {
        Color.black
            .frame(width: 200, height: 200)
            .swiftForgeOverlayLayer(item, kind: kind) { _ in
                marker.frame(width: 40, height: 40)
            }
    }

    private func isMarker(_ pixel: (red: Int, green: Int, blue: Int, alpha: Int)) -> Bool {
        pixel.red > 200 && pixel.green < 60 && pixel.blue < 60
    }

    @Test("Without an item, the content is untouched")
    func empty() {
        let rendered = RenderedView(screen(nil, kind: .modal))
        #expect(rendered.matches(x: 100, y: 100, hex: 0x000000))
        #expect(rendered.matches(x: 5, y: 5, hex: 0x000000))
    }

    // ImageRenderer doesn't draw views with `accessibilityFocused(_:)`, which
    // the modal layer uses to move VoiceOver into the dialog; the dialog's
    // content is verified by the hosted snapshot tests.
    @Test("A modal item covers the content with a scrim")
    func modal() {
        let rendered = RenderedView(screen(Note(id: 1), kind: .modal))
        // The light canvas scrim lifts the black content everywhere.
        #expect(rendered.color(x: 5, y: 5).red > 100)
        #expect(rendered.color(x: 100, y: 100).red > 100)
    }

    @Test("A transient item sits at its edge, inside the screen inset, without a scrim")
    func transient() {
        let rendered = RenderedView(screen(Note(id: 1), kind: .transient(edge: .bottom)))
        let inset = Int(theme.spacing.screenHorizontal)
        #expect(isMarker(rendered.color(x: 100, y: 200 - inset - 20)))
        #expect(!isMarker(rendered.color(x: 100, y: 100)))
        #expect(rendered.matches(x: 5, y: 5, hex: 0x000000))
    }

    @Test("Reduce Transparency makes the scrim nearly opaque")
    func reducedTransparencyScrim() {
        func corner(_ reduced: Bool) -> Int {
            RenderedView(
                screen(Note(id: 1), kind: .modal).swiftForgeAccessibilitySimulation(reduceTransparency: reduced)
            ).color(x: 5, y: 5).red
        }
        #expect(corner(true) > corner(false))
    }
}
