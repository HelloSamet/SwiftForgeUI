//
//  SwiftForgeBanner.swift
//  SwiftForgeUI
//

import SwiftUI

/// A message placed within a screen's content — a form-level error, the
/// result of an action, or a notice.
///
/// ```swift
/// SwiftForgeBanner(
///     .danger,
///     title: "Couldn't save changes",
///     message: "Check your connection and try again.",
///     onDismiss: { saveError = nil }
/// ) {
///     Button("Retry") { retry() }
/// }
/// ```
///
/// Meaning never depends on color alone: every tone pairs a distinct icon
/// with its color, and VoiceOver reads the tone's name before the title
/// ("Error: Couldn't save changes. Check your connection and try again.").
/// Danger and warning banners are announced when they appear.
public struct SwiftForgeBanner<Actions: View>: View {

    /// How strongly a banner stands out.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Prominence: Sendable, Hashable {
        /// Primary text on a light tinted background. The default.
        case subtle
        /// Contrasting text on a solid background, for messages that must not be missed.
        case prominent
    }

    private let tone: SwiftForgeTone
    private let title: SwiftForgeText
    private let message: SwiftForgeText?
    private let systemImage: String?
    private let prominence: Prominence
    private let announcesAppearance: Bool
    private let onDismiss: (() -> Void)?
    private let actions: Actions

    @Environment(\.swiftForgeTheme) private var theme
    @State private var hasAppeared = false

    /// Creates a banner with localized text and actions.
    ///
    /// - Parameters:
    ///   - tone: The banner's tone, which sets its icon and colors.
    ///   - title: A short summary.
    ///   - message: Supporting detail.
    ///   - systemImage: An SF Symbol replacing the tone's icon.
    ///   - prominence: How strongly the banner stands out. Defaults to ``Prominence/subtle``.
    ///   - announcesAppearance: Whether VoiceOver announces the banner when it
    ///     appears. Defaults to `true` for warning and danger, `false` otherwise.
    ///   - onDismiss: Adds a close button that calls this closure.
    ///   - actions: Buttons shown below the text, styled as small SwiftForgeUI
    ///     buttons: plain in subtle banners, tinted in prominent ones.
    public init(
        _ tone: SwiftForgeTone,
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        systemImage: String? = nil,
        prominence: Prominence = .subtle,
        announcesAppearance: Bool? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            tone: tone,
            title: SwiftForgeText(title),
            message: message.map(SwiftForgeText.init),
            systemImage: systemImage,
            prominence: prominence,
            announcesAppearance: announcesAppearance,
            onDismiss: onDismiss,
            actions: actions()
        )
    }

    /// Creates a banner with text that isn't localized, and actions.
    @_disfavoredOverload
    public init<Title: StringProtocol>(
        _ tone: SwiftForgeTone,
        title: Title,
        message: String? = nil,
        systemImage: String? = nil,
        prominence: Prominence = .subtle,
        announcesAppearance: Bool? = nil,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            tone: tone,
            title: SwiftForgeText(verbatim: String(title)),
            message: message.map { SwiftForgeText(verbatim: $0) },
            systemImage: systemImage,
            prominence: prominence,
            announcesAppearance: announcesAppearance,
            onDismiss: onDismiss,
            actions: actions()
        )
    }

    private init(
        tone: SwiftForgeTone,
        title: SwiftForgeText,
        message: SwiftForgeText?,
        systemImage: String?,
        prominence: Prominence,
        announcesAppearance: Bool?,
        onDismiss: (() -> Void)?,
        actions: Actions
    ) {
        self.tone = tone
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.prominence = prominence
        self.announcesAppearance = announcesAppearance ?? (tone == .danger || tone == .warning)
        self.onDismiss = onDismiss
        self.actions = actions
    }

    /// The content and behavior of the view.
    public var body: some View {
        let colors = theme.colors[tone]
        let isProminent = prominence == .prominent
        let hasActions = Actions.self != EmptyView.self
        let shape = theme.radius.shape(theme.components.banner.cornerRadius ?? theme.radius.card)

        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Image(systemName: systemImage ?? Self.icon(for: tone))
                    .foregroundStyle(isProminent ? colors.onSolid : colors.text)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    title.text
                        .font(theme.typography.font(titleStyle))
                        .foregroundStyle(isProminent ? colors.onSolid : theme.colors.textPrimary)
                    if let message {
                        message.text
                            .font(theme.typography.font(theme.typography.footnote))
                            .foregroundStyle(isProminent ? colors.onSolid : theme.colors.textSecondary)
                    }
                }
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityLabel)
                .accessibilityAddTraits(.isStaticText)

                Spacer(minLength: onDismiss == nil ? 0 : theme.sizes.minimumHitTarget - theme.spacing.sm)
            }
            .font(theme.typography.font(titleStyle))

            if hasActions {
                ViewThatFits(in: .horizontal) {
                    HStack(spacing: theme.spacing.xs) { actions }
                    VStack(alignment: .leading, spacing: theme.spacing.xs) { actions }
                }
                .buttonStyle(.swiftForge(isProminent ? .tinted : .plain, tone: tone))
                .controlSize(.small)
            }
        }
        .padding(theme.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isProminent ? colors.solid : colors.subtle, in: shape)
        .overlay {
            if let borderWidth = theme.components.banner.borderWidth {
                shape.strokeBorder(colors.text, lineWidth: borderWidth)
            }
        }
        .overlay(alignment: .topTrailing) {
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(theme.typography.font(theme.typography.footnote.weight(.semibold)))
                        .foregroundStyle(isProminent ? colors.onSolid : theme.colors.textSecondary)
                        .frame(width: theme.sizes.minimumHitTarget, height: theme.sizes.minimumHitTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(SwiftForgeStrings.close)
            }
        }
        .accessibilityElement(children: .contain)
        .onAppear {
            hasAppeared = true
            if announcesAppearance {
                AccessibilityNotification.Announcement(announcement).post()
            }
        }
        .swiftForgeHaptic(trigger: hasAppeared) { _, appeared in
            appeared ? hapticEvent : nil
        }
    }

    private var titleStyle: SwiftForgeTextStyle {
        theme.components.banner.title ?? theme.typography.subheadline.weight(.semibold)
    }

    private var accessibilityLabel: Text {
        let prefix = SwiftForgeStrings.toneName(tone) + Text(verbatim: ": ") + title.text
        guard let message else { return prefix }
        return prefix + Text(verbatim: ". ") + message.text
    }

    private var announcement: String {
        var parts = "\(SwiftForgeStrings.toneNameString(tone)): \(title.string)"
        if let message { parts += ". \(message.string)" }
        return parts
    }

    private var hapticEvent: SwiftForgeHapticEvent? {
        switch tone {
        case .success: .success
        case .warning: .warning
        case .danger: .error
        case .accent, .neutral, .info: nil
        }
    }

    static func icon(for tone: SwiftForgeTone) -> String {
        switch tone {
        case .accent: "sparkles"
        case .neutral: "bell.fill"
        case .info: "info.circle.fill"
        case .success: "checkmark.circle.fill"
        case .warning: "exclamationmark.triangle.fill"
        case .danger: "xmark.octagon.fill"
        }
    }
}

