//
//  SwiftForgeBadge.swift
//  SwiftForgeUI
//

import SwiftUI

/// A small capsule for a short status, a count, or an unread dot.
///
/// ```swift
/// SwiftForgeBadge("New", tone: .info)
/// SwiftForgeBadge("Beta", tone: .neutral, systemImage: "flask")
/// SwiftForgeBadge(count: unreadCount)
/// SwiftForgeBadge.dot()
/// ```
///
/// Badges come in three sizes, set with `controlSize(_:)`: `.small` for
/// dense lists, `.regular` (the default), and `.large` beside titles. Text
/// never goes below the caption size, so small badges stay readable.
///
/// To attach a count to an icon, use ``SwiftUICore/View/swiftForgeBadge(count:tone:maxCount:)``.
public struct SwiftForgeBadge: View {

    /// How strongly a text badge stands out.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Prominence: Sendable, Hashable {
        /// Tinted text on a light tinted background. The default.
        case subtle
        /// Contrasting text on a solid background.
        case prominent
    }

    enum Content {
        case text(Text, systemImage: String?, prominence: Prominence)
        case count(Int, maxCount: Int)
        case dot
    }

    private let content: Content
    private let tone: SwiftForgeTone
    /// `false` when the badge decorates another element that reports its count.
    var isAccessibilityElement = true

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.displayScale) private var displayScale
    @Environment(\.controlSize) private var controlSize
    /// Grows count and dot diameters with Dynamic Type. `ScaledMetric` rounds
    /// its value to whole pixels, so the factor is measured on a large
    /// reference length and each scaled diameter is rounded the same way.
    @ScaledMetric(relativeTo: .caption2) private var scaledReference: CGFloat = Self.referenceLength
    private static let referenceLength: CGFloat = 1_000

    private func scaled(_ length: CGFloat) -> CGFloat {
        (length * scaledReference / Self.referenceLength * displayScale).rounded() / displayScale
    }

    /// Creates a text badge with a localized title.
    ///
    /// - Parameters:
    ///   - titleKey: A word or two. The badge doesn't wrap.
    ///   - tone: The color family. Defaults to ``SwiftForgeTone/neutral``.
    ///   - systemImage: An SF Symbol shown before the text.
    ///   - prominence: How strongly the badge stands out. Defaults to ``Prominence/subtle``.
    public init(
        _ titleKey: LocalizedStringKey,
        tone: SwiftForgeTone = .neutral,
        systemImage: String? = nil,
        prominence: Prominence = .subtle
    ) {
        content = .text(Text(titleKey), systemImage: systemImage, prominence: prominence)
        self.tone = tone
    }

    /// Creates a text badge with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        tone: SwiftForgeTone = .neutral,
        systemImage: String? = nil,
        prominence: Prominence = .subtle
    ) {
        content = .text(Text(title), systemImage: systemImage, prominence: prominence)
        self.tone = tone
    }

    /// Creates a count badge. A count of zero or less shows nothing.
    ///
    /// Counts above `maxCount` show as "99+", but VoiceOver reads the exact
    /// count.
    ///
    /// - Parameters:
    ///   - count: The number to show.
    ///   - tone: The color family. Defaults to ``SwiftForgeTone/danger``.
    ///   - maxCount: The largest count shown in full. Defaults to 99.
    public init(count: Int, tone: SwiftForgeTone = .danger, maxCount: Int = 99) {
        content = .count(count, maxCount: maxCount)
        self.tone = tone
    }

    fileprivate init(decorating count: Int, tone: SwiftForgeTone, maxCount: Int) {
        self.init(count: count, tone: tone, maxCount: maxCount)
        isAccessibilityElement = false
    }

    private init(dotTone: SwiftForgeTone) {
        content = .dot
        tone = dotTone
    }

    /// A dot that signals something new without a count.
    ///
    /// The dot is hidden from VoiceOver. If it carries meaning, describe it in
    /// the accessibility label of the element it decorates.
    public static func dot(tone: SwiftForgeTone = .danger) -> SwiftForgeBadge {
        SwiftForgeBadge(dotTone: tone)
    }

    /// The content and behavior of the view.
    public var body: some View {
        let colors = theme.colors[tone]
        let tokens = theme.components.badge
        let shape = theme.radius.shape(tokens.cornerRadius)
        switch content {
        case let .text(text, systemImage, prominence):
            HStack(spacing: theme.spacing.xxs) {
                if let systemImage {
                    Image(systemName: systemImage).imageScale(.small)
                }
                text
            }
            .font(theme.typography.font(textStyle))
            .lineLimit(1)
            .foregroundStyle(prominence == .subtle ? colors.text : colors.onSolid)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(prominence == .subtle ? colors.subtle : colors.solid, in: shape)
            .overlay { border(shape, colors: colors) }
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isStaticText)

        case let .count(count, maxCount) where count > 0:
            Text(verbatim: count > maxCount ? "\(maxCount.formatted())+" : count.formatted())
                .font(theme.typography.font(textStyle))
                .monospacedDigit()
                .lineLimit(1)
                .foregroundStyle(colors.onSolid)
                .padding(.horizontal, theme.spacing.xxs)
                .frame(minWidth: scaled(countDiameter), minHeight: scaled(countDiameter))
                .background(colors.solid, in: shape)
                .overlay { border(shape, colors: colors) }
                // A count is never truncated or squeezed: "99+" must stay readable.
                .fixedSize()
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(SwiftForgeStrings.badgeCount(count))
                .accessibilityAddTraits(.isStaticText)
                .accessibilityHidden(!isAccessibilityElement)

        case .count:
            EmptyView()

        case .dot:
            Circle()
                .fill(colors.solid)
                .frame(width: scaled(dotDiameter), height: scaled(dotDiameter))
                .accessibilityHidden(true)
        }
    }

    private var size: SwiftForgeControlSize { SwiftForgeControlSize(controlSize) }

    /// Large badges use the small control label; smaller ones the badge role,
    /// which is never below the caption size.
    private var textStyle: SwiftForgeTextStyle {
        size == .large ? theme.typography.controlLabelSmall : theme.typography.badge
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: theme.spacing.xxs
        case .regular: theme.spacing.xs
        case .large: theme.spacing.sm
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: 0
        case .regular: theme.spacing.xxxs
        case .large: theme.spacing.xxs
        }
    }

    private var countDiameter: CGFloat {
        let tokens = theme.components.badge
        return switch size {
        case .small: tokens.countDiameterSmall
        case .regular: tokens.countDiameter
        case .large: tokens.countDiameterLarge
        }
    }

    /// The dot grows and shrinks in proportion to the count badge.
    private var dotDiameter: CGFloat {
        let tokens = theme.components.badge
        return tokens.dotDiameter * countDiameter / tokens.countDiameter
    }

    @ViewBuilder
    private func border(_ shape: SwiftForgeShape, colors: SwiftForgeToneColors) -> some View {
        if let width = theme.components.badge.borderWidth {
            shape.strokeBorder(theme.components.badge.borderColor ?? colors.text, lineWidth: width)
        }
    }
}

