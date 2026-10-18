//
//  Specimens+Display.swift
//  SwiftForgeShowcase
//
//  Specimens of the display components added with the component catalog:
//  list rows, card slots, badge sizes, labeled dividers, avatars, and empty
//  states.
//

import SwiftForgeUI
import SwiftUI

extension Specimens {

    /// Rows on a surface, as outside a `List`; `List` itself is UIKit-backed
    /// and doesn't size to fit in a snapshot.
    struct ListRows: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                SwiftForgeSectionHeader("Settings") { Button("Edit") {} }
                VStack(spacing: 0) {
                    SwiftForgeListRow(
                        "Notifications", subtitle: Text("Banners, sounds, badges"), systemImage: "bell", accessory: .chevron)
                    SwiftForgeDivider(inset: .leading(32))
                    SwiftForgeListRow("Wi-Fi", systemImage: "wifi", value: Text("Home"), accessory: .chevron)
                    SwiftForgeDivider(inset: .leading(32))
                    SwiftForgeListRow("Ada Lovelace", subtitle: Text("Online")) {
                        SwiftForgeAvatar(name: "Ada Lovelace", status: .online).controlSize(.small)
                    } trailing: {
                        SwiftForgeBadge(count: 3)
                    }
                    SwiftForgeDivider(inset: .leading(32))
                    SwiftForgeListRow("English", accessory: .checkmark)
                    SwiftForgeDivider()
                    LabeledContent("Version", value: "2.4.1")
                        .labeledContentStyle(.swiftForge)
                }
                .padding(.horizontal, 16)
                .swiftForgeSurface()
            }
        }
    }

    struct CardSlots: View {
        var body: some View {
            VStack(spacing: 12) {
                SwiftForgeCard(style: .elevated) {
                    Text("Your subscription renews on March 4.")
                } header: {
                    Text("Plan renews")
                } footer: {
                    Button("Manage") {}.buttonStyle(.swiftForge(.tinted)).controlSize(.small)
                }
                GroupBox("Storage") {
                    ProgressView(value: 0.62).progressViewStyle(.swiftForgeLinear)
                }
                .groupBoxStyle(.swiftForgeCard(.outlined))
            }
        }
    }

    struct BadgeSizes: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach([ControlSize.small, .regular, .large], id: \.self) { size in
                    SwiftForgeFlowLayout(spacing: 12) {
                        SwiftForgeBadge("New", tone: .info)
                        SwiftForgeBadge("Beta", tone: .accent, prominence: .prominent)
                        SwiftForgeBadge(count: 7)
                        SwiftForgeBadge(count: 128)
                        SwiftForgeBadge.dot()
                    }
                    .controlSize(size)
                }
            }
        }
    }

    struct LabeledDividers: View {
        var body: some View {
            VStack(spacing: 16) {
                SwiftForgeDivider("or")
                SwiftForgeDivider("Continue with", inset: .horizontal(24), emphasis: .strong)
            }
        }
    }

    struct Avatars: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    SwiftForgeAvatar(name: "Ada Lovelace", status: .online).controlSize(.small)
                    SwiftForgeAvatar(name: "Grace Hopper", status: .away)
                    SwiftForgeAvatar(name: "Katherine Johnson", status: .busy).controlSize(.large)
                    SwiftForgeAvatar(name: "Alan Turing", status: .offline)
                    SwiftForgeAvatar(name: "")
                }
                SwiftForgeAvatarGroup(
                    ["Ada Lovelace", "Grace Hopper", "Katherine Johnson", "Alan Turing", "Margaret Hamilton", "Linus Pauling"]
                        .map { SwiftForgeAvatar(name: $0) },
                    maxVisible: 4)
            }
        }
    }

    struct EmptyStates: View {
        var body: some View {
            SwiftForgeEmptyState(
                "No Messages", systemImage: "tray", description: Text("Messages you receive appear here.")
            ) {
                Button("Compose") {}
                Button("Import") {}.buttonStyle(.swiftForge(.plain))
            }
        }
    }
}
