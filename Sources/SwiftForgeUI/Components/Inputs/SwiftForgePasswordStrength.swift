//
//  SwiftForgePasswordStrength.swift
//  SwiftForgeUI
//

import SwiftUI

/// How strong a password is, shown by ``SwiftForgeSecureField`` as a meter.
///
/// SwiftForgeUI doesn't judge passwords: your app decides the strength —
/// with its own rules or a library — and the field shows it.
///
/// ```swift
/// SwiftForgeSecureField("New password", text: $password)
///     .textContentType(.newPassword)
///     .swiftForgePasswordStrength(password.isEmpty ? nil : strength(of: password))
/// ```
///
/// The meter fills one segment per level and names the level in text, so it
/// never relies on color alone. VoiceOver reads it with the field.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgePasswordStrength: String, Sendable, Hashable, CaseIterable, Comparable {

    /// Easy to guess. Shown in the danger tone.
    case weak
    /// Better, but still guessable. Shown in the warning tone.
    case fair
    /// Hard to guess. Shown in the success tone.
    case good
    /// Very hard to guess. Shown in the success tone, every segment filled.
    case strong

    /// The number of filled segments, from 1 to 4.
    var level: Int {
        switch self {
        case .weak: 1
        case .fair: 2
        case .good: 3
        case .strong: 4
        }
    }

    var tone: SwiftForgeTone {
        switch self {
        case .weak: .danger
        case .fair: .warning
        case .good, .strong: .success
        }
    }

    /// Whether `lhs` is weaker than `rhs`.
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.level < rhs.level }
}

extension EnvironmentValues {
    @Entry var swiftForgePasswordStrength: SwiftForgePasswordStrength? = nil
}

extension View {

    /// Shows a strength meter under the ``SwiftForgeSecureField`` beneath
    /// this view. Pass `nil` to hide it, such as while the field is empty.
    public func swiftForgePasswordStrength(_ strength: SwiftForgePasswordStrength?) -> some View {
        environment(\.swiftForgePasswordStrength, strength)
    }
}

/// The meter: four segments and the level's name.
struct SwiftForgePasswordStrengthMeter: View {

    let strength: SwiftForgePasswordStrength

    @Environment(\.swiftForgeTheme) private var theme
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        HStack(spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xxs) {
                ForEach(1...SwiftForgePasswordStrength.allCases.count, id: \.self) { segment in
                    theme.radius.shape(tokens.barCornerRadius)
                        .fill(segment <= strength.level ? theme.colors[strength.tone].text : theme.colors.fillMuted)
                        .frame(height: tokens.barHeight)
                }
            }
            SwiftForgeStrings.passwordStrengthName(strength)
                .font(theme.typography.font(theme.typography.fieldHelper))
                .foregroundStyle(theme.colors[strength.tone].text)
                .fixedSize()
        }
        .animation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion), value: strength)
        // The field reads the strength as custom content.
        .accessibilityHidden(true)
    }

    private var tokens: SwiftForgeProgressTokens { theme.components.progress }
}
