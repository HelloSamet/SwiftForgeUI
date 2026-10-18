//
//  UITestFixtures.swift
//  SwiftForgeShowcase
//
//  Deterministic screens for XCUITest, opened with the launch argument
//  `-uiTestFixture <rawValue>`.
//

import SwiftForgeUI
import SwiftUI

enum UITestFixture: String, CaseIterable {
    case buttons
    case toggles
    case fields
    case semantics
    case auditButtons
    case auditFields
    case auditFeedback
    case auditCards
    case themeGallery
    case themeComparison
    case stateMatrix
    case controls
    case auditSelection
    case auditChoices
    case auditInputs
    case display
    case auditDisplay
    case listRowsPage
    case nativeListBaseline
    case overlays
    case navigation
    case auditToasts
    case auditDialog
    case auditTabBars
    case auditNavigationHeader
    case authScreen
    case settingsScreen
    case inboxScreen
    case p2
    case auditP2
    case auditTooltip
    case auditStructure
    case stress
    case stressNative

    /// `-stressKind N` limits the stress page to one kind of row.
    static var stressKind: Int? { UserDefaults.standard.object(forKey: "stressKind") as? Int }

    static var fromLaunchArguments: UITestFixture? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-uiTestFixture"), arguments.indices.contains(index + 1) else {
            return nil
        }
        return UITestFixture(rawValue: arguments[index + 1])
    }

    @MainActor @ViewBuilder
    var view: some View {
        switch self {
        case .buttons: ButtonFixture()
        case .toggles: ToggleFixture()
        case .fields: FieldFixture()
        case .semantics: SemanticsFixture()
        case .auditButtons:
            AuditFixture {
                Specimens.Buttons()
                Specimens.Toggles()
            }
        case .auditFields: AuditFixture { Specimens.TextFields() }
        case .auditFeedback:
            AuditFixture {
                Specimens.Banners()
                Specimens.Badges()
            }
        case .themeGallery: NavigationStack { ThemeGalleryPage() }
        case .themeComparison: NavigationStack { ThemeComparisonPage() }
        case .stateMatrix: NavigationStack { StateMatrixPage() }
        case .auditCards:
            AuditFixture {
                Specimens.Cards()
                Specimens.Progress()
            }
        case .controls: ControlFixture()
        case .auditSelection:
            AuditFixture {
                Specimens.Checkboxes()
                Specimens.RadioGroups()
            }
        case .auditChoices:
            AuditFixture {
                Specimens.Chips()
                Specimens.SegmentedControls()
            }
        case .display: DisplayFixture()
        case .listRowsPage: NavigationStack { ListRowsPage() }
        case .nativeListBaseline: NavigationStack { NativeListBaseline() }
        case .overlays: OverlayFixture()
        case .navigation: NavigationFixture()
        // Full screen, over content without text: the audit also measures
        // content a modal hides from VoiceOver, and a short frame would clip
        // a toast at large sizes.
        case .auditToasts:
            Specimens.Presented(
                toast: SwiftForgeToast(
                    .neutral, title: "Conversation archived", message: "It's in the Archive folder.",
                    action: .init("Undo") {}),
                height: 600, showsContent: false)
        case .auditDialog:
            Specimens.Presented(
                dialog: SwiftForgeAlertDialog(
                    title: "Delete this draft?", message: "You can't undo this.", systemImage: "trash", tone: .danger,
                    actions: [.init("Delete", role: .destructive), .init("Save"), .cancel()]),
                height: 600, showsContent: false)
        case .auditTabBars: AuditFixture { Specimens.TabBars() }
        case .authScreen: ExampleScreenFixture { AuthExample() }
        case .settingsScreen: ExampleScreenFixture { SettingsExample() }
        case .inboxScreen: ExampleScreenFixture { InboxExample() }
        case .p2: P2Fixture()
        case .auditStructure:
            AuditFixture {
                Specimens.Skeleton()
                Specimens.Dividers()
                Specimens.Surfaces()
                SwiftForgeCard { Specimens.CardText(title: "Order #1042", subtitle: "Arrives Thursday") }
                    .frame(height: 160)
                    .swiftForgeLoadingOverlay(isPresented: true, message: "Saving…")
            }
        case .stress: StressTestPage(autoScroll: true, kind: Self.stressKind)
        case .stressNative: StressTestPage(autoScroll: true, native: true, kind: Self.stressKind)
        case .auditP2:
            AuditFixture {
                Specimens.Steppers()
                Specimens.OTPFields()
                Specimens.Ratings()
                Specimens.Accordions()
            }
        case .auditTooltip: AuditFixture { TooltipAuditSpecimen() }
        case .auditNavigationHeader:
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        SwiftForgeNavigationHeader("Inbox", subtitle: Text("12 unread")) {
                            SwiftForgeAvatar(name: "Ada Lovelace").controlSize(.small)
                        }
                        ForEach(0..<6, id: \.self) { SwiftForgeListRow("Message \($0)") }
                    }
                    .padding(.horizontal)
                }
            }
        case .auditDisplay:
            AuditFixture {
                Specimens.ListRows()
                Specimens.CardSlots()
                Specimens.BadgeSizes()
                Specimens.LabeledDividers()
                Specimens.Avatars()
            }
        case .auditInputs:
            AuditFixture {
                Specimens.TextAreas()
                Specimens.SearchFields()
                Specimens.Sliders()
                Specimens.Pickers()
                Specimens.PasswordStrength()
            }
        }
    }
}

