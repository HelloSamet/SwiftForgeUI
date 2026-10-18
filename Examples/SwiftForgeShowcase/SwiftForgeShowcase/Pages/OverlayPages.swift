//
//  OverlayPages.swift
//  SwiftForgeShowcase
//
//  Live pages for toasts, dialogs, the tab bar, and the navigation header.
//  The app's root installs the presenter, so these pages only use it.
//

import SwiftForgeUI
import SwiftUI

struct ToastsAndDialogsPage: View {

    @Environment(SwiftForgePresenter.self) private var presenter
    @State private var archived = 0

    var body: some View {
        CatalogPageContainer {
            Specimen("Toasts") {
                Button("Success") { presenter.show(SwiftForgeToast(.success, title: "Message sent")) }
                Button("With undo") {
                    presenter.show(
                        SwiftForgeToast(
                            .neutral, title: "Conversation archived", message: "It's in the Archive folder.",
                            action: .init("Undo") {}))
                }
                Button("Error, stays") {
                    presenter.show(SwiftForgeToast(.danger, title: "Couldn't upload photo", duration: .indefinite))
                }
                Button("Queue three") {
                    for index in 1...3 {
                        presenter.show(SwiftForgeToast(.info, title: "Toast \(index) of 3"))
                    }
                }
            }
            Specimen("Dialogs") {
                Button("Destructive") {
                    presenter.present(
                        SwiftForgeAlertDialog(
                            title: "Delete this draft?", message: "You can't undo this.", systemImage: "trash",
                            tone: .danger, actions: [.init("Delete", role: .destructive), .cancel()]))
                }
                Button("Three actions") {
                    presenter.present(
                        SwiftForgeAlertDialog(
                            title: "Turn on notifications?", message: "Hear about replies and mentions right away.",
                            systemImage: "bell.badge", actions: [.init("Turn On"), .init("Choose Topics"), .cancel()]))
                }
                Button("No cancel") {
                    presenter.present(
                        SwiftForgeAlertDialog(
                            title: "Terms updated", message: "Review the new terms to continue.",
                            actions: [.init("Review Terms")]))
                }
            }
        }
        .buttonStyle(.swiftForge(.tinted))
    }
}

struct TabBarAndHeaderPage: View {

    enum Tab: Hashable, Sendable { case inbox, search, profile }

    @State private var tab = Tab.inbox

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SwiftForgeNavigationHeader("Inbox", subtitle: Text("Scroll to hand the title to the bar")) {
                    SwiftForgeAvatar(name: "Ada Lovelace", status: .online).controlSize(.small)
                }
                ForEach(0..<40, id: \.self) { index in
                    SwiftForgeListRow("Message \(index)", subtitle: Text("Preview of the message"))
                    SwiftForgeDivider()
                }
            }
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            SwiftForgeTabBar(
                selection: $tab,
                items: [
                    SwiftForgeTabItem("Inbox", systemImage: "tray", value: .inbox, badge: 3),
                    SwiftForgeTabItem("Search", systemImage: "magnifyingglass", value: .search),
                    SwiftForgeTabItem("Profile", systemImage: "person", value: .profile),
                ])
        }
    }
}
