//
//  SwiftForgeSingleFlight.swift
//  SwiftForgeUI
//

import Observation

/// Runs at most one async operation at a time. Backs ``SwiftForgeButton``.
///
/// Cancelling doesn't end a run: cancellation is cooperative, so the run
/// counts as in flight until its operation actually returns. That keeps an
/// operation that ignores cancellation from running twice when a cancelled
/// button reappears and is tapped again.
@MainActor
@Observable
final class SwiftForgeSingleFlight {

    /// Whether an operation is running.
    private(set) var isRunning = false

    @ObservationIgnored private var task: Task<Void, Never>?

    /// Starts `operation` unless one is already running.
    ///
    /// - Returns: Whether the operation started.
    @discardableResult
    func run(_ operation: @escaping @MainActor () async -> Void) -> Bool {
        guard task == nil else { return false }
        isRunning = true
        task = Task { [weak self] in
            await operation()
            self?.finish()
        }
        return true
    }

    /// Asks the running operation, if any, to stop.
    func cancel() {
        task?.cancel()
    }

    private func finish() {
        task = nil
        isRunning = false
    }
}