/// A toggle whose state is mirrored in a label, and a disabled one.
private struct ToggleFixture: View {

    @State private var isOn = false
    @State private var disabledIsOn = false

    var body: some View {
        VStack(spacing: 16) {
            Toggle("Wi-Fi", isOn: $isOn)
            Toggle("Locked", isOn: $disabledIsOn).disabled(true)
            Text(verbatim: "wifi:\(isOn) locked:\(disabledIsOn)")
                .accessibilityIdentifier("state")
        }
        .toggleStyle(.swiftForge)
        .padding()
    }
}

/// Counts taps on buttons in each interaction state.
private struct ButtonFixture: View {

    @State private var normalTaps = 0
    @State private var loadingTaps = 0
    @State private var disabledTaps = 0
    @State private var asyncRuns = 0

    var body: some View {
        VStack(spacing: 16) {
            Button("Normal") { normalTaps += 1 }
                .buttonStyle(.swiftForge())
                .accessibilityIdentifier("normal")
            Button("Loading") { loadingTaps += 1 }
                .buttonStyle(.swiftForge())
                .swiftForgeLoading(true)
                .accessibilityIdentifier("loading")
            Button("Disabled") { disabledTaps += 1 }
                .buttonStyle(.swiftForge())
                .disabled(true)
                .accessibilityIdentifier("disabled")
            SwiftForgeButton("Async") {
                asyncRuns += 1
                try await Task.sleep(for: .seconds(1))
            }
            .accessibilityIdentifier("async")
            Button("Small") {}
                .buttonStyle(.swiftForge(.plain))
                .controlSize(.small)
                .accessibilityIdentifier("small")

            Text("normal:\(normalTaps) loading:\(loadingTaps) disabled:\(disabledTaps) async:\(asyncRuns)")
                .accessibilityIdentifier("counts")
        }
        .padding()
    }
}

private struct FieldFixture: View {

    @State private var email = ""
    @State private var password = ""
    @State private var code = ""
    @State private var hasSubmitted = false

    var body: some View {
        VStack(spacing: 16) {
            SwiftForgeTextField(
                "Email", text: $email,
                state: hasSubmitted && !email.contains("@") ? .error("Enter a valid email address.") : .normal
            )
            .accessibilityIdentifier("email")
            SwiftForgeSecureField("Password", text: $password)
                .accessibilityIdentifier("password")
            SwiftForgeTextField("Code", text: $code)
                .swiftForgeCharacterLimit(6)
                .accessibilityIdentifier("code")
            Button("Submit") { hasSubmitted = true }
                .buttonStyle(.swiftForge())
                .accessibilityIdentifier("submit")
            Text(password).accessibilityIdentifier("passwordEcho")
        }
        .padding()
    }
}

/// A specimen on the theme's canvas, as the accessibility audit sees it.
private struct AuditFixture<Content: View>: View {

    @ViewBuilder let content: Content
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) { content }
                .padding()
        }
        .background(theme.colors.canvas)
    }
}

/// Elements whose VoiceOver semantics the UI tests assert.
private struct SemanticsFixture: View {
    var body: some View {
        VStack(spacing: 16) {
            SwiftForgeBanner(.danger, title: "Couldn't save", message: "Try again.", announcesAppearance: false)
            SwiftForgeBanner(.danger, title: "Kaydedilemedi", announcesAppearance: false)
                .environment(\.locale, Locale(identifier: "tr"))
            SwiftForgeBadge(count: 1_250)
            Button("Delete", role: .destructive) {}.buttonStyle(.swiftForge())
            Button("Close", systemImage: "xmark") {}.buttonStyle(.swiftForgeIcon())
            Button("Inbox", systemImage: "tray") {}
                .buttonStyle(.swiftForgeIcon(.tinted))
                .swiftForgeBadge(count: 3)
            SwiftForgeTextField("Email", text: .constant(""), prompt: Text("you@example.com"))
            SwiftForgeCard { Text("Decorative divider below") }
            SwiftForgeDivider()
        }
        .padding()
    }
}