extension SwiftForgeBanner where Actions == EmptyView {

    /// Creates a banner with localized text.
    ///
    /// - Parameters:
    ///   - tone: The banner's tone, which sets its icon and colors.
    ///   - title: A short summary.
    ///   - message: Supporting detail.
    ///   - systemImage: An SF Symbol replacing the tone's icon.
    ///   - prominence: How strongly the banner stands out. Defaults to ``Prominence/subtle``.
    ///   - announcesAppearance: Whether VoiceOver announces the banner when it
    ///     appears. Defaults to `true` for warning and danger, `false` otherwise.
    ///   - onDismiss: Adds a close button that calls this closure.
    public init(
        _ tone: SwiftForgeTone,
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        systemImage: String? = nil,
        prominence: Prominence = .subtle,
        announcesAppearance: Bool? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(
            tone, title: title, message: message, systemImage: systemImage, prominence: prominence,
            announcesAppearance: announcesAppearance, onDismiss: onDismiss
        ) { EmptyView() }
    }

    /// Creates a banner with text that isn't localized.
    @_disfavoredOverload
    public init<Title: StringProtocol>(
        _ tone: SwiftForgeTone,
        title: Title,
        message: String? = nil,
        systemImage: String? = nil,
        prominence: Prominence = .subtle,
        announcesAppearance: Bool? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.init(
            tone, title: title, message: message, systemImage: systemImage, prominence: prominence,
            announcesAppearance: announcesAppearance, onDismiss: onDismiss
        ) { EmptyView() }
    }
}

#Preview("Tones") {
    ScrollView {
        VStack(spacing: 12) {
            SwiftForgeBanner(.info, title: "New version available", message: "Update to get the latest components.")
            SwiftForgeBanner(.success, title: "Changes saved", onDismiss: {})
            SwiftForgeBanner(.warning, title: "Unsaved changes", message: "You have edits that haven't been saved.") {
                Button("Save") {}
                Button("Discard") {}
            }
            SwiftForgeBanner(
                .danger, title: "Couldn't save changes", message: "Check your connection and try again.", onDismiss: {}
            ) {
                Button("Retry") {}
            }
            SwiftForgeBanner(
                .danger, title: "Payment failed", message: "Your card was declined.", prominence: .prominent, onDismiss: {}
            ) {
                Button("Update card") {}
            }
            SwiftForgeBanner(.neutral, title: "Maintenance tonight", message: "The service is unavailable from 2 to 3 AM.")
        }
        .padding()
    }
}

#Preview("Dark, AX5, RTL") {
    ScrollView {
        SwiftForgeBanner(.warning, title: "Unsaved changes", message: "You have edits that haven't been saved.", onDismiss: {}) {
            Button("Save") {}
            Button("Discard") {}
        }
        .padding()
    }
    .environment(\.dynamicTypeSize, .accessibility5)
    .environment(\.layoutDirection, .rightToLeft)
    .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(spacing: 8) {
            SwiftForgeBanner(.success, title: "Changes saved", announcesAppearance: false, onDismiss: {})
            SwiftForgeBanner(.danger, title: "Payment failed", message: "Your card was declined.", prominence: .prominent) {
                Button("Update card") {}
            }
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(spacing: 8) {
            SwiftForgeBanner(.success, title: "Changes saved", announcesAppearance: false, onDismiss: {})
            SwiftForgeBanner(.danger, title: "Payment failed", message: "Your card was declined.", prominence: .prominent) {
                Button("Update card") {}
            }
        }
    }
}
