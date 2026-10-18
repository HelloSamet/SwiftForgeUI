//
//  DisplayPages.swift
//  SwiftForgeShowcase
//
//  Live pages for the display components of the component catalog.
//

import SwiftForgeUI
import SwiftUI

struct ListRowsPage: View {

    @State private var darkMode = false
    @State private var language = "English"
    @State private var contacts = ["Ada Lovelace", "Grace Hopper", "Katherine Johnson"]
    @State private var density = SwiftForgeDensity.regular

    var body: some View {
        List {
            Section {
                SwiftForgeSegmentedControl("Density", selection: $density, options: SwiftForgeDensity.allCases) {
                    Text($0.rawValue.capitalized)
                }
            }
            Section {
                NavigationLink {
                    Text("Notifications")
                } label: {
                    SwiftForgeListRow("Notifications", subtitle: Text("Banners, sounds, badges"), systemImage: "bell")
                }
                SwiftForgeListRow("Wi-Fi", systemImage: "wifi", value: Text("Home"), accessory: .chevron)
                SwiftForgeListRow("Dark Mode") {
                    SwiftForgeIcon("moon")
                } trailing: {
                    Toggle("Dark Mode", isOn: $darkMode).labelsHidden().toggleStyle(.swiftForge)
                }
            } header: {
                SwiftForgeSectionHeader("Settings")
            }
            Section {
                ForEach(["English", "Türkçe", "Deutsch"], id: \.self) { option in
                    Button {
                        language = option
                    } label: {
                        SwiftForgeListRow(LocalizedStringKey(option), accessory: language == option ? .checkmark : .none)
                    }
                }
            } header: {
                SwiftForgeSectionHeader("Language")
            }
            Section {
                ForEach(contacts, id: \.self) { name in
                    SwiftForgeListRow(LocalizedStringKey(name), subtitle: Text("Swipe for actions")) {
                        SwiftForgeAvatar(name: name, status: .online).controlSize(.small)
                    } trailing: {
                        EmptyView()
                    }
                    .swipeActions {
                        Button("Delete", role: .destructive) { contacts.removeAll { $0 == name } }
                    }
                }
            } header: {
                SwiftForgeSectionHeader("Contacts") { Button("Reset") { contacts = ["Ada Lovelace", "Grace Hopper"] } }
            }
            Section {
                LabeledContent("Version", value: "2.4.1")
                LabeledContent("Storage") { Text("12.4 GB of 64 GB") }
            }
            .labeledContentStyle(.swiftForge)
        }
        .swiftForgeDensity(density)
    }
}

struct AvatarsPage: View {

    @State private var visible = 3.0

    private let people = ["Ada Lovelace", "Grace Hopper", "Katherine Johnson", "Alan Turing", "Margaret Hamilton", "山田 太郎"]

    var body: some View {
        CatalogPageContainer {
            Specimen("Sizes and status") {
                HStack(spacing: 12) {
                    SwiftForgeAvatar(name: "Ada Lovelace", status: .online).controlSize(.small)
                    SwiftForgeAvatar(name: "Grace Hopper", status: .away)
                    SwiftForgeAvatar(name: "Katherine Johnson", status: .busy).controlSize(.large)
                    SwiftForgeAvatar(name: "Alan Turing", status: .offline)
                }
            }
            Specimen("Fallbacks") {
                HStack(spacing: 12) {
                    SwiftForgeAvatar(name: "Ada Lovelace", image: Image(systemName: "photo.artframe"))
                    SwiftForgeAvatar(name: "山田 太郎")
                    SwiftForgeAvatar(name: "محمد علي")
                    SwiftForgeAvatar(name: "")
                }
            }
            Specimen("Group") {
                SwiftForgeAvatarGroup(people.map { SwiftForgeAvatar(name: $0) }, maxVisible: Int(visible))
                SwiftForgeSlider("Visible", value: $visible, in: 1...6, step: 1) { Text(Int($0), format: .number) }
            }
            Specimen("Without color") {
                HStack(spacing: 12) {
                    ForEach(SwiftForgeAvatar.Status.allCases, id: \.self) { status in
                        SwiftForgeAvatar(name: "Ada Lovelace", status: status)
                    }
                }
                .swiftForgeAccessibilitySimulation(differentiateWithoutColor: true)
            }
        }
    }
}

struct EmptyStatePage: View {

    @State private var hasMessages = false

    var body: some View {
        Group {
            if hasMessages {
                List(["Welcome to SwiftForge", "Your order shipped"], id: \.self) { subject in
                    SwiftForgeListRow(LocalizedStringKey(subject), subtitle: Text("Just now"))
                }
            } else {
                SwiftForgeEmptyState(
                    "No Messages", systemImage: "tray", description: Text("Messages you receive appear here.")
                ) {
                    Button("Load Sample Messages") { hasMessages = true }
                }
            }
        }
        .toolbar {
            if hasMessages {
                Button("Clear") { hasMessages = false }
            }
        }
    }
}
