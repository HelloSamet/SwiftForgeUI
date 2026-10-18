//
//  ComponentPages.swift
//  SwiftForgeShowcase
//

import SwiftForgeUI
import SwiftUI

struct ButtonsPage: View {

    @State private var isLoading = false

    var body: some View {
        CatalogPageContainer {
            Specimen("Variants") {
                ForEach(SwiftForgeButtonStyle.Variant.allCases, id: \.self) { variant in
                    HStack {
                        Button(variant.rawValue.capitalized) {}.buttonStyle(.swiftForge(variant))
                        Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge(variant))
                        Button("Neutral") {}.buttonStyle(.swiftForge(variant, tone: .neutral))
                    }
                }
            }
            Specimen("Sizes") {
                HStack {
                    Button("Small") {}.controlSize(.small)
                    Button("Regular") {}
                    Button("Large") {}.controlSize(.large)
                }
                .buttonStyle(.swiftForge(.filled))
            }
            Specimen("With icons") {
                HStack {
                    Button("Share", systemImage: "square.and.arrow.up") {}.buttonStyle(.swiftForge(.tinted))
                    Button("Next", systemImage: "arrow.forward") {}
                        .buttonStyle(.swiftForge(.outlined))
                        .swiftForgeIconPlacement(.trailing)
                }
                HStack {
                    ForEach(SwiftForgeButtonStyle.Variant.allCases, id: \.self) { variant in
                        Button("Favorite", systemImage: "heart") {}.buttonStyle(.swiftForgeIcon(variant))
                    }
                    Button("Close", systemImage: "xmark") {}.buttonStyle(.swiftForgeIcon(.tinted, tone: .neutral, shape: .circle))
                }
            }
            Specimen("States") {
                Button("Disabled") {}.buttonStyle(.swiftForge()).disabled(true)
                Button("Toggle loading") { isLoading.toggle() }.buttonStyle(.swiftForge(.outlined))
                Button("Pay $12.00") {}.buttonStyle(.swiftForge()).swiftForgeLoading(isLoading)
                SwiftForgeButton("Async save (2 s)", variant: .tinted) {
                    try await Task.sleep(for: .seconds(2))
                }
            }
            Specimen("Full width") {
                VStack {
                    Button("Create Account") {}.buttonStyle(.swiftForge(.filled))
                    Button("Sign In") {}.buttonStyle(.swiftForge(.outlined))
                }
                .controlSize(.large)
                .swiftForgeFullWidth()
            }
        }
    }
}

struct TogglesPage: View {

    @State private var notifications = true
    @State private var sounds = false
    @State private var autoLock = true

    var body: some View {
        CatalogPageContainer {
            Specimen("States") {
                Toggle("Notifications", isOn: $notifications)
                Toggle("Sounds", isOn: $sounds)
                Toggle("Disabled on", isOn: .constant(true)).disabled(true)
                Toggle("Disabled off", isOn: .constant(false)).disabled(true)
            }
            Specimen("Tones") {
                Toggle("Auto-lock", isOn: $autoLock).toggleStyle(.swiftForge(tone: .success))
                Toggle("Erase after 10 attempts", isOn: $autoLock).toggleStyle(.swiftForge(tone: .danger))
            }
            Specimen("Without color") {
                Toggle("On", isOn: .constant(true))
                Toggle("Off", isOn: .constant(false))
            }
            .swiftForgeAccessibilitySimulation(differentiateWithoutColor: true)
        }
        .toggleStyle(.swiftForge)
    }
}

struct FieldsPage: View {

    @State private var name = ""
    @State private var email = "sam@"
    @State private var username = "sam"
    @State private var bio = ""
    @State private var password = ""
    @State private var amount = "120"

    var body: some View {
        CatalogPageContainer {
            Specimen("Text fields") {
                SwiftForgeTextField("Name", text: $name, prompt: Text("Jane Appleseed"))
                    .textContentType(.name)
                SwiftForgeTextField(
                    "Email", text: $email, prompt: Text("you@example.com"),
                    state: email.contains("@") && email.contains(".")
                        ? .success("Looks good.") : .error("Enter a valid email address.")
                ) {
                    Image(systemName: "envelope")
                }
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .swiftForgeClearButton(.whileEditing)
                SwiftForgeTextField("Username", text: $username, state: .helper("Visible to other people."))
                SwiftForgeTextField("Bio", text: $bio)
                    .swiftForgeCharacterLimit(80)
                    .swiftForgeOptionalField()
                SwiftForgeTextField(
                    "Amount", text: $amount, leading: { Image(systemName: "dollarsign") }, trailing: { Text("USD") }
                )
                .keyboardType(.decimalPad)
                SwiftForgeTextField("Disabled", text: .constant("Read only")).disabled(true)
            }
            Specimen("Secure field") {
                SwiftForgeSecureField(
                    "Password", text: $password, prompt: Text("At least 12 characters"),
                    state: password.isEmpty || password.count >= 12 ? .normal : .error("Use at least 12 characters.")
                )
                .textContentType(.newPassword)
            }
        }
    }
}