extension View {

    /// Attaches a count badge to the top-trailing corner of this view,
    /// typically an icon or icon button.
    ///
    /// ```swift
    /// Button("Inbox", systemImage: "tray") { openInbox() }
    ///     .buttonStyle(.swiftForgeIcon())
    ///     .swiftForgeBadge(count: unread)
    /// ```
    ///
    /// The badge isn't a separate VoiceOver element: the count is added to
    /// this view's accessibility value ("Inbox, 3 new items, button").
    public func swiftForgeBadge(count: Int, tone: SwiftForgeTone = .danger, maxCount: Int = 99) -> some View {
        // The value goes on this view before the overlay is added; applied
        // afterwards, SwiftUI would also attach it to the badge and expose it.
        accessibilityValue(count > 0 ? SwiftForgeStrings.badgeCount(count) : Text(verbatim: ""))
            .overlay(alignment: .topTrailing) {
                SwiftForgeBadge(decorating: count, tone: tone, maxCount: maxCount)
                    .alignmentGuide(.top) { $0.height / 2 }
                    .alignmentGuide(.trailing) { $0.width / 2 }
            }
    }
}

#Preview("Badges") {
    VStack(alignment: .leading, spacing: 12) {
        HStack {
            ForEach(SwiftForgeTone.allCases, id: \.self) { tone in
                SwiftForgeBadge(tone.rawValue.capitalized, tone: tone)
            }
        }
        HStack {
            ForEach(SwiftForgeTone.allCases, id: \.self) { tone in
                SwiftForgeBadge(tone.rawValue.capitalized, tone: tone, prominence: .prominent)
            }
        }
        HStack(spacing: 16) {
            SwiftForgeBadge(count: 3)
            SwiftForgeBadge(count: 42, tone: .accent)
            SwiftForgeBadge(count: 1_250)
            SwiftForgeBadge.dot()
            Image(systemName: "bell").font(.title2).swiftForgeBadge(count: 5)
        }
    }
    .padding()
}

#Preview("Dark, AX3") {
    HStack {
        SwiftForgeBadge("Live", tone: .success, systemImage: "dot.radiowaves.left.and.right")
        SwiftForgeBadge(count: 7)
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility3)
    .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SwiftForgeBadge("New", tone: .info)
                SwiftForgeBadge("Beta", tone: .neutral, systemImage: "flask")
                SwiftForgeBadge("Live", tone: .success, prominence: .prominent)
            }
            HStack(spacing: 16) {
                SwiftForgeBadge(count: 3)
                SwiftForgeBadge(count: 1_250)
                SwiftForgeBadge.dot()
            }
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SwiftForgeBadge("New", tone: .info)
                SwiftForgeBadge("Beta", tone: .neutral, systemImage: "flask")
                SwiftForgeBadge("Live", tone: .success, prominence: .prominent)
            }
            HStack(spacing: 16) {
                SwiftForgeBadge(count: 3)
                SwiftForgeBadge(count: 1_250)
                SwiftForgeBadge.dot()
            }
        }
    }
}
