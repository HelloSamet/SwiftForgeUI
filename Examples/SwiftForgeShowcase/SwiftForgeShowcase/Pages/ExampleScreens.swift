//
//  ExampleScreens.swift
//  SwiftForgeShowcase
//
//  Three real-world screens built only from SwiftForgeUI components and
//  SwiftUI containers: sign-in and sign-up, settings, and an inbox with a
//  detail screen. Anything a screen needs that the library lacks is a gap
//  to fix in the library, not to work around here.
//

import SwiftForgeUI
import SwiftUI

// MARK: - Sign in and sign up

struct AuthExample: View {

    enum Mode: String, CaseIterable { case signIn = "Sign In", signUp = "Create Account" }

    @Environment(SwiftForgePresenter.self) private var presenter
    @Environment(\.swiftForgeTheme) private var theme
    @State private var mode = Mode.signIn
    @State private var email = ""
    @State private var password = ""
    @State private var acceptsTerms = false
    @State private var showsErrors = false
    @State private var error: String?
    @State private var awaitsCode = false
    @State private var code = ""

    var body: some View {
        CatalogPageContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(mode == .signIn ? "Welcome back" : "Create your account")
                    .swiftForgeTextStyle(\.largeTitle, color: \.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                Text(mode == .signIn ? "Sign in to continue." : "It takes less than a minute.")
                    .swiftForgeTextStyle(\.body, color: \.textSecondary)
            }
            if awaitsCode {
                verification
            } else {
                form
            }
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: theme.spacing.section) {
            SwiftForgeSegmentedControl("Mode", selection: $mode, options: Mode.allCases) { Text($0.rawValue) }
            if let error {
                SwiftForgeBanner(.danger, title: "Couldn't sign in", message: error, onDismiss: { self.error = nil })
            }
            VStack(spacing: theme.spacing.component) {
                SwiftForgeTextField("Email", text: $email, prompt: Text(verbatim: "you@example.com"), state: emailState) {
                    Image(systemName: "envelope")
                }
                .keyboardType(.emailAddress)
                .textContentType(.username)
                .textInputAutocapitalization(.never)
                .swiftForgeClearButton(.whileEditing)
                SwiftForgeSecureField("Password", text: $password, state: passwordState)
                    .textContentType(mode == .signIn ? .password : .newPassword)
                    .swiftForgePasswordStrength(mode == .signUp && !password.isEmpty ? PasswordRules.strength(of: password) : nil)
                if mode == .signUp {
                    Toggle("I agree to the Terms of Service", isOn: $acceptsTerms)
                        .toggleStyle(.swiftForgeCheckbox)
                        .swiftForgeDescription(showsErrors && !acceptsTerms ? Text("Required to create an account.") : nil)
                }
            }
            VStack(spacing: theme.spacing.sm) {
                SwiftForgeButton(mode == .signIn ? "Sign In" : "Create Account") {
                    try await submit()
                } onError: { _ in
                    error = "The email or password is incorrect."
                }
                .controlSize(.large)
                if mode == .signIn {
                    Button("Forgot password?") {}.buttonStyle(.swiftForge(.plain))
                }
                SwiftForgeDivider("or")
                Button("Continue with Passkey", systemImage: "person.badge.key") {}
                    .buttonStyle(.swiftForge(.outlined))
                    .controlSize(.large)
            }
            .swiftForgeFullWidth()
        }
    }

    private var verification: some View {
        VStack(alignment: .leading, spacing: theme.spacing.section) {
            SwiftForgeOTPField(
                "Verification code", code: $code,
                state: code.count == 6 && code != "123456"
                    ? .error("That code isn't right.") : .helper("Sent to \(email). Try 123456.")
            )
            .onChange(of: code) { _, code in
                guard code == "123456" else { return }
                presenter.show(SwiftForgeToast(.success, title: "Account created"))
                awaitsCode = false
                self.code = ""
            }
            Button("Use a different email") { awaitsCode = false }
                .buttonStyle(.swiftForge(.plain))
        }
    }

    private var emailState: SwiftForgeFieldState {
        guard showsErrors else { return .normal }
        return email.contains("@") && email.contains(".") ? .normal : .error("Enter an email address like you@example.com.")
    }

    private var passwordState: SwiftForgeFieldState {
        guard showsErrors else { return mode == .signUp ? .helper("Use 12 or more characters.") : .normal }
        return password.count >= (mode == .signUp ? 12 : 1) ? .normal : .error("Use at least 12 characters.")
    }

    private func submit() async throws {
        showsErrors = true
        guard emailState == .normal, passwordState != .error("Use at least 12 characters.") else { return }
        if mode == .signUp {
            guard acceptsTerms else { return }
            try await Task.sleep(for: .milliseconds(600))
            presenter.show(SwiftForgeToast(.info, title: "Code sent", message: "Check your messages."))
            awaitsCode = true
        } else {
            try await Task.sleep(for: .seconds(1))
            if password.count < 8 { throw SignInError.invalidCredentials }
            presenter.show(SwiftForgeToast(.success, title: "Signed in"))
        }
    }

    enum SignInError: Error { case invalidCredentials }
}