struct BannersPage: View {

    @State private var isShowingSuccess = true

    var body: some View {
        CatalogPageContainer {
            Specimen("Tones") {
                SwiftForgeBanner(.info, title: "New version available", message: "Update to get the latest components.")
                if isShowingSuccess {
                    SwiftForgeBanner(.success, title: "Changes saved", onDismiss: { isShowingSuccess = false })
                } else {
                    Button("Show success banner") { isShowingSuccess = true }.buttonStyle(.swiftForge(.plain))
                }
                SwiftForgeBanner(.warning, title: "Unsaved changes", message: "You have edits that haven't been saved.") {
                    Button("Save") {}
                    Button("Discard") {}
                }
                SwiftForgeBanner(.danger, title: "Couldn't save changes", message: "Check your connection and try again.") {
                    Button("Retry") {}
                }
                SwiftForgeBanner(.neutral, title: "Maintenance tonight", message: "The service is unavailable from 2 to 3 AM.")
            }
            Specimen("Prominent") {
                SwiftForgeBanner(.danger, title: "Payment failed", message: "Your card was declined.", prominence: .prominent) {
                    Button("Update card") {}
                }
            }
        }
    }
}

struct BadgesPage: View {

    @State private var count = 3

    var body: some View {
        CatalogPageContainer {
            Specimen("Text") {
                FlowRow {
                    ForEach(SwiftForgeTone.allCases, id: \.self) { tone in
                        SwiftForgeBadge(tone.rawValue.capitalized, tone: tone)
                    }
                }
                FlowRow {
                    ForEach(SwiftForgeTone.allCases, id: \.self) { tone in
                        SwiftForgeBadge(tone.rawValue.capitalized, tone: tone, prominence: .prominent)
                    }
                }
                SwiftForgeBadge("Beta", tone: .accent, systemImage: "flask")
            }
            Specimen("Counts") {
                HStack(spacing: 24) {
                    SwiftForgeBadge(count: count)
                    SwiftForgeBadge(count: 1_250)
                    SwiftForgeBadge.dot()
                    Button("Inbox", systemImage: "tray") {}
                        .buttonStyle(.swiftForgeIcon(.tinted))
                        .swiftForgeBadge(count: count)
                }
                Stepper("Count: \(count)", value: $count, in: 0...150)
            }
            Specimen("Sizes") {
                ForEach([ControlSize.small, .regular, .large], id: \.self) { size in
                    SwiftForgeFlowLayout(spacing: 12) {
                        SwiftForgeBadge("New", tone: .info)
                        SwiftForgeBadge(count: count)
                        SwiftForgeBadge.dot()
                    }
                    .controlSize(size)
                }
            }
        }
    }
}

struct CardsPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        CatalogPageContainer {
            ForEach(SwiftForgeCardStyle.allCases, id: \.self) { style in
                SwiftForgeCard(style: style) {
                    CardContent(title: style.rawValue.capitalized, subtitle: "Your subscription renews on March 4.")
                }
            }
            Button {
            } label: {
                CardContent(title: "Tappable card", subtitle: "A button styled as a card.")
            }
            .buttonStyle(.swiftForgeCard(.outlined))
            SwiftForgeCard(style: .outlined) {
                VStack(alignment: .leading, spacing: 0) {
                    Rectangle().fill(theme.colors.accent.subtle).frame(height: 120)
                    CardContent(title: "Edge to edge", subtitle: "Card padding removed for media.").padding(
                        theme.spacing.cardPadding)
                }
            }
            .swiftForgeCardPadding(.none)
            SwiftForgeCard(style: .elevated) {
                Text("Your subscription renews on March 4.")
            } header: {
                Text("Header and footer")
            } footer: {
                Button("Manage") {}.buttonStyle(.swiftForge(.tinted)).controlSize(.small)
            }
            GroupBox("GroupBox as a card") {
                ProgressView(value: 0.62).progressViewStyle(.swiftForgeLinear)
            }
            .groupBoxStyle(.swiftForgeCard(.outlined))
        }
    }
}

