//
//  SwiftForgePresenter.swift
//  SwiftForgeUI
//

import SwiftUI

/// Shows toasts and dialogs above an app's content, one at a time and in
/// order.
///
/// Create one presenter for a window, install it with
/// ``SwiftUICore/View/swiftForgePresentationHost(_:toastEdge:)``, and use it
/// from any view beneath:
///
/// ```swift
/// @main
/// struct MyApp: App {
///     @State private var presenter = SwiftForgePresenter()
///
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///                 .swiftForgePresentationHost(presenter)
///         }
///     }
/// }
///
/// struct ComposeView: View {
///     @Environment(SwiftForgePresenter.self) private var presenter
///
///     var body: some View {
///         Button("Send") {
///             send()
///             presenter.show(SwiftForgeToast(.success, title: "Message sent"))
///         }
///     }
/// }
/// ```
///
/// Toasts and dialogs each have their own queue: while one is shown, later
/// ones wait. A dialog dims and blocks the content — including a visible
/// toast — until it's answered.
@MainActor
@Observable
public final class SwiftForgePresenter {

    private(set) var toasts = SwiftForgePresentationQueue<SwiftForgeToast>()
    private(set) var dialogs = SwiftForgePresentationQueue<SwiftForgeAlertDialog>()

    /// Creates a presenter.
    public init() {}

    /// The toast on screen, if any.
    public var visibleToast: SwiftForgeToast? { toasts.current }

    /// The dialog on screen, if any.
    public var visibleDialog: SwiftForgeAlertDialog? { dialogs.current }

    /// Shows a toast now, or after the toasts before it.
    public func show(_ toast: SwiftForgeToast) {
        toasts.enqueue(toast)
    }

    /// Dismisses the toast with `id`, whether it's shown or waiting.
    public func dismissToast(id: SwiftForgeToast.ID) {
        toasts.dismiss(id: id)
    }

    /// Dismisses every toast.
    public func dismissAllToasts() {
        toasts.dismissAll()
    }

    /// Presents a dialog now, or after the dialogs before it.
    public func present(_ dialog: SwiftForgeAlertDialog) {
        dialogs.enqueue(dialog)
    }

    /// Dismisses the dialog with `id` without running any of its actions.
    public func dismissDialog(id: SwiftForgeAlertDialog.ID) {
        dialogs.dismiss(id: id)
    }

    /// Dismisses a dialog and runs one of its actions.
    func perform(_ action: SwiftForgeAlertDialog.Action, in dialog: SwiftForgeAlertDialog) {
        dialogs.dismiss(id: dialog.id)
        action.handler()
    }
}

private struct SwiftForgePresentationHostModifier: ViewModifier {

    let presenter: SwiftForgePresenter
    let toastEdge: VerticalEdge

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.accessibilityVoiceOverEnabled) private var isVoiceOverRunning

    func body(content: Content) -> some View {
        content
            .swiftForgeOverlayLayer(
                presenter.visibleToast, kind: .transient(edge: toastEdge), announcement: { $0.announcement }
            ) { toast in
                SwiftForgeToastView(toast: toast) { presenter.dismissToast(id: toast.id) }
            }
            .task(id: presenter.visibleToast?.id) {
                guard let toast = presenter.visibleToast,
                    let delay = SwiftForgePresentationTiming.autoDismissDelay(
                        duration: toast.displayTime(in: theme.components.toast), hasAction: toast.action != nil,
                        isVoiceOverRunning: isVoiceOverRunning)
                else { return }
                try? await Task.sleep(for: delay)
                guard !Task.isCancelled else { return }
                presenter.dismissToast(id: toast.id)
            }
            .swiftForgeOverlayLayer(
                presenter.visibleDialog, kind: .modal, scrim: theme.components.dialog.scrim,
                onDismissRequest: { dialog in
                    if let cancel = dialog.cancelAction { presenter.perform(cancel, in: dialog) }
                }
            ) { dialog in
                SwiftForgeAlertDialogView(dialog: dialog) { action in presenter.perform(action, in: dialog) }
            }
            .environment(presenter)
    }
}

extension View {

    /// Shows the toasts and dialogs of a presenter above this view, and
    /// makes the presenter available to views beneath as
    /// `@Environment(SwiftForgePresenter.self)`.
    ///
    /// Apply it once, near the root of a window, so presentations cover the
    /// whole screen.
    ///
    /// - Parameters:
    ///   - presenter: The presenter whose toasts and dialogs to show.
    ///   - toastEdge: Where toasts appear. Defaults to the bottom, within the safe area.
    public func swiftForgePresentationHost(_ presenter: SwiftForgePresenter, toastEdge: VerticalEdge = .bottom) -> some View {
        modifier(SwiftForgePresentationHostModifier(presenter: presenter, toastEdge: toastEdge))
    }
}

// MARK: - Previews

private struct PresentationPreview: View {
    @Environment(SwiftForgePresenter.self) private var presenter

    var body: some View {
        VStack(spacing: 12) {
            Button("Toast") { presenter.show(SwiftForgeToast(.success, title: "Message sent")) }
            Button("Toast with undo") {
                presenter.show(
                    SwiftForgeToast(.neutral, title: "Conversation archived", action: .init("Undo") {}))
            }
            Button("Dialog") {
                presenter.present(
                    SwiftForgeAlertDialog(
                        title: "Delete this draft?", message: "You can't undo this.", systemImage: "trash", tone: .danger,
                        actions: [.init("Delete", role: .destructive), .cancel()]))
            }
        }
        .buttonStyle(.swiftForge(.tinted))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Presentations") {
    @Previewable @State var presenter = SwiftForgePresenter()
    PresentationPreview().swiftForgePresentationHost(presenter)
}