/// Selection and input controls whose state is mirrored in a label.
private struct ControlFixture: View {

    @State private var terms = false
    @State private var toppings = [false, true]
    @State private var delivery = "Standard"
    @State private var cuisines: Set<String> = []
    @State private var recipients = ["Ada Lovelace", "Grace Hopper"]
    @State private var period = "Week"
    @State private var volume = 40.0
    @State private var price = 100.0...300.0
    @State private var query = ""
    @State private var searched = ""
    @State private var country = "Japan"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Terms", isOn: $terms).toggleStyle(.swiftForgeCheckbox)
                Toggle(sources: $toppings, isOn: \.self) { Text("All toppings") }.toggleStyle(.swiftForgeCheckbox)
                SwiftForgeRadioGroup(
                    "Delivery", selection: $delivery, options: ["Standard", "Express", "Pickup"], axis: .horizontal
                ) { Text($0) }
                SwiftForgeChipGroup("Cuisine", selection: $cuisines, options: ["Thai", "Turkish"]) { Text($0) }
                HStack {
                    ForEach(recipients, id: \.self) { name in
                        SwiftForgeChip(name, onRemove: { recipients.removeAll { $0 == name } })
                    }
                }
                SwiftForgeSegmentedControl("Period", selection: $period, options: ["Day", "Week", "Month"]) { Text($0) }
                SwiftForgeSlider("Volume", value: $volume, in: 0...100, step: 10) { Text(Int($0), format: .number) }
                SwiftForgeRangeSlider("Price", value: $price, in: 0...500, step: 50)
                SwiftForgeSearchField(text: $query, debounce: .milliseconds(200)) { searched = $0 }
                SwiftForgePicker("Country", selection: $country, options: ["Germany", "Japan", "Türkiye"]) { Text($0) }
                Text(verbatim: state)
                    .accessibilityIdentifier("state")
            }
            .padding()
        }
    }

    private var state: String {
        [
            "terms:\(terms)", "toppings:\(toppings.map { $0 ? "1" : "0" }.joined())", "delivery:\(delivery)",
            "cuisines:\(cuisines.sorted().joined(separator: ","))", "recipients:\(recipients.count)", "period:\(period)",
            "volume:\(Int(volume))", "price:\(Int(price.lowerBound))-\(Int(price.upperBound))", "searched:\(searched)",
            "country:\(country)",
        ].joined(separator: " ")
    }
}

/// Display components whose VoiceOver semantics the UI tests assert.
private struct DisplayFixture: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                SwiftForgeAvatar(name: "Ada Lovelace", status: .online)
                SwiftForgeAvatarGroup(
                    ["Ada Lovelace", "Grace Hopper", "Alan Turing", "Linus Pauling"].map { SwiftForgeAvatar(name: $0) },
                    maxVisible: 2)
                SwiftForgeSectionHeader("Account")
                SwiftForgeListRow("Notifications", subtitle: Text("Banners and sounds"), systemImage: "bell", accessory: .chevron)
                SwiftForgeListRow("English", accessory: .checkmark)
                SwiftForgeDivider("or")
                HStack {
                    Toggle("Hidden switch", isOn: .constant(true)).labelsHidden().toggleStyle(.swiftForge)
                    Toggle("Hidden checkbox", isOn: .constant(true)).labelsHidden().toggleStyle(.swiftForgeCheckbox)
                    Text(verbatim: "label-end").accessibilityIdentifier("labelEnd")
                }
                SwiftForgeEmptyState("No Messages", systemImage: "tray", description: Text("Messages appear here."))
                    .frame(height: 300)
            }
            .padding()
        }
    }
}

