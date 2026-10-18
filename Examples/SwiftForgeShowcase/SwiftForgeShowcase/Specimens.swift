//
//  Specimens.swift
//  SwiftForgeShowcase
//
//  Compact, deterministic arrangements of each component, shared by the
//  snapshot tests and the accessibility-audit UI test fixtures. Animated states (spinners) are left out: their
//  frames aren't deterministic. Loading states are covered by unit tests.
//

import SwiftForgeUI
import SwiftUI

enum Specimens {

    struct Buttons: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(SwiftForgeButtonStyle.Variant.allCases, id: \.self) { variant in
                    HStack {
                        Button(variant.rawValue.capitalized) {}.buttonStyle(.swiftForge(variant))
                        Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge(variant))
                        Button("Share", systemImage: "square.and.arrow.up") {}.buttonStyle(.swiftForgeIcon(variant))
                    }
                }
                HStack {
                    Button("Small") {}.controlSize(.small)
                    Button("Large", systemImage: "arrow.forward") {}
                        .controlSize(.large)
                        .swiftForgeIconPlacement(.trailing)
                    Button("Disabled") {}.disabled(true)
                }
                .buttonStyle(.swiftForge(.filled))
                Button("Continue to payment") {}
                    .buttonStyle(.swiftForge(.filled))
                    .swiftForgeFullWidth()
            }
        }
    }

    struct Toggles: View {
        var body: some View {
            VStack(spacing: 4) {
                Toggle("Notifications", isOn: .constant(true))
                Toggle("Sounds", isOn: .constant(false))
                Toggle("Erase data", isOn: .constant(true)).toggleStyle(.swiftForge(tone: .danger))
                Toggle("Disabled", isOn: .constant(true)).disabled(true)
                Group {
                    Toggle("On, without color", isOn: .constant(true))
                    Toggle("Off, without color", isOn: .constant(false))
                }
                .swiftForgeAccessibilitySimulation(differentiateWithoutColor: true)
            }
            .toggleStyle(.swiftForge)
        }
    }

    struct TextFields: View {
        var body: some View {
            VStack(spacing: 12) {
                SwiftForgeTextField("Name", text: .constant(""), prompt: Text("Jane Appleseed"))
                SwiftForgeTextField("Email", text: .constant("sam@"), state: .error("Enter a valid email address.")) {
                    Image(systemName: "envelope")
                }
                SwiftForgeTextField("Username", text: .constant("sam"), state: .success("That username is available."))
                SwiftForgeTextField("Bio", text: .constant("Designer"), state: .helper("Shown on your profile."))
                    .swiftForgeCharacterLimit(80)
                    .swiftForgeOptionalField()
                SwiftForgeSecureField("Password", text: .constant("hunter22"))
                SwiftForgeTextField("Disabled", text: .constant("Read only")).disabled(true)
            }
        }
    }

    struct Banners: View {
        var body: some View {
            VStack(spacing: 12) {
                SwiftForgeBanner(
                    .info, title: "New version available", message: "Update to get the latest components.",
                    announcesAppearance: false)
                SwiftForgeBanner(.success, title: "Changes saved", onDismiss: {})
                SwiftForgeBanner(
                    .warning, title: "Unsaved changes", message: "You have edits that haven't been saved.",
                    announcesAppearance: false
                ) {
                    Button("Save") {}
                    Button("Discard") {}
                }
                SwiftForgeBanner(
                    .danger, title: "Payment failed", message: "Your card was declined.", prominence: .prominent,
                    announcesAppearance: false, onDismiss: {}
                ) {
                    Button("Update card") {}
                }
            }
        }
    }

    struct Badges: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                FlowRow {
                    ForEach([SwiftForgeTone.neutral, .info, .success], id: \.self) { tone in
                        SwiftForgeBadge(tone.rawValue.capitalized, tone: tone)
                    }
                }
                FlowRow {
                    ForEach([SwiftForgeTone.warning, .danger, .accent], id: \.self) { tone in
                        SwiftForgeBadge(tone.rawValue.capitalized, tone: tone, prominence: .prominent)
                    }
                }
                FlowRow(spacing: 20) {
                    SwiftForgeBadge(count: 3)
                    SwiftForgeBadge(count: 42, tone: .accent)
                    SwiftForgeBadge(count: 1_250)
                    SwiftForgeBadge.dot()
                    Button("Inbox", systemImage: "tray") {}
                        .buttonStyle(.swiftForgeIcon(.tinted))
                        .swiftForgeBadge(count: 5)
                }
            }
        }
    }

    struct Cards: View {
        var body: some View {
            VStack(spacing: 12) {
                ForEach(SwiftForgeCardStyle.allCases, id: \.self) { style in
                    SwiftForgeCard(style: style) {
                        CardText(title: style.rawValue.capitalized, subtitle: "Your subscription renews on March 4.")
                    }
                }
                Button {
                } label: {
                    CardText(title: "Tappable", subtitle: "A button styled as a card.")
                }
                .buttonStyle(.swiftForgeCard())
            }
        }
    }

    struct Progress: View {
        var body: some View {
            VStack(spacing: 16) {
                ProgressView(value: 0.4) {
                    Text("Uploading")
                } currentValueLabel: {
                    Text("40%")
                }
                .progressViewStyle(.swiftForgeLinear)
                ProgressView(value: 0.75).progressViewStyle(.swiftForgeLinear(tone: .success)).controlSize(.large)
                HStack(spacing: 24) {
                    ProgressView(value: 0.3).progressViewStyle(.swiftForgeCircular).controlSize(.small)
                    ProgressView(value: 0.6).progressViewStyle(.swiftForgeCircular)
                    ProgressView(value: 0.9) {
                        EmptyView()
                    } currentValueLabel: {
                        Text("90%")
                    }
                    .progressViewStyle(.swiftForgeCircular)
                    .controlSize(.large)
                }
            }
        }
    }

    /// Rendered with Reduce Motion simulated, so the shimmer is static.
    struct Skeleton: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                SwiftForgeCard { CardText(title: "Jane Appleseed", subtitle: "Shared three photos") }
                    .swiftForgeSkeleton(isActive: true)
                HStack {
                    SwiftForgeSkeletonShape(.circle).frame(width: 40, height: 40)
                    VStack(alignment: .leading) {
                        SwiftForgeSkeletonShape().frame(width: 180, height: 14)
                        SwiftForgeSkeletonShape(.capsule).frame(width: 120, height: 14)
                    }
                }
            }
        }
    }

    struct Dividers: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("Notifications")
                SwiftForgeDivider()
                Text("Privacy")
                SwiftForgeDivider(inset: .leading(24))
                HStack {
                    Text("Left")
                    SwiftForgeDivider().frame(height: 20)
                    Text("Right")
                }
                SwiftForgeDivider(emphasis: .strong)
            }
        }
    }

    struct Surfaces: View {
        var body: some View {
            VStack(spacing: 16) {
                ForEach([SwiftForgeSurfaceLevel.surface, .raised, .overlay], id: \.self) { level in
                    Text(String(describing: level))
                        .frame(maxWidth: .infinity, minHeight: 56)
                        .swiftForgeSurface(level)
                }
            }
        }
    }

    struct CardText: View {
        let title: String
        let subtitle: String
        @Environment(\.swiftForgeTheme) private var theme

        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).swiftForgeTextStyle(\.headline).foregroundStyle(theme.colors.textPrimary)
                Text(subtitle).swiftForgeTextStyle(\.subheadline).foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}
