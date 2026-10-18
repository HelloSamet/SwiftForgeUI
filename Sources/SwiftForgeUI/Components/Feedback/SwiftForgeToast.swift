//
//  SwiftForgeToast.swift
//  SwiftForgeUI
//

import SwiftUI

/// A brief message about an action's result, shown at the bottom of the
/// screen by a ``SwiftForgePresenter``.
///
/// ```swift
/// @Environment(SwiftForgePresenter.self) private var presenter
///
/// presenter.show(SwiftForgeToast(.success, title: "Message sent"))
/// presenter.show(SwiftForgeToast(.neutral, title: "Conversation archived", action: .init("Undo") { unarchive() }))
/// ```
///
/// Toasts appear one at a time; later ones wait their turn. A toast leaves
/// after its ``DisplayDuration`` — twice as long with VoiceOver running —
/// unless it has an action: a person who needs more time must not lose the
/// chance to undo (WCAG 2.2.1). Toasts with an action or an indefinite
/// duration show a close button; any toast can be swiped away.
///
/// VoiceOver announces the tone, title, and message without moving focus.
///
/// - Do: confirm the result of something the person just did.
/// - Don't: use a toast for errors that need attention or for anything the
///   person must read; use a ``SwiftForgeBanner`` or ``SwiftForgeAlertDialog``.
public struct SwiftForgeToast: Identifiable, Sendable {

    /// How long a toast stays before leaving on its own.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum DisplayDuration: Sendable, Hashable {
        /// ``SwiftForgeToastTokens/shortDuration`` — 4 seconds by default.
        case short
        /// ``SwiftForgeToastTokens/longDuration`` — 8 seconds by default.
        case long
        /// Until dismissed.
        case indefinite
    }

    /// A button in a toast, such as "Undo".
    public struct Action: Sendable {
        let title: SwiftForgeText
        let handler: @MainActor @Sendable () -> Void

        /// Creates an action.
        ///
        /// - Parameters:
        ///   - title: The button's title.
        ///   - handler: What the action does. The toast is dismissed first.
        public init(_ title: LocalizedStringResource, handler: @escaping @MainActor @Sendable () -> Void) {
            self.title = SwiftForgeText(title)
            self.handler = handler
        }

        /// Creates an action with a title that isn't localized.
        @_disfavoredOverload
        public init<Title: StringProtocol>(_ title: Title, handler: @escaping @MainActor @Sendable () -> Void) {
            self.title = SwiftForgeText(verbatim: String(title))
            self.handler = handler
        }
    }

    /// The toast's identity. Showing a toast whose identifier is already
    /// shown or waiting does nothing.
    public let id: String
    let tone: SwiftForgeTone
    let title: SwiftForgeText
    let message: SwiftForgeText?
    let systemImage: String?
    let duration: DisplayDuration
    let action: Action?

    /// Creates a toast.
    ///
    /// - Parameters:
    ///   - tone: The toast's tone, which sets its icon.
    ///   - title: A short summary, such as "Message sent".
    ///   - message: Supporting detail.
    ///   - systemImage: An SF Symbol replacing the tone's icon.
    ///   - duration: How long the toast stays. Defaults to ``DisplayDuration/short``.
    ///   - action: A button, such as "Undo". Toasts with an action stay until dismissed.
    ///   - id: An identity, to avoid showing the same toast twice. Defaults to a new one.
    public init(
        _ tone: SwiftForgeTone = .neutral,
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        systemImage: String? = nil,
        duration: DisplayDuration = .short,
        action: Action? = nil,
        id: String = UUID().uuidString
    ) {
        self.init(
            tone: tone, title: SwiftForgeText(title), message: message.map(SwiftForgeText.init), systemImage: systemImage,
            duration: duration, action: action, id: id)
    }

    /// Creates a toast with text that isn't localized, such as a message from
    /// your server.
    ///
    /// - Parameters:
    ///   - tone: The toast's tone, which sets its icon.
    ///   - title: A short summary.
    ///   - message: Supporting detail.
    ///   - systemImage: An SF Symbol replacing the tone's icon.
    ///   - duration: How long the toast stays. Defaults to ``DisplayDuration/short``.
    ///   - action: A button, such as "Undo". Toasts with an action stay until dismissed.
    ///   - id: An identity, to avoid showing the same toast twice. Defaults to a new one.
    @_disfavoredOverload
    public init<Title: StringProtocol>(
        _ tone: SwiftForgeTone = .neutral,
        title: Title,
        message: String? = nil,
        systemImage: String? = nil,
        duration: DisplayDuration = .short,
        action: Action? = nil,
        id: String = UUID().uuidString
    ) {
        self.init(
            tone: tone, title: SwiftForgeText(verbatim: String(title)), message: message.map { SwiftForgeText(verbatim: $0) },
            systemImage: systemImage, duration: duration, action: action, id: id)
    }

    private init(
        tone: SwiftForgeTone, title: SwiftForgeText, message: SwiftForgeText?, systemImage: String?,
        duration: DisplayDuration, action: Action?, id: String
    ) {
        self.id = id
        self.tone = tone
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.duration = duration
        self.action = action
    }

    /// Whether the toast shows a close button: when it won't leave on its own.
    var isDismissible: Bool { action != nil || duration == .indefinite }

    /// The spoken summary, in the device language.
    var announcement: String {
        var text = "\(SwiftForgeStrings.toneNameString(tone)): \(title.string)"
        if let message { text += ". \(message.string)" }
        return text
    }

    /// How long the toast stays, or `nil` until dismissed.
    func displayTime(in tokens: SwiftForgeToastTokens) -> Duration? {
        switch duration {
        case .short: .seconds(tokens.shortDuration)
        case .long: .seconds(tokens.longDuration)
        case .indefinite: nil
        }
    }
}

