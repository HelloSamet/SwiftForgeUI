//
//  SwiftForgePresentationQueue.swift
//  SwiftForgeUI
//
//  The engine behind toasts and dialogs: one presentation is shown at a time,
//  later ones wait in order. Pure value logic, so it's unit-tested without UI.
//

import Foundation

/// A first-in, first-out queue of presentations, of which one is current.
struct SwiftForgePresentationQueue<Item: Identifiable> {

    /// The presentation on screen, if any.
    private(set) var current: Item?

    /// Presentations waiting for the current one to be dismissed, oldest first.
    private(set) var pending: [Item] = []

    /// Whether nothing is shown or waiting.
    var isEmpty: Bool { current == nil && pending.isEmpty }

    /// Shows `item` now if nothing is current, or after the ones before it.
    /// An item whose identifier is already shown or waiting is ignored, so
    /// repeating the same message doesn't stack copies of it.
    mutating func enqueue(_ item: Item) {
        guard !contains(id: item.id) else { return }
        if current == nil {
            current = item
        } else {
            pending.append(item)
        }
    }

    /// Dismisses the item with `id`: the current item gives way to the next
    /// waiting one; a waiting item is removed. Returns whether it was found.
    @discardableResult
    mutating func dismiss(id: Item.ID) -> Bool {
        if current?.id == id {
            current = pending.isEmpty ? nil : pending.removeFirst()
            return true
        }
        guard let index = pending.firstIndex(where: { $0.id == id }) else { return false }
        pending.remove(at: index)
        return true
    }

    /// Dismisses the current item and everything waiting.
    mutating func dismissAll() {
        current = nil
        pending.removeAll()
    }

    /// Whether an item with `id` is shown or waiting.
    func contains(id: Item.ID) -> Bool {
        current?.id == id || pending.contains { $0.id == id }
    }
}

/// When a presentation dismisses itself.
enum SwiftForgePresentationTiming {

    /// How long a presentation stays before dismissing itself, or `nil` if
    /// it stays until dismissed.
    ///
    /// Presentations with an action never time out: a person who needs more
    /// time to reach the action must not lose it (WCAG 2.2.1). With VoiceOver
    /// running, the time doubles, since the presentation is read aloud before
    /// it can be acted on.
    ///
    /// - Parameters:
    ///   - duration: The requested display time, or `nil` to stay.
    ///   - hasAction: Whether the presentation offers an action.
    ///   - isVoiceOverRunning: Whether VoiceOver is on.
    static func autoDismissDelay(duration: Duration?, hasAction: Bool, isVoiceOverRunning: Bool) -> Duration? {
        guard let duration, !hasAction else { return nil }
        return isVoiceOverRunning ? duration * 2 : duration
    }
}
