//
//  SwiftForgeOverlayLayer.swift
//  SwiftForgeUI
//
//  The layer toasts and dialogs are drawn in, above a screen's content. It
//  owns what every presentation must get right — motion, the scrim, safe
//  areas, and VoiceOver focus — so each component only draws its own body.
//

import SwiftUI

/// How a presentation relates to the content beneath it.
enum SwiftForgeOverlayKind: Sendable, Hashable {

    /// Floats at an edge without blocking the content, like a toast.
    case transient(edge: VerticalEdge)

    /// Centered over a scrim that blocks the content, like a dialog. The
    /// content is hidden from VoiceOver while it's shown.
    case modal
}

struct SwiftForgeOverlayLayer<Item: Identifiable, Overlay: View>: ViewModifier {

    let item: Item?
    let kind: SwiftForgeOverlayKind
    /// The modal scrim's color before ``SwiftForgeOpacity/scrim`` applies,
    /// or `nil` for the canvas color, like the loading overlay.
    var scrim: SwiftForgeColor? = nil
    /// Called when the person asks to dismiss a modal presentation with the
    /// VoiceOver escape gesture or a tap on the scrim; `nil` if it can't be
    /// dismissed that way.
    var onDismissRequest: (@MainActor (Item) -> Void)? = nil
    /// The text VoiceOver announces when a transient presentation appears.
    var announcement: (Item) -> String? = { _ in nil }
    @ViewBuilder let overlay: (Item) -> Overlay

    @Environment(\.swiftForgeTheme) private var theme
    @SwiftForgeAccessibilityContext private var accessibility
    @AccessibilityFocusState private var overlayHasFocus: Bool

    func body(content: Content) -> some View {
        content
            .accessibilityHidden(blocksContent)
            .allowsHitTesting(!blocksContent)
            .overlay(alignment: alignment) {
                ZStack(alignment: alignment) {
                    if isModal, let item {
                        scrimView
                            .onTapGesture { onDismissRequest?(item) }
                            .transition(.opacity)
                    }
                    if let item {
                        presented(item)
                            .id(item.id)
                            .transition(transition)
                    }
                }
                .animation(motion.animation(reduceMotion: accessibility.reduceMotion), value: item?.id)
            }
            .onChange(of: item?.id, initial: true) { _, id in
                guard id != nil, let item else { return }
                if isModal {
                    overlayHasFocus = true
                } else if let text = announcement(item) {
                    AccessibilityNotification.Announcement(text).post()
                }
            }
    }

    private var isModal: Bool { kind == .modal }

    private var blocksContent: Bool { isModal && item != nil }

    private var alignment: Alignment {
        switch kind {
        case .modal: .center
        case .transient(.top): .top
        case .transient(.bottom): .bottom
        }
    }

    /// Dialogs take the emphasized spring; toasts the standard one.
    private var motion: SwiftForgeMotionToken {
        isModal ? theme.motion.emphasized : theme.motion.standard
    }

    /// Slides in from the edge (toasts) or grows slightly (dialogs); only
    /// fades with Reduce Motion on.
    private var transition: AnyTransition {
        if accessibility.reduceMotion { return .opacity }
        switch kind {
        case .modal: return .scale(scale: theme.motion.pressedScale).combined(with: .opacity)
        case .transient(.top): return .move(edge: .top).combined(with: .opacity)
        case .transient(.bottom): return .move(edge: .bottom).combined(with: .opacity)
        }
    }

    @ViewBuilder
    private func presented(_ item: Item) -> some View {
        let view = overlay(item)
            .padding(theme.spacing.screenHorizontal)
        if isModal {
            view
                .accessibilityElement(children: .contain)
                .accessibilityAddTraits(.isModal)
                .accessibilityFocused($overlayHasFocus)
                .accessibilityAction(.escape) { onDismissRequest?(item) }
        } else {
            view
        }
    }

    /// The modal scrim at the theme's scrim opacity, nearly opaque with
    /// Reduce Transparency on.
    private var scrimView: some View {
        let opacity = accessibility.reduceTransparency ? theme.opacity.scrimReducedTransparency : theme.opacity.scrim
        return Rectangle()
            .fill((scrim ?? theme.colors.canvas).withOpacity(opacity))
            .ignoresSafeArea()
            .accessibilityHidden(true)
    }
}

extension View {

    /// Draws the current item of a presentation queue above this view.
    func swiftForgeOverlayLayer<Item: Identifiable, Overlay: View>(
        _ item: Item?,
        kind: SwiftForgeOverlayKind,
        scrim: SwiftForgeColor? = nil,
        onDismissRequest: (@MainActor (Item) -> Void)? = nil,
        announcement: @escaping (Item) -> String? = { _ in nil },
        @ViewBuilder overlay: @escaping (Item) -> Overlay
    ) -> some View {
        modifier(
            SwiftForgeOverlayLayer(
                item: item, kind: kind, scrim: scrim, onDismissRequest: onDismissRequest, announcement: announcement,
                overlay: overlay))
    }
}
