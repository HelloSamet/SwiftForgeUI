//
//  SwiftForgeMotion.swift
//  SwiftForgeUI
//

import SwiftUI

/// A spring animation described by its duration and bounce.
///
/// Motion tokens are plain values rather than `Animation`s so themes stay
/// `Sendable` and comparable. Resolve one with ``animation(reduceMotion:)``,
/// which substitutes a short ease when Reduce Motion is on.
public struct SwiftForgeMotionToken: Sendable, Hashable {

    /// The perceptual duration, in seconds.
    public var duration: Double
    /// How much the spring overshoots, from 0 (none) to 1.
    public var bounce: Double

    /// Creates a motion token.
    public init(duration: Double, bounce: Double = 0) {
        self.duration = duration
        self.bounce = bounce
    }

    /// The animation for this token: an interruptible spring, or a short
    /// ease-in-out of at most 0.2 s when Reduce Motion is on.
    public func animation(reduceMotion: Bool) -> Animation {
        reduceMotion ? .easeInOut(duration: min(duration, 0.2)) : .spring(duration: duration, bounce: bounce)
    }
}

/// The motion tokens components animate with.
public struct SwiftForgeMotion: Sendable, Hashable {

    /// Press feedback, toggles, chip selection.
    public var fast: SwiftForgeMotionToken
    /// Appearing and disappearing content, indicators moving.
    public var standard: SwiftForgeMotionToken
    /// Toasts and confirmations that deserve emphasis.
    public var emphasized: SwiftForgeMotionToken
    /// One sweep of a loading placeholder's highlight, in seconds.
    public var shimmerDuration: Double
    /// The scale of a control while pressed. Not applied with Reduce Motion.
    public var pressedScale: CGFloat
    /// The width of a loading placeholder's highlight band, as a fraction of
    /// the placeholder's width.
    public var shimmerBandWidth: Double

    /// Creates a motion set.
    public init(
        fast: SwiftForgeMotionToken,
        standard: SwiftForgeMotionToken,
        emphasized: SwiftForgeMotionToken,
        shimmerDuration: Double,
        pressedScale: CGFloat,
        shimmerBandWidth: Double = 0.6
    ) {
        self.fast = fast
        self.standard = standard
        self.emphasized = emphasized
        self.shimmerDuration = shimmerDuration
        self.pressedScale = pressedScale
        self.shimmerBandWidth = shimmerBandWidth
    }

    /// SwiftForgeUI's motion, modeled on Apple's `snappy`, `smooth`, and
    /// bouncy spring presets.
    public static let standard = SwiftForgeMotion(
        fast: SwiftForgeMotionToken(duration: 0.2, bounce: 0.15),
        standard: SwiftForgeMotionToken(duration: 0.3),
        emphasized: SwiftForgeMotionToken(duration: 0.45, bounce: 0.15),
        shimmerDuration: 1.4,
        pressedScale: 0.97
    )
}

/// An event that may play haptic feedback.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeHapticEvent: Sendable, Hashable, CaseIterable {
    /// A selection changed, such as a segment or chip.
    case selection
    /// A success message appeared.
    case success
    /// A warning appeared.
    case warning
    /// An error appeared, such as a field validation error.
    case error
}

/// Which events play haptic feedback.
///
/// Following Apple's guidance to use haptics sparingly, button taps never
/// play feedback; selection changes and status messages do.
public struct SwiftForgeHaptics: Sendable, Hashable {

    /// Whether SwiftForgeUI components play any haptic feedback.
    public var isEnabled: Bool

    /// The events that play feedback when ``isEnabled`` is `true`.
    public var events: Set<SwiftForgeHapticEvent>

    /// Creates a haptics configuration.
    public init(isEnabled: Bool = true, events: Set<SwiftForgeHapticEvent> = Set(SwiftForgeHapticEvent.allCases)) {
        self.isEnabled = isEnabled
        self.events = events
    }

    /// Whether an event plays feedback.
    public func plays(_ event: SwiftForgeHapticEvent) -> Bool {
        isEnabled && events.contains(event)
    }

    /// The feedback for an event, or `nil` if it shouldn't play.
    @available(iOS 17.0, visionOS 26.0, *)
    public func feedback(for event: SwiftForgeHapticEvent) -> SensoryFeedback? {
        guard plays(event) else { return nil }
        switch event {
        case .selection: return .selection
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }

    /// Feedback for selection changes and status messages.
    public static let standard = SwiftForgeHaptics()

    /// No haptic feedback.
    public static let disabled = SwiftForgeHaptics(isEnabled: false)
}

private struct SwiftForgeHapticModifier<Trigger: Equatable>: ViewModifier {

    let trigger: Trigger
    let event: (Trigger, Trigger) -> SwiftForgeHapticEvent?

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        #if os(visionOS)
        if #available(visionOS 26.0, *) {
            content.sensoryFeedback(trigger: trigger) { old, new in
                event(old, new).flatMap(theme.haptics.feedback(for:))
            }
        } else {
            content
        }
        #else
        content.sensoryFeedback(trigger: trigger) { old, new in
            event(old, new).flatMap(theme.haptics.feedback(for:))
        }
        #endif
    }
}

extension View {

    /// Plays the theme's haptic feedback for the event `event` returns when
    /// `trigger` changes. A no-op where the platform has no haptics API.
    func swiftForgeHaptic<Trigger: Equatable>(
        trigger: Trigger,
        _ event: @escaping (_ oldValue: Trigger, _ newValue: Trigger) -> SwiftForgeHapticEvent?
    ) -> some View {
        modifier(SwiftForgeHapticModifier(trigger: trigger, event: event))
    }
}
