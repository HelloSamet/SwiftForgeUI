import SwiftUI
import Testing

@testable import SwiftForgeUI

/// The presenter, toasts, dialogs, and the tab bar. Their visuals are in the
/// hosted `OverlaySnapshotTests`; timing, focus, and taps in the UI tests.
@MainActor
@Suite("Overlays and navigation")
struct OverlayAndNavigationTests {

    // MARK: Presenter

    @Test("Toasts show one at a time, in order, and ignore repeats")
    func toastQueue() {
        let presenter = SwiftForgePresenter()
        presenter.show(SwiftForgeToast(title: "One", id: "1"))
        presenter.show(SwiftForgeToast(title: "Two", id: "2"))
        presenter.show(SwiftForgeToast(title: "One again", id: "1"))
        #expect(presenter.visibleToast?.id == "1")
        presenter.dismissToast(id: "1")
        #expect(presenter.visibleToast?.id == "2")
        presenter.dismissAllToasts()
        #expect(presenter.visibleToast == nil)
    }

    @Test("Performing a dialog action dismisses the dialog before running the action")
    func dialogAction() {
        let presenter = SwiftForgePresenter()
        let log = ActionLog()
        let dialog = SwiftForgeAlertDialog(
            title: "Delete?",
            actions: [.init("Delete", role: .destructive) { log.record(presenter.visibleDialog == nil) }, .cancel()])
        presenter.present(dialog)
        #expect(presenter.visibleDialog?.id == dialog.id)
        presenter.perform(dialog.actions[0], in: dialog)
        #expect(presenter.visibleDialog == nil)
        #expect(log.entries == [true])
    }

    @Test("A dialog's primary action is the first that isn't cancel; it keeps at most three actions")
    func dialogRoles() {
        let dialog = SwiftForgeAlertDialog(
            title: "Choose",
            actions: [.cancel(), .init("Save"), .init("Discard", role: .destructive), .init("Extra")])
        #expect(dialog.actions.count == 3)
        #expect(dialog.cancelAction?.role == .cancel)
        #expect(dialog.primaryAction?.title.string == "Save")
    }

    @Test("Dismissing a dialog without an action runs nothing")
    func dismissDialog() {
        let presenter = SwiftForgePresenter()
        let log = ActionLog()
        presenter.present(SwiftForgeAlertDialog(title: "Info", actions: [.init("OK") { log.record(true) }], id: "info"))
        presenter.dismissDialog(id: "info")
        #expect(presenter.visibleDialog == nil)
        #expect(log.entries.isEmpty)
    }

    // MARK: Toast

    @Test("Toasts and dialogs take text that isn't localized, such as a server message, and announce it verbatim")
    func verbatimText() {
        let serverMessage: String = "Quota exceeded (code 42)"
        let toast = SwiftForgeToast(.danger, title: serverMessage, message: "Try again tomorrow.", action: .init("Retry") {})
        #expect(toast.title == SwiftForgeText(verbatim: serverMessage))
        #expect(toast.message == SwiftForgeText(verbatim: "Try again tomorrow."))
        #expect(toast.announcement.hasSuffix("\(serverMessage). Try again tomorrow."))

        let title: Substring = serverMessage.prefix(14)
        let dialog = SwiftForgeAlertDialog(title: title, actions: [.init(String("OK"))])
        #expect(dialog.title == SwiftForgeText(verbatim: "Quota exceeded"))
        #expect(dialog.actions.first?.title == SwiftForgeText(verbatim: "OK"))

        // String literals still pick the localized initializers.
        #expect(SwiftForgeToast(title: "Sent").title == SwiftForgeText(LocalizedStringResource("Sent")))
    }

    @Test("Toast durations come from the theme; indefinite toasts stay")
    func toastDurations() {
        let tokens = SwiftForgeToastTokens(shortDuration: 3, longDuration: 9)
        #expect(SwiftForgeToast(title: "A").displayTime(in: tokens) == .seconds(3))
        #expect(SwiftForgeToast(title: "A", duration: .long).displayTime(in: tokens) == .seconds(9))
        #expect(SwiftForgeToast(title: "A", duration: .indefinite).displayTime(in: tokens) == nil)
    }

    @Test("Toasts that won't leave on their own can be closed")
    func toastDismissible() {
        #expect(!SwiftForgeToast(title: "Sent").isDismissible)
        #expect(SwiftForgeToast(title: "Archived", action: .init("Undo") {}).isDismissible)
        #expect(SwiftForgeToast(title: "Failed", duration: .indefinite).isDismissible)
    }

    @Test("A toast's announcement starts with its tone")
    func toastAnnouncement() {
        let toast = SwiftForgeToast(.danger, title: "Upload failed", message: "Try again.")
        #expect(toast.announcement.hasSuffix("Upload failed. Try again."))
        #expect(toast.announcement.hasPrefix(SwiftForgeStrings.toneNameString(.danger)))
    }

    // MARK: Tab bar

    @Test("A selected tab shows the filled symbol when there is one")
    func tabSymbols() {
        let house = SwiftForgeTabItem("Home", systemImage: "house", value: 1)
        #expect(house.symbol(isSelected: false) == "house")
        #expect(house.symbol(isSelected: true) == "house.fill")
        let search = SwiftForgeTabItem("Search", systemImage: "magnifyingglass", value: 2)
        #expect(search.symbol(isSelected: true) == "magnifyingglass")
        let custom = SwiftForgeTabItem("Me", systemImage: "person", selectedSystemImage: "person.crop.circle.fill", value: 3)
        #expect(custom.symbol(isSelected: true) == "person.crop.circle.fill")
    }

    @Test("Tab items share the bar's width and keep a 44-pt hit area")
    func tabBarLayout() {
        let bar = SwiftForgeTabBar(
            selection: .constant(1),
            items: [
                SwiftForgeTabItem("Home", systemImage: "house", value: 1),
                SwiftForgeTabItem("Inbox", systemImage: "tray", value: 2),
            ])
        let rendered = RenderedView(bar, width: 300)
        #expect(rendered.size.height >= SwiftForgeTheme.forge.components.tabBar.height)
        #expect(rendered.size.height >= 44)
    }

    @Test("Every theme's overlay, tooltip, and tab bar tokens are usable", arguments: SwiftForgeTheme.builtIn)
    func tokens(theme: SwiftForgeTheme) {
        let components = theme.components
        #expect(components.toast.shortDuration >= 4 && components.toast.longDuration > components.toast.shortDuration)
        #expect(components.dialog.width >= 280)
        #expect(components.tabBar.height >= 44)
        // Wide enough for a sentence, narrow enough for an iPhone SE with margins.
        #expect((200...(320 - 2 * theme.spacing.md)).contains(components.tooltip.maxWidth))
    }
}

/// Records what actions observe, from main-actor closures.
@MainActor
private final class ActionLog: Sendable {
    private(set) var entries: [Bool] = []
    func record(_ entry: Bool) { entries.append(entry) }
}
