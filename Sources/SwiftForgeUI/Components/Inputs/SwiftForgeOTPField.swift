//
//  SwiftForgeOTPField.swift
//  SwiftForgeUI
//

import SwiftUI

/// A field for a one-time code, shown as one box per digit.
///
/// ```swift
/// SwiftForgeOTPField("Verification code", code: $code, length: 6, state: codeState)
///     .onChange(of: code) { _, code in
///         if code.count == 6 { verify(code) }
///     }
/// ```
///
/// Under the boxes is a single text field with the one-time-code content
/// type, so the code from a text message is offered above the keyboard and
/// fills every box at once, as does pasting. Typing moves to the next box,
/// and deleting to the previous one; non-digits are ignored and the code
/// never grows past `length`.
///
/// VoiceOver reads the field as one element — "Verification code, 4 of 6
/// digits entered" — rather than six separate boxes, along with the state's
/// message like other SwiftForgeUI fields.
public struct SwiftForgeOTPField: View {

    private let title: Text
    @Binding private var code: String
    private let length: Int
    private let state: SwiftForgeFieldState

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @SwiftForgeAccessibilityContext private var accessibility
    @FocusState private var isFocused: Bool

    /// Creates a one-time code field.
    ///
    /// - Parameters:
    ///   - titleKey: The field's label, shown above it and read by VoiceOver.
    ///   - code: The digits entered.
    ///   - length: The number of digits. Defaults to 6.
    ///   - state: The validation state and its message.
    public init(
        _ titleKey: LocalizedStringKey, code: Binding<String>, length: Int = 6, state: SwiftForgeFieldState = .normal
    ) {
        title = Text(titleKey)
        _code = code
        self.length = max(1, length)
        self.state = state
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            title
                .font(theme.typography.font(theme.typography.fieldLabel))
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityHidden(true)
            boxes
                .overlay {
                    TextField(text: $code, prompt: Text(verbatim: "")) { title }
                        .focused($isFocused)
                        .textContentType(.oneTimeCode)
                        #if os(iOS)
                    .keyboardType(.numberPad)
                        #endif
                        .autocorrectionDisabled()
                        // Invisible: the boxes show the code; the field takes
                        // input, autofill, paste, and VoiceOver. The empty
                        // prompt keeps the title from showing as a placeholder.
                        // The text keeps its real color, which accessibility
                        // tools read, and is multiplied away when drawn. (Zero
                        // opacity or a mask would hide the field from UIKit,
                        // and it couldn't take focus.)
                        .foregroundStyle(theme.colors.textPrimary)
                        .tint(.clear)
                        .colorMultiply(.clear)
                        // Exactly as large as the boxes (an overlay is sized
                        // by them), so its frame — what VoiceOver outlines
                        // and the hit area — matches what people see.
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .accessibilityLabel(title)
                        .accessibilityValue(SwiftForgeStrings.otpProgress(code.count, of: length))
                        .modifier(SwiftForgeFieldAccessibility(state: state))
                        .onChange(of: code) { _, newValue in
                            let digits = Self.sanitized(newValue, length: length)
                            if digits != newValue { code = digits }
                        }
                }
                .contentShape(Rectangle())
                .onTapGesture { isFocused = true }
            if state.message != nil {
                SwiftForgeFieldMessage(state: state)
            }
        }
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .accessibilityElement(children: .contain)
    }

    /// One box per digit; the next box to fill shows the focus color.
    private var boxes: some View {
        let characters = Array(code)
        return HStack(spacing: theme.spacing.xs) {
            ForEach(0..<length, id: \.self) { index in
                let isCurrent = isFocused && index == min(characters.count, length - 1)
                let shape = theme.radius.shape(theme.components.field.cornerRadius ?? theme.radius.control)
                Text(verbatim: index < characters.count ? String(characters[index]) : "")
                    .font(theme.typography.font(theme.typography.title2))
                    .monospacedDigit()
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: theme.sizes.controlHeightLarge)
                    .background(theme.components.field.background ?? theme.colors.surface, in: shape)
                    .overlay {
                        shape.strokeBorder(borderColor(isCurrent: isCurrent), lineWidth: borderWidth(isCurrent: isCurrent))
                    }
                    .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: isCurrent)
            }
        }
        .accessibilityHidden(true)
    }

    private func borderColor(isCurrent: Bool) -> SwiftForgeColor {
        switch state {
        case .error: theme.colors.danger.text
        case .success: theme.colors.success.text
        case .normal, .helper: isCurrent ? theme.colors.focusRing : theme.colors.borderStrong
        }
    }

    private func borderWidth(isCurrent: Bool) -> CGFloat {
        if case .error = state { return theme.borders.thick }
        return isCurrent ? theme.borders.thick : theme.borders.thin
    }

    /// Digits only, at most `length` of them.
    static func sanitized(_ text: String, length: Int) -> String {
        String(text.filter(\.isNumber).prefix(length))
    }
}

// MARK: - Previews

private struct OTPPreview: View {
    @State private var code = "4821"

    var body: some View {
        VStack(spacing: 24) {
            SwiftForgeOTPField("Verification code", code: $code, state: .helper("Sent to +90 555 000 00 00."))
            SwiftForgeOTPField("PIN", code: .constant("12"), length: 4, state: .error("That PIN isn't right."))
        }
        .padding()
    }
}

#Preview("OTP field") { OTPPreview() }

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeOTPField("Verification code", code: .constant("4821"))
    }
}