// MARK: - Settings

struct SettingsExample: View {

    @Environment(SwiftForgePresenter.self) private var presenter
    @State private var notifications = true
    @State private var sounds = false
    @State private var appearance = "System"
    @State private var language = "English"
    @State private var textSize = 1.0
    @State private var backupsKept = 5

    var body: some View {
        List {
            Section {
                NavigationLink {
                    SwiftForgeEmptyState(
                        "Profile", systemImage: "person.crop.circle", description: Text("Edit your profile here."))
                } label: {
                    SwiftForgeListRow("Ada Lovelace", subtitle: Text(verbatim: "ada@example.com")) {
                        SwiftForgeAvatar(name: "Ada Lovelace", status: .online)
                    } trailing: {
                        SwiftForgeBadge("Pro", tone: .accent)
                    }
                }
            }
            .swiftForgeListRowBackground()
            Section {
                Toggle("Notifications", isOn: $notifications)
                    .swiftForgeDescription("Banners for messages and mentions.")
                Toggle("Sounds", isOn: $sounds).disabled(!notifications)
            } header: {
                SwiftForgeSectionHeader("Notifications")
            }
            .toggleStyle(.swiftForge)
            .swiftForgeListRowBackground()
            Section {
                SwiftForgeSegmentedControl("Appearance", selection: $appearance, options: ["Light", "Dark", "System"]) {
                    Text($0)
                }
                SwiftForgePicker("Language", selection: $language, options: ["English", "Türkçe", "Deutsch", "日本語"]) {
                    Text($0)
                }
                SwiftForgeSlider("Text size", value: $textSize, in: 0.8...1.6, step: 0.1) {
                    Text($0, format: .percent.precision(.fractionLength(0)))
                }
            } header: {
                SwiftForgeSectionHeader("Display")
            }
            .swiftForgeListRowBackground()
            Section {
                SwiftForgeStepper("Backups to keep", value: $backupsKept, in: 1...30) { Text($0, format: .number) }
                LabeledContent("Storage used") { Text("12.4 GB of 64 GB") }
                    .labeledContentStyle(.swiftForge)
                ProgressView(value: 12.4, total: 64).progressViewStyle(.swiftForgeLinear)
            } header: {
                SwiftForgeSectionHeader("Storage")
            }
            .swiftForgeListRowBackground()
            Section {
                DisclosureGroup("About") {
                    LabeledContent("Version", value: "2.4.1").labeledContentStyle(.swiftForge)
                    LabeledContent("Build", value: "1024").labeledContentStyle(.swiftForge)
                }
                .disclosureGroupStyle(.swiftForge)
            }
            .swiftForgeListRowBackground()
            Section {
                Button("Sign Out") {
                    presenter.present(
                        SwiftForgeAlertDialog(
                            title: "Sign out?", message: "You'll need your password to sign back in.",
                            actions: [.init("Sign Out"), .cancel()]))
                }
                .buttonStyle(.swiftForge(.plain))
                Button("Delete Account", role: .destructive) {
                    presenter.present(
                        SwiftForgeAlertDialog(
                            title: "Delete your account?", message: "Your messages and settings are erased. You can't undo this.",
                            systemImage: "trash", tone: .danger,
                            actions: [
                                .init("Delete Account", role: .destructive) {
                                    presenter.show(SwiftForgeToast(.neutral, title: "Account deletion requested"))
                                },
                                .cancel(),
                            ]))
                }
                .buttonStyle(.swiftForge(.plain))
            }
            .swiftForgeListRowBackground()
        }
        .swiftForgeListStyle()
    }
}

// MARK: - Inbox: list and detail

struct InboxMessage: Identifiable, Hashable {
    let id: Int
    let sender: String
    let subject: String
    let preview: String
    var isUnread: Bool
    var isFlagged: Bool
}

struct InboxExample: View {

    enum Filter: String, CaseIterable { case all = "All", unread = "Unread", flagged = "Flagged" }

    @Environment(SwiftForgePresenter.self) private var presenter
    @Environment(\.swiftForgeTheme) private var theme
    @State private var messages = InboxExample.sample
    @State private var query = ""
    @State private var filter: Filter? = .all
    @State private var isLoading = true