/// A toast as drawn by the presentation host.
struct SwiftForgeToastView: View {

    let toast: SwiftForgeToast
    let onDismiss: @MainActor () -> Void

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @GestureState private var dragOffset: CGFloat = 0

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                // The icon and close button take a row of their own, so the
                // text keeps the toast's full width and never breaks inside a word.
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    HStack {
                        icon
                        Spacer(minLength: theme.spacing.xs)
                        closeButton
                    }
                    texts
                    actionButton
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                    icon
                    texts.frame(maxWidth: .infinity, alignment: .leading)
                    actionButton
                    closeButton
                }
            }
        }
        .padding(.leading, theme.spacing.md)
        .padding(.trailing, toast.isDismissible ? theme.spacing.xxs : theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .frame(maxWidth: theme.components.toast.maxWidth)
        .modifier(
            SwiftForgeSurfaceModifier(
                level: .overlay, shape: .card, isOutlined: false, cornerRadius: theme.components.toast.cornerRadius)
        )
        .offset(y: max(dragOffset, 0))
        .gesture(
            DragGesture(minimumDistance: theme.spacing.xs)
                .updating($dragOffset) { value, state, _ in state = value.translation.height }
                .onEnded { value in
                    if value.translation.height > theme.sizes.minimumHitTarget { onDismiss() }
                }
        )
        .accessibilityElement(children: .contain)
    }

    private var icon: some View {
        Image(systemName: toast.systemImage ?? SwiftForgeBanner<EmptyView>.icon(for: toast.tone))
            .foregroundStyle(theme.colors[toast.tone].text)
            .accessibilityHidden(true)
    }

    private var texts: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            toast.title.text
                .font(theme.typography.font(theme.typography.subheadline.weight(.semibold)))
                .foregroundStyle(theme.colors.textPrimary)
            if let message = toast.message {
                message.text
                    .font(theme.typography.font(theme.typography.footnote))
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var closeButton: some View {
        if toast.isDismissible {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(theme.typography.font(theme.typography.footnote.weight(.semibold)))
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(minWidth: theme.sizes.minimumHitTarget, minHeight: theme.sizes.minimumHitTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(SwiftForgeStrings.close)
        }
    }

    @ViewBuilder
    private var actionButton: some View {
        if let action = toast.action {
            Button {
                onDismiss()
                action.handler()
            } label: {
                action.title.text
            }
            .buttonStyle(.swiftForge(.plain, tone: toast.tone == .neutral ? .accent : toast.tone))
            .controlSize(.small)
        }
    }
}
