//
//  SwiftForgeFieldMessage.swift
//  SwiftForgeUI
//

import SwiftUI

/// A form control's message row: the state's icon and message, and an
/// optional character counter. Shared by every field and by controls that
/// show validation outside a field, such as radio groups.
///
/// The message is hidden from VoiceOver here: the editable control reads it
/// through ``SwiftForgeFieldAccessibility``.
struct SwiftForgeFieldMessage: View {

    let state: SwiftForgeFieldState
    var characterCount: Int? = nil
    var characterLimit: Int? = nil

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Whether the row has anything to show.
    static func isVisible(state: SwiftForgeFieldState, characterCount: Int?, characterLimit: Int?) -> Bool {
        state.message != nil || (characterCount != nil && characterLimit != nil)
    }

    var body: some View {
        // At accessibility sizes the message and counter stack, so
        // neither has to wrap into a sliver beside the other.
        let layout =
            dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .trailing, spacing: theme.spacing.xxs))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: theme.spacing.xs))
        layout {
            if let message = state.message {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xxs) {
                    Image(systemName: state.iconName)
                    Text(message)
                }
                .foregroundStyle(messageColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
                .accessibilityHidden(true)
            }
            if let characterCount, let characterLimit {
                Text(verbatim: "\(characterCount.formatted())/\(characterLimit.formatted())")
                    .monospacedDigit()
                    .fixedSize()
                    .foregroundStyle(theme.colors.textSecondary)
                    .accessibilityLabel(SwiftForgeStrings.characterCount(characterCount, limit: characterLimit))
            }
        }
        .font(theme.typography.font(theme.typography.fieldHelper))
    }

    private var messageColor: SwiftForgeColor {
        state.tone.map { theme.colors[$0].text } ?? theme.colors.textSecondary
    }
}

/// Accessibility shared by the editable control inside SwiftForgeUI fields:
/// helper text as the hint, success and error messages as high-importance
/// custom content, an announcement and haptic when a message appears.
struct SwiftForgeFieldAccessibility: ViewModifier {

    let state: SwiftForgeFieldState

    func body(content: Content) -> some View {
        content
            .accessibilityHint(helperText ?? Text(verbatim: ""))
            .accessibilityCustomContent(
                state.tone.map(SwiftForgeStrings.toneName) ?? Text(verbatim: ""),
                // Always applied, so the field's identity — and keyboard focus —
                // survives state changes; empty content isn't read.
                statusText ?? Text(verbatim: ""),
                importance: .high
            )
            .onChange(of: state) { oldState, newState in
                guard newState != oldState, let tone = newState.tone, let message = newState.message else { return }
                AccessibilityNotification.Announcement(
                    "\(SwiftForgeStrings.toneNameString(tone)): \(String(localized: message))"
                ).post()
            }
            .swiftForgeHaptic(trigger: state) { _, newState in
                if case .error = newState { .error } else { nil }
            }
    }

    private var helperText: Text? {
        if case .helper(let message) = state { Text(message) } else { nil }
    }

    private var statusText: Text? {
        switch state {
        case .success(let message), .error(let message): Text(message)
        case .normal, .helper: nil
        }
    }
}

/// An accessory button inside a field's input area, such as the clear or
/// show-password button: a 44-pt hit area that extends into the field's
/// content inset.
struct SwiftForgeFieldAccessoryButton: View {

    let systemImage: String
    let label: Text
    let action: () -> Void

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(minWidth: theme.sizes.minimumHitTarget, minHeight: theme.sizes.minimumHitTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        // The 44-pt hit area extends into the input area's padding instead of
        // making the field taller than one without the button.
        .padding(.horizontal, -theme.fieldContentInset)
        .padding(.vertical, -theme.spacing.xs)
    }
}

extension SwiftForgeTheme {

    /// The horizontal inset of a field's content. Accessory buttons use
    /// its negative so their 44-pt hit area extends into it.
    var fieldContentInset: CGFloat {
        components.field.style == .underlined ? 0 : spacing.sm
    }
}
