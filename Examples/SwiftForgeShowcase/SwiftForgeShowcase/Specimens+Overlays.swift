//
//  Specimens+Overlays.swift
//  SwiftForgeShowcase
//
//  Specimens of toasts, dialogs, and the tab bar, drawn through the public
//  presentation host with a presenter that already shows them.
//

import SwiftForgeUI
import SwiftUI

extension Specimens {

    /// A presenter already showing `toast` or `dialog`, hosted over a frame
    /// of the canvas.
    struct Presented: View {
        @State private var presenter: SwiftForgePresenter
        let height: CGFloat
        var showsContent = true
        /// Grows the frame with Dynamic Type: presentations are overlays and
        /// don't size their host.
        @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

        init(toast: SwiftForgeToast? = nil, dialog: SwiftForgeAlertDialog? = nil, height: CGFloat, showsContent: Bool = true) {
            let presenter = SwiftForgePresenter()
            if let toast { presenter.show(toast) }
            if let dialog { presenter.present(dialog) }
            _presenter = State(initialValue: presenter)
            self.height = height
            self.showsContent = showsContent
        }

        var body: some View {
            Text("Content behind")
                .opacity(showsContent ? 1 : 0)
                .frame(maxWidth: .infinity, minHeight: height * scale, alignment: .top)
                .swiftForgePresentationHost(presenter)
        }
    }

    struct Toasts: View {
        var body: some View {
            VStack(spacing: 0) {
                Presented(toast: SwiftForgeToast(.success, title: "Message sent"), height: 120)
                Presented(
                    toast: SwiftForgeToast(
                        .neutral, title: "Conversation archived", message: "It's in the Archive folder.",
                        action: .init("Undo") {}),
                    height: 150)
                Presented(
                    toast: SwiftForgeToast(.danger, title: "Couldn't upload photo", duration: .indefinite), height: 120)
            }
        }
    }

    struct Dialogs: View {
        var body: some View {
            VStack(spacing: 0) {
                Presented(
                    dialog: SwiftForgeAlertDialog(
                        title: "Delete this draft?", message: "You can't undo this.", systemImage: "trash",
                        tone: .danger, actions: [.init("Delete", role: .destructive), .cancel()]),
                    height: 360)
                Presented(
                    dialog: SwiftForgeAlertDialog(
                        title: "Turn on notifications?", message: "Hear about replies and mentions right away.",
                        systemImage: "bell.badge",
                        actions: [.init("Turn On"), .init("Choose Topics"), .cancel()]),
                    height: 440)
            }
        }
    }

    struct TabBars: View {
        enum Tab: Hashable, Sendable { case home, inbox, search, profile }

        var body: some View {
            VStack(spacing: 16) {
                bar(selected: .home, badge: nil)
                bar(selected: .inbox, badge: 3)
                bar(selected: .profile, badge: 128)
            }
        }

        private func bar(selected: Tab, badge: Int?) -> some View {
            SwiftForgeTabBar(
                selection: .constant(selected),
                items: [
                    SwiftForgeTabItem("Home", systemImage: "house", value: .home),
                    SwiftForgeTabItem("Inbox", systemImage: "tray", value: .inbox, badge: badge),
                    SwiftForgeTabItem("Search", systemImage: "magnifyingglass", value: .search),
                    SwiftForgeTabItem("Profile", systemImage: "person", value: .profile),
                ])
        }
    }
}
