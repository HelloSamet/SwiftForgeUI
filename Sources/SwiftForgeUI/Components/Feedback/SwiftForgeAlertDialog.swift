//
//  SwiftForgeAlertDialog.swift
//  SwiftForgeUI
//

import SwiftUI

/// A modal dialog with a title, a message, and one to three actions,
/// presented by a ``SwiftForgePresenter``.
///
/// ```swift
/// @Environment(SwiftForgePresenter.self) private var presenter
///
/// presenter.present(
///     SwiftForgeAlertDialog(
///         title: "Delete this draft?",
///         message: "You can't undo this.",
///         systemImage: "trash",
///         actions: [
///             .init("Delete", role: .destructive) { deleteDraft() },
///             .cancel(),
///         ]))
/// ```
///
/// The first action that isn't the cancel action is the primary one, drawn
/// as a filled button — in the danger tone if it's destructive. Others are
/// outlined, and the cancel action is plain. Two actions sit side by side
/// (cancel on the leading side) unless the text is large; otherwise they
/// stack with the primary action first.
///
/// While a dialog is shown, the screen behind it is dimmed, blocked, and
/// hidden from VoiceOver, which moves into the dialog. Escape — on a
/// keyboard or with the VoiceOver scrub gesture — and a tap outside run the
/// cancel action; a dialog without one can only be closed by its actions.
/// Return runs the primary action unless it's destructive.
///
/// - Do: use a dialog for decisions that need an answer before continuing,
///   with a branded look or illustration.
/// - Don't: use one for system-style confirmations where SwiftUI's own
///   `alert(_:isPresented:actions:message:)` fits; or for information that
///   doesn't need a decision — use a ``SwiftForgeToast`` or ``SwiftForgeBanner``.
public struct SwiftForgeAlertDialog: Identifiable, Sendable {

    /// A button in a dialog.
    public struct Action: Identifiable, Sendable {

        /// A stable identity within the dialog.
        public let id: UUID
        let title: SwiftForgeText
        let role: ButtonRole?
        let handler: @MainActor @Sendable () -> Void

        /// Creates an action.
        ///
        /// - Parameters:
        ///   - title: The button's title.
        ///   - role: `.destructive` for actions that delete or can't be
        ///     undone, `.cancel` for the action that backs out.
        ///   - handler: What the action does. The dialog is dismissed first.
        public init(
            _ title: LocalizedStringResource, role: ButtonRole? = nil,
            handler: @escaping @MainActor @Sendable () -> Void = {}
        ) {
            self.init(title: SwiftForgeText(title), role: role, handler: handler)
        }

        /// Creates an action with a title that isn't localized.
        @_disfavoredOverload
        public init<Title: StringProtocol>(
            _ title: Title, role: ButtonRole? = nil,
            handler: @escaping @MainActor @Sendable () -> Void = {}
        ) {
            self.init(title: SwiftForgeText(verbatim: String(title)), role: role, handler: handler)
        }

        init(title: SwiftForgeText, role: ButtonRole?, handler: @escaping @MainActor @Sendable () -> Void) {
            id = UUID()
            self.title = title
            self.role = role
            self.handler = handler
        }

        /// A cancel action titled "Cancel", in the library's language.
        public static func cancel(handler: @escaping @MainActor @Sendable () -> Void = {}) -> Action {
            Action(title: SwiftForgeText(SwiftForgeStrings.cancelResource), role: .cancel, handler: handler)
        }
    }

    /// The dialog's identity. Presenting a dialog whose identifier is already
    /// shown or waiting does nothing.
    public let id: String
    let title: SwiftForgeText
    let message: SwiftForgeText?
    let systemImage: String?
    let tone: SwiftForgeTone
    let actions: [Action]

    /// Creates a dialog.
    ///
    /// - Parameters:
    ///   - title: The question or statement, such as "Delete this draft?".
    ///   - message: The consequences or detail.
    ///   - systemImage: A symbol above the title.
    ///   - tone: The symbol's tone. Defaults to the accent.
    ///   - actions: One to three actions; any beyond three are ignored.
    ///   - id: An identity, to avoid presenting the same dialog twice. Defaults to a new one.
    public init(
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        systemImage: String? = nil,
        tone: SwiftForgeTone = .accent,
        actions: [Action],
        id: String = UUID().uuidString
    ) {
        self.init(
            title: SwiftForgeText(title), message: message.map(SwiftForgeText.init), systemImage: systemImage, tone: tone,
            actions: actions, id: id)
    }