/// The List Rows page built from native components only, to tell findings
/// the accessibility audit makes about `List` itself from those about rows.
private struct NativeListBaseline: View {
    @State private var on = false
    var body: some View {
        List {
            Section("Settings") {
                NavigationLink {
                    Text(verbatim: "")
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
                LabeledContent("Wi-Fi", value: "Home")
                Toggle("Dark Mode", isOn: $on)
            }
            Section("Language") {
                ForEach(["English", "Türkçe", "Deutsch"], id: \.self) { Text($0) }
            }
            Section("Contacts") {
                ForEach(["Ada Lovelace", "Grace Hopper", "Katherine Johnson"], id: \.self) { name in
                    VStack(alignment: .leading) {
                        Text(name)
                        Text("Swipe for actions").foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

/// Toasts and dialogs whose results are mirrored in a label.
private struct OverlayFixture: View {

    @State private var presenter = SwiftForgePresenter()
    @State private var log = OverlayLog()

    var body: some View {
        VStack(spacing: 16) {
            Button("Show toast") { presenter.show(SwiftForgeToast(.success, title: "Message sent")) }
            Button("Show undo toast") {
                let log = log
                presenter.show(
                    SwiftForgeToast(.neutral, title: "Conversation archived", action: .init("Undo") { log.undos += 1 }))
            }
            Button("Show dialog") {
                let log = log
                presenter.present(
                    SwiftForgeAlertDialog(
                        title: "Delete this draft?", message: "You can't undo this.",
                        actions: [
                            .init("Delete", role: .destructive) { log.deletions += 1 },
                            .cancel { log.cancellations += 1 },
                        ]))
            }
            Text(verbatim: "undo:\(log.undos) deleted:\(log.deletions) canceled:\(log.cancellations)")
                .accessibilityIdentifier("log")
        }
        .buttonStyle(.swiftForge(.tinted))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .swiftForgePresentationHost(presenter)
    }
}

@MainActor
@Observable
private final class OverlayLog: Sendable {
    var undos = 0
    var deletions = 0
    var cancellations = 0
}

/// A scrolling screen with a navigation header, and a tab bar.
private struct NavigationFixture: View {

    enum Tab: Hashable, Sendable { case inbox, search, profile }

    @State private var tab = Tab.inbox

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SwiftForgeNavigationHeader("Inbox", subtitle: Text("12 unread"))
                    ForEach(0..<40, id: \.self) { index in
                        SwiftForgeListRow("Message \(index)", subtitle: Text("Preview"))
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
            .overlay(alignment: .center) {
                Text(verbatim: "tab:\(tab)").accessibilityIdentifier("tab").opacity(0.01)
            }
        }
    }
}

/// An example screen as the catalog shows it: in a navigation stack, with a
/// presenter for its toasts and dialogs.
private struct ExampleScreenFixture<Screen: View>: View {
    @ViewBuilder let screen: Screen
    @State private var presenter = SwiftForgePresenter()

    var body: some View {
        NavigationStack { screen }
            .swiftForgePresentationHost(presenter)
    }
}

/// P2 controls whose values are mirrored in a label.
private struct P2Fixture: View {
    @State private var guests = 2
    @State private var code = ""
    @State private var stars = 3.0
    @State private var isExpanded = false
    @State private var showsSheet = false
    @State private var showsTooltip = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SwiftForgeStepper("Guests", value: $guests, in: 1...12) { Text($0, format: .number) }
            SwiftForgeOTPField("Verification code", code: $code)
            SwiftForgeRating("Your rating", value: $stars)
            DisclosureGroup("Shipping", isExpanded: $isExpanded) { Text("Ships in two days.") }
                .disclosureGroupStyle(.swiftForge)
            Button("Open sheet") { showsSheet = true }.buttonStyle(.swiftForge(.tinted))
            Button("About fees", systemImage: "info.circle") { showsTooltip.toggle() }
                .buttonStyle(.swiftForgeIcon())
                .swiftForgeTooltip("A 2% fee applies to card payments.", isPresented: $showsTooltip)
            Text(verbatim: "guests:\(guests) code:\(code) stars:\(stars.formatted()) expanded:\(isExpanded)")
                .accessibilityIdentifier("state")
        }
        .padding()
        .swiftForgeBottomSheet(isPresented: $showsSheet, detents: [.medium]) {
            Text("Sheet content").padding()
        }
    }
}

/// A tooltip that opens once its anchor is on screen, for the audit.
private struct TooltipAuditSpecimen: View {
    @State private var showsTooltip = false

    var body: some View {
        HStack {
            Text("Total: $42.00")
            Button("About fees", systemImage: "info.circle") { showsTooltip.toggle() }
                .buttonStyle(.swiftForgeIcon())
                .swiftForgeTooltip("A 2% fee applies to card payments.", isPresented: $showsTooltip)
        }
        .task { showsTooltip = true }
    }
}
