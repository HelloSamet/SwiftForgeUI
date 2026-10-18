//
//  SwiftForgeDivider.swift
//  SwiftForgeUI
//

import SwiftUI

/// A themed hairline separator.
///
/// Built on SwiftUI's `Divider`, so it's horizontal in a `VStack`, vertical
/// in an `HStack`, and always one physical pixel thick.
///
/// ```swift
/// VStack(spacing: 0) {
///     SettingsRow("Notifications")
///     SwiftForgeDivider(inset: .leading(56))
///     SettingsRow("Privacy")
/// }
/// ```
///
/// Give a divider a label to separate alternatives, such as sign-in
/// methods; the label sits between two lines and VoiceOver reads it:
///
/// ```swift
/// SwiftForgeDivider("or")
/// ```
///
/// Unlabeled dividers are decorative and hidden from VoiceOver. If a
/// separation carries meaning, use a section header instead.
public struct SwiftForgeDivider: View {

    /// Space left empty before or around a horizontal divider.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Inset: Sendable, Hashable {
        /// Edge to edge.
        case none
        /// Inset from the leading edge — for example, past a row's icon column.
        case leading(CGFloat)
        /// Inset from both edges.
        case horizontal(CGFloat)
    }

    /// The divider's weight.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Emphasis: Sendable, Hashable {
        /// A subtle hairline. The default.
        case subtle
        /// A stronger line, for the end of a section.
        case strong
    }

    private let inset: Inset
    private let emphasis: Emphasis
    private var label: Text?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.displayScale) private var displayScale

    /// Creates a divider.
    ///
    /// - Parameters:
    ///   - inset: Space left empty before or around a horizontal divider. Defaults to ``Inset/none``.
    ///   - emphasis: The divider's weight. Defaults to ``Emphasis/subtle``.
    public init(inset: Inset = .none, emphasis: Emphasis = .subtle) {
        self.inset = inset
        self.emphasis = emphasis
    }

    /// Creates a horizontal divider with a label between two lines.
    ///
    /// - Parameters:
    ///   - titleKey: A short label, such as "or".
    ///   - inset: Space left empty around the divider. Defaults to ``Inset/none``.
    ///   - emphasis: The lines' weight. Defaults to ``Emphasis/subtle``.
    public init(_ titleKey: LocalizedStringKey, inset: Inset = .none, emphasis: Emphasis = .subtle) {
        self.init(inset: inset, emphasis: emphasis)
        label = Text(titleKey)
    }

    /// Creates a labeled divider with a label that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, inset: Inset = .none, emphasis: Emphasis = .subtle) {
        self.init(inset: inset, emphasis: emphasis)
        label = Text(title)
    }

    /// The content and behavior of the view.
    public var body: some View {
        if let label {
            HStack(spacing: theme.spacing.sm) {
                line
                label
                    .font(theme.typography.font(theme.typography.footnote))
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize()
                line
            }
            .padding(.leading, leadingInset)
            .padding(.trailing, trailingInset)
        } else {
            Divider()
                .overlay(lineColor)
                .padding(.leading, leadingInset)
                .padding(.trailing, trailingInset)
                .accessibilityHidden(true)
        }
    }

    private var lineColor: SwiftForgeColor {
        emphasis == .subtle ? theme.colors.borderSubtle : theme.colors.borderStrong
    }

    /// A horizontal hairline that fills the space beside a label.
    private var line: some View {
        Rectangle()
            .fill(lineColor)
            .frame(height: 1 / displayScale)  // swiftforge-lint: allow (one physical pixel)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }

    private var leadingInset: CGFloat {
        switch inset {
        case .none: 0
        case .leading(let value), .horizontal(let value): value
        }
    }

    private var trailingInset: CGFloat {
        if case .horizontal(let value) = inset { value } else { 0 }
    }
}

#Preview("Axes and insets") {
    VStack(spacing: 16) {
        Text("Above")
        SwiftForgeDivider()
        Text("Inset below")
        SwiftForgeDivider(inset: .leading(40))
        HStack {
            Text("Left")
            SwiftForgeDivider().frame(height: 24)
            Text("Right")
        }
        SwiftForgeDivider(emphasis: .strong)
    }
    .padding()
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(alignment: .leading, spacing: 8) {
            Text("Above")
            SwiftForgeDivider()
            Text("Below")
            SwiftForgeDivider(emphasis: .strong)
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Above")
            SwiftForgeDivider()
            Text("Below")
            SwiftForgeDivider(emphasis: .strong)
        }
    }
}
