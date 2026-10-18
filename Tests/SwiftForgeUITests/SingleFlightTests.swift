import Testing

@testable import SwiftForgeUI

/// An operation that waits until it's opened, ignoring cancellation the way
/// a network call that doesn't check for it would.
@MainActor
private final class Gate {
    private var continuation: CheckedContinuation<Void, Never>?
    private(set) var runs = 0
    private(set) var sawCancellation = false

    func operation() async {
        runs += 1
        await withCheckedContinuation { continuation = $0 }
        sawCancellation = Task.isCancelled
    }

    func open() {
        continuation?.resume()
        continuation = nil
    }

    var isWaiting: Bool { continuation != nil }
}

/// Lets other main-actor work run until `condition` holds.
@MainActor
private func waitUntil(_ condition: () -> Bool) async {
    for _ in 0..<1_000 where !condition() {
        await Task.yield()
    }
}

@MainActor
@Suite("Async button runs")
struct SingleFlightTests {

    @Test("A second tap while the action runs doesn't start it again")
    func ignoresRepeats() async {
        let flight = SwiftForgeSingleFlight()
        let gate = Gate()
        #expect(flight.run(gate.operation))
        #expect(!flight.run(gate.operation))
        await waitUntil { gate.isWaiting }
        #expect(gate.runs == 1)
        #expect(flight.isRunning)

        gate.open()
        await waitUntil { !flight.isRunning }
        #expect(!flight.isRunning)
        #expect(flight.run(gate.operation))
        await waitUntil { gate.isWaiting }
        gate.open()
        await waitUntil { !flight.isRunning }
        #expect(gate.runs == 2)
    }

    @Test("A cancelled action stays in flight until it returns, so it never runs twice")
    func cancellationKeepsTheRun() async {
        let flight = SwiftForgeSingleFlight()
        let gate = Gate()
        flight.run(gate.operation)
        await waitUntil { gate.isWaiting }

        flight.cancel()
        #expect(flight.isRunning)
        #expect(!flight.run(gate.operation))

        gate.open()
        await waitUntil { !flight.isRunning }
        #expect(gate.sawCancellation)
        #expect(gate.runs == 1)
    }
}