    /// Creates a dialog with text that isn't localized.
    ///
    /// - Parameters:
    ///   - title: The question or statement.
    ///   - message: The consequences or detail.
    ///   - systemImage: A symbol above the title.
    ///   - tone: The symbol's tone. Defaults to the accent.
    ///   - actions: One to three actions; any beyond three are ignored.
    ///   - id: An identity, to avoid presenting the same dialog twice. Defaults to a new one.
    @_disfavoredOverload
    public init<Title: StringProtocol>(
        title: Title,
        message: String? = nil,
        systemImage: String? = nil,
        tone: SwiftForgeTone = .accent,
        actions: [Action],
        id: String = UUID().uuidString
    ) {
        self.init(
            title: SwiftForgeText(verbatim: String(title)), message: message.map { SwiftForgeText(verbatim: $0) },
            systemImage: systemImage, tone: tone, actions: actions, id: id)
    }

    private init(
        title: SwiftForgeText, message: SwiftForgeText?, systemImage: String?, tone: SwiftForgeTone, actions: [Action],
        id: String
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.tone = tone
        self.actions = Array(actions.prefix(3))
    }

    /// The action Escape and a tap outside run.
    var cancelAction: Action? { actions.first { $0.role == .cancel } }

    /// The filled action: the first one that isn't cancel.
    var primaryAction: Action? { actions.first { $0.role != .cancel } }
}

/// A dialog as drawn by the presentation host.
struct SwiftForgeAlertDialogView: View {

    let dialog: SwiftForgeAlertDialog
    let perform: @MainActor (SwiftForgeAlertDialog.Action) -> Void

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var widthScale: CGFloat = 1

    var body: some View {
        VStack(spacing: theme.spacing.md) {
            if let systemImage = dialog.systemImage {
                Image(systemName: systemImage)
                    .font(theme.typography.font(theme.typography.title1))
                    .foregroundStyle(theme.colors[dialog.tone].text)
                    .accessibilityHidden(true)
            }
            VStack(spacing: theme.spacing.xs) {
                dialog.title.text
                    .font(theme.typography.font(theme.typography.title3))
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if let message = dialog.message {
                    message.text
                        .font(theme.typography.font(theme.typography.body))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)

            actionsLayout {
                ForEach(orderedActions) { action in
                    button(for: action)
                }
            }
            .swiftForgeFullWidth()
            .padding(.top, theme.spacing.xs)
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: theme.components.dialog.width * widthScale)
        .modifier(
            SwiftForgeSurfaceModifier(
                level: .overlay, shape: .sheet, isOutlined: false, cornerRadius: theme.components.dialog.cornerRadius))
    }

    /// Side by side for two actions at regular sizes; stacked otherwise.
    private var isHorizontal: Bool {
        dialog.actions.count == 2 && !dynamicTypeSize.isAccessibilitySize
    }

    private var actionsLayout: AnyLayout {
        isHorizontal
            ? AnyLayout(HStackLayout(spacing: theme.spacing.xs))
            : AnyLayout(VStackLayout(spacing: theme.spacing.xs))
    }

    /// Cancel leads a row and ends a stack; the primary action is next to
    /// it in a row and first in a stack.
    private var orderedActions: [SwiftForgeAlertDialog.Action] {
        let cancel = dialog.actions.filter { $0.role == .cancel }
        let others = dialog.actions.filter { $0.role != .cancel }
        return isHorizontal ? cancel + others : others + cancel
    }

    @ViewBuilder
    private func button(for action: SwiftForgeAlertDialog.Action) -> some View {
        let button = Button(role: action.role) {
            perform(action)
        } label: {
            action.title.text
        }
        if action.role == .cancel {
            button
                .buttonStyle(.swiftForge(.plain, tone: .neutral))
                .keyboardShortcut(.cancelAction)
        } else if action.id == dialog.primaryAction?.id {
            if action.role == .destructive {
                button.buttonStyle(.swiftForge(.filled))
            } else {
                button.buttonStyle(.swiftForge(.filled)).keyboardShortcut(.defaultAction)
            }
        } else {
            button.buttonStyle(.swiftForge(.outlined))
        }
    }
}