    var body: some View {
        List {
            Section {
                SwiftForgeSearchField(text: $query, showsCancelButton: false)
                SwiftForgeChipGroup("Show", selection: $filter, options: Filter.allCases) { Text($0.rawValue) }
            }
            .listRowSeparator(.hidden)
            .swiftForgeListRowBackground()
            if visible.isEmpty {
                SwiftForgeEmptyState(
                    "No Messages", systemImage: query.isEmpty ? "tray" : "magnifyingglass",
                    description: Text(query.isEmpty ? "Messages you receive appear here." : "Try a different search.")
                ) {
                    if !query.isEmpty || filter != .all {
                        Button("Clear Filters") {
                            query = ""
                            filter = .all
                        }
                    }
                }
                .listRowBackground(Color.clear)
            } else {
                ForEach(visible) { message in
                    NavigationLink(value: message) {
                        SwiftForgeListRow(LocalizedStringKey(message.sender), subtitle: Text(message.subject)) {
                            SwiftForgeAvatar(name: message.sender).controlSize(.small)
                        } trailing: {
                            if message.isUnread { SwiftForgeBadge.dot(tone: .accent) }
                        }
                        .swiftForgeSkeleton(isActive: isLoading)
                    }
                    .swipeActions {
                        Button("Archive", systemImage: "archivebox") { archive(message) }
                            .tint(theme.colors.info.solid)
                    }
                    .swipeActions(edge: .leading) {
                        Button(message.isUnread ? "Mark Read" : "Mark Unread", systemImage: "envelope.badge") {
                            toggleUnread(message)
                        }
                    }
                }
                .swiftForgeListRowBackground()
            }
        }
        .swiftForgeListStyle()
        .navigationDestination(for: InboxMessage.self) { message in
            InboxDetail(message: message) { archive(message) }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(800))
            isLoading = false
        }
    }

    private var visible: [InboxMessage] {
        messages.filter { message in
            switch filter ?? .all {
            case .all: true
            case .unread: message.isUnread
            case .flagged: message.isFlagged
            }
        }
        .filter { query.isEmpty || "\($0.sender) \($0.subject)".localizedStandardContains(query) }
    }

    private func archive(_ message: InboxMessage) {
        guard let index = messages.firstIndex(of: message) else { return }
        messages.remove(at: index)
        presenter.show(
            SwiftForgeToast(
                .neutral, title: "Conversation archived",
                action: .init("Undo") { restore(message, at: index) }))
    }

    private func restore(_ message: InboxMessage, at index: Int) {
        messages.insert(message, at: min(index, messages.count))
    }

    private func toggleUnread(_ message: InboxMessage) {
        guard let index = messages.firstIndex(of: message) else { return }
        messages[index].isUnread.toggle()
    }

    static let sample: [InboxMessage] = [
        InboxMessage(
            id: 1, sender: "Grace Hopper", subject: "Compiler review notes", preview: "I went through the parser changes…",
            isUnread: true, isFlagged: true),
        InboxMessage(
            id: 2, sender: "Katherine Johnson", subject: "Trajectory numbers", preview: "Attached are the figures for…",
            isUnread: true, isFlagged: false),
        InboxMessage(
            id: 3, sender: "Alan Turing", subject: "Lunch on Friday?", preview: "There's a new place near the…", isUnread: false,
            isFlagged: false),
        InboxMessage(
            id: 4, sender: "Margaret Hamilton", subject: "Release checklist", preview: "Before we ship, let's confirm…",
            isUnread: false, isFlagged: true),
    ]
}

struct InboxDetail: View {

    let message: InboxMessage
    let onArchive: () -> Void

    @Environment(SwiftForgePresenter.self) private var presenter
    @Environment(\.dismiss) private var dismiss
    @Environment(\.swiftForgeTheme) private var theme
    @State private var reply = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.section) {
                SwiftForgeNavigationHeader(LocalizedStringKey(message.subject)) {
                    if message.isFlagged { SwiftForgeBadge("Flagged", tone: .warning, systemImage: "flag.fill") }
                }
                SwiftForgeListRow(LocalizedStringKey(message.sender), subtitle: Text("To: me · Today")) {
                    SwiftForgeAvatar(name: message.sender, status: .online)
                } trailing: {
                    EmptyView()
                }
                Text(message.preview + " The rest of the message continues here, long enough to wrap onto several lines.")
                    .swiftForgeTextStyle(\.body, color: \.textPrimary)
                SwiftForgeTextArea("Reply", text: $reply, prompt: Text("Write a reply…"), lineLimit: 3...6)
                HStack(spacing: theme.spacing.sm) {
                    Button("Archive", systemImage: "archivebox") {
                        onArchive()
                        dismiss()
                    }
                    .buttonStyle(.swiftForge(.outlined))
                    Button("Send", systemImage: "paperplane") {
                        reply = ""
                        presenter.show(SwiftForgeToast(.success, title: "Reply sent"))
                    }
                    .buttonStyle(.swiftForge(.filled))
                    .disabled(reply.isEmpty)
                }
                .swiftForgeFullWidth()
            }
        }
        .swiftForgeScreen()
    }
}