struct CardContent: View {
    let title: String
    let subtitle: String
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            Text(title).swiftForgeTextStyle(\.headline).foregroundStyle(theme.colors.textPrimary)
            Text(subtitle).swiftForgeTextStyle(\.subheadline).foregroundStyle(theme.colors.textSecondary)
        }
    }
}

struct ProgressPage: View {

    @State private var value = 0.4

    var body: some View {
        CatalogPageContainer {
            Specimen("Linear") {
                ProgressView(value: value) {
                    Text("Uploading")
                } currentValueLabel: {
                    Text(value, format: .percent.precision(.fractionLength(0)))
                }
                .progressViewStyle(.swiftForgeLinear)
                ProgressView(value: value).progressViewStyle(.swiftForgeLinear(tone: .success)).controlSize(.large)
            }
            Specimen("Circular") {
                HStack(spacing: 24) {
                    ProgressView(value: value).progressViewStyle(.swiftForgeCircular).controlSize(.small)
                    ProgressView(value: value).progressViewStyle(.swiftForgeCircular)
                    ProgressView(value: value) {
                        EmptyView()
                    } currentValueLabel: {
                        Text(value, format: .percent.precision(.fractionLength(0)))
                    }
                    .progressViewStyle(.swiftForgeCircular)
                    .controlSize(.large)
                    ProgressView().controlSize(.large)
                }
            }
            Slider(value: $value)
        }
    }
}

struct SkeletonPage: View {

    @State private var isLoading = true

    var body: some View {
        CatalogPageContainer {
            Toggle("Loading", isOn: $isLoading)
            ForEach(0..<3) { _ in
                SwiftForgeCard {
                    CardContent(title: "Jane Appleseed", subtitle: "Shared three photos with you")
                }
                .swiftForgeSkeleton(isActive: isLoading)
            }
            HStack {
                SwiftForgeSkeletonShape(.circle).frame(width: 48, height: 48)
                VStack(alignment: .leading) {
                    SwiftForgeSkeletonShape().frame(width: 180, height: 14)
                    SwiftForgeSkeletonShape().frame(width: 120, height: 14)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Loading profile")
        }
    }
}

struct LoadingOverlayPage: View {

    @State private var isSubmitting = false

    var body: some View {
        CatalogPageContainer {
            SwiftForgeCard(style: .elevated) {
                VStack(alignment: .leading, spacing: 12) {
                    CardContent(title: "Order summary", subtitle: "2 items · $48.00")
                    Button("Place order") {
                        isSubmitting = true
                        Task {
                            try? await Task.sleep(for: .seconds(2))
                            isSubmitting = false
                        }
                    }
                    .buttonStyle(.swiftForge())
                    .swiftForgeFullWidth()
                }
            }
            .swiftForgeLoadingOverlay(isPresented: isSubmitting, message: "Placing your order…")
        }
    }
}

struct DividersPage: View {
    var body: some View {
        CatalogPageContainer {
            SwiftForgeCard(style: .outlined) {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Notifications", systemImage: "bell")
                    SwiftForgeDivider(inset: .leading(32))
                    Label("Privacy", systemImage: "hand.raised")
                    SwiftForgeDivider(inset: .leading(32))
                    Label("Storage", systemImage: "internaldrive")
                }
            }
            HStack {
                Text("Left")
                SwiftForgeDivider().frame(height: 24)
                Text("Right")
            }
            SwiftForgeDivider(emphasis: .strong)
            SwiftForgeDivider("or")
        }
    }
}

/// Lays out children in rows, wrapping to the next row when one is full.
struct FlowRow: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(width: proposal.width ?? .infinity, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(width: bounds.width, subviews: subviews) {
            var x = bounds.minX
            for index in row.indices {
                let size = subviews[index].sizeThatFits(.unspecified)
                subviews[index].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var indices: [Int] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    private func arrange(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows = [Row()]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            if !rows[rows.count - 1].indices.isEmpty, rows[rows.count - 1].width + spacing + size.width > width {
                rows.append(Row())
            }
            var row = rows.removeLast()
            row.width += (row.indices.isEmpty ? 0 : spacing) + size.width
            row.height = max(row.height, size.height)
            row.indices.append(index)
            rows.append(row)
        }
        return rows
    }
}
