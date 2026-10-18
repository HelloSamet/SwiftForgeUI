//
//  SwiftForgeAvatar.swift
//  SwiftForgeUI
//

import SwiftUI

/// A person's picture, or their initials when there's no picture, with an
/// optional presence status.
///
/// ```swift
/// SwiftForgeAvatar(name: "Ada Lovelace")                          // initials "AL"
/// SwiftForgeAvatar(name: "Ada Lovelace", image: Image("ada"), status: .online)
/// SwiftForgeAvatar(name: "Ada Lovelace").controlSize(.large)
/// ```
///
/// The fallbacks run in order: the image, the initials of `name` — derived
/// with the person-name formatter, so they're right for names in any script
/// — and finally a person symbol. Initials sit on one of the theme's tones,
/// chosen from the name so a person keeps the same color everywhere.
///
/// SwiftForgeUI never downloads images: load the picture yourself and pass
/// it as an `Image`.
///
/// Sizes come from `controlSize(_:)` and ``SwiftForgeAvatarTokens/diameters``.
/// VoiceOver reads the avatar as an image labeled with the name and status,
/// such as "Ada Lovelace, Online". Hide a purely decorative avatar — one next
/// to the same name in text — with `accessibilityHidden(true)`. An avatar
/// with an empty name is hidden from VoiceOver.
public struct SwiftForgeAvatar: View, Identifiable {

    /// A person's presence.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Status: String, Sendable, Hashable, CaseIterable {
        /// Available. A green dot.
        case online
        /// Idle or away. An amber dot.
        case away
        /// Doesn't want to be disturbed. A red dot with a bar.
        case busy
        /// Not connected. A hollow gray ring.
        case offline

        var tone: SwiftForgeTone {
            switch self {
            case .online: .success
            case .away: .warning
            case .busy: .danger
            case .offline: .neutral
            }
        }

        /// Shown inside the dot with Differentiate Without Color on.
        var glyph: String? {
            switch self {
            case .online: "checkmark"
            case .away: "moon.fill"
            case .busy: "minus"
            case .offline: nil
            }
        }
    }

    /// The person's name, which also identifies the avatar in a group.
    public let name: String
    private let image: Image?
    private let status: Status?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize
    @SwiftForgeAccessibilityContext private var accessibility

    /// A stable identity for groups: the name.
    nonisolated public var id: String { name }

    /// Creates an avatar.
    ///
    /// - Parameters:
    ///   - name: The person's name, read by VoiceOver and used for initials.
    ///   - image: The person's picture, if you have one.
    ///   - status: The person's presence, shown as a dot.
    public init(name: String, image: Image? = nil, status: Status? = nil) {
        self.name = name
        self.image = image
        self.status = status
    }

    /// The content and behavior of the view.
    public var body: some View {
        let diameter = theme.components.avatar.diameters[SwiftForgeControlSize(controlSize)]
        let shape = theme.radius.shape(tokens.cornerRadius)
        face(diameter: diameter)
            // The initials and symbol are part of the picture; the avatar
            // as a whole is the element, labeled with the name.
            .accessibilityHidden(true)
            .frame(width: diameter, height: diameter)
            .clipShape(shape)
            .overlay {
                if let width = tokens.borderWidth {
                    shape.strokeBorder(tokens.borderColor ?? theme.colors.borderStrong, lineWidth: width)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let status {
                    statusDot(status, diameter: diameter)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityAddTraits(.isImage)
            // Without a name there's nothing to say: an unlabeled image would
            // only add noise.
            .accessibilityHidden(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }

    private var tokens: SwiftForgeAvatarTokens { theme.components.avatar }

    @ViewBuilder
    private func face(diameter: CGFloat) -> some View {
        if let image {
            image
                .resizable()
                .scaledToFill()
        } else {
            let colors = theme.colors[Self.tone(for: name)]
            ZStack {
                Rectangle().fill(colors.subtle)
                SwiftForgeAvatarGlyph(
                    content: Self.initials(of: name).map { .text($0) } ?? .symbol("person.fill"),
                    fontSize: diameter * Self.initialsScale,
                    maxWidth: diameter * (1 - 2 * Self.initialsInset),
                    color: colors.text,
                    design: theme.typography.body.design)
            }
        }
    }

    /// The status dot, a quarter of the avatar across, ringed with the
    /// surface color so it stands out from the picture.
    private func statusDot(_ status: Status, diameter: CGFloat) -> some View {
        let size = max(diameter * Self.statusScale, theme.spacing.xs)
        let colors = theme.colors[status.tone]
        return ZStack {
            Circle().fill(theme.colors.surface)
            if status == .offline {
                Circle().strokeBorder(colors.text, lineWidth: max(size / 5, theme.borders.thin))
                    .padding(tokens.ringWidth)
            } else {
                Circle().fill(colors.text).padding(tokens.ringWidth)
                if accessibility.differentiateWithoutColor, let glyph = status.glyph {
                    Image(systemName: glyph)
                        .font(.system(size: size * Self.glyphScale, weight: .bold))
                        .foregroundStyle(theme.colors.surface)
                }
                if status == .busy, !accessibility.differentiateWithoutColor {
                    // A bar marks busy even without color, like the system's.
                    theme.radius.shape(SwiftForgeRadius.capsule).fill(theme.colors.surface)
                        .frame(width: size * Self.glyphScale, height: max(size / 6, theme.borders.thin))
                }
            }
        }
        .frame(width: size, height: size)
        // Sits on the avatar's edge rather than inside the picture.
        .offset(x: tokens.cornerRadius == 0 ? size / 4 : 0, y: tokens.cornerRadius == 0 ? size / 4 : 0)
    }

    private var accessibilityLabel: Text {
        guard let status else { return Text(verbatim: name) }
        return Text(verbatim: name) + Text(verbatim: ", ") + SwiftForgeStrings.avatarStatus(status)
    }

    // Proportions keep every size balanced; the sizes themselves are tokens.
    private static let initialsScale: CGFloat = 0.4  // swiftforge-lint: allow (proportion)
    static let initialsInset: CGFloat = 0.1  // swiftforge-lint: allow (proportion)
    private static let statusScale: CGFloat = 0.28  // swiftforge-lint: allow (proportion)
    private static let glyphScale: CGFloat = 0.5  // swiftforge-lint: allow (proportion)

    /// Up to two initials, from the person-name formatter's abbreviation,
    /// which handles names in any script; `nil` if there's nothing to show.
    ///
    /// Avatars redraw as lists scroll, and creating and running the formatter
    /// is costly (it loads locale data), so one formatter is shared and
    /// results are kept for the names seen most recently.
    static func initials(of name: String) -> String? {
        if let cached = initialsCache[name] { return cached }
        let initials = computeInitials(of: name)
        if initialsCache.count >= initialsCacheLimit { initialsCache.removeAll(keepingCapacity: true) }
        initialsCache[name] = initials
        return initials
    }

    private static func computeInitials(of name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let components = nameFormatter.personNameComponents(from: trimmed) {
            let abbreviation = nameFormatter.string(from: components)
            if !abbreviation.isEmpty { return String(abbreviation.prefix(2)).uppercased() }
        }
        return String(trimmed.prefix(1)).uppercased()
    }

    private static let nameFormatter: PersonNameComponentsFormatter = {
        let formatter = PersonNameComponentsFormatter()
        formatter.style = .abbreviated
        return formatter
    }()

    private static var initialsCache: [String: String?] = [:]
    private static var initialsCacheLimit: Int { 512 }  // swiftforge-lint: allow (cache size)

    /// The tone for a name's initials. A stable hash — not Swift's `Hasher`,
    /// which is seeded per launch — keeps a person's color fixed.
    static func tone(for name: String) -> SwiftForgeTone {
        let tones: [SwiftForgeTone] = [.accent, .info, .success, .warning, .neutral]
        let hash = name.unicodeScalars.reduce(UInt32(5381)) { ($0 &<< 5) &+ $0 &+ $1.value }
        return tones[Int(hash % UInt32(tones.count))]
    }
}

/// Overlapping avatars for a group of people, with a "+N" count for those
/// that don't fit.
///
/// ```swift
/// SwiftForgeAvatarGroup(members.map { SwiftForgeAvatar(name: $0.name, image: $0.photo) }, maxVisible: 3)
/// ```
///
/// Each avatar overlaps the previous one by ``SwiftForgeAvatarTokens/groupOverlap``
/// and is ringed with the surface color. The group is one VoiceOver element
/// that lists the names, such as "Ada Lovelace, Grace Hopper, and 3 others".
/// Avatars follow the reading direction.
public struct SwiftForgeAvatarGroup: View {

    private let avatars: [SwiftForgeAvatar]
    private let maxVisible: Int

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize

    /// Creates an avatar group.
    ///
    /// - Parameters:
    ///   - avatars: The people, in display order.
    ///   - maxVisible: How many avatars to show before the "+N" count.
    ///     Defaults to 4.
    public init(_ avatars: [SwiftForgeAvatar], maxVisible: Int = 4) {
        self.avatars = avatars
        self.maxVisible = max(1, maxVisible)
    }

    /// The content and behavior of the view.
    public var body: some View {
        let diameter = tokens.diameters[SwiftForgeControlSize(controlSize)]
        let visible = Array(avatars.prefix(maxVisible))
        let hidden = avatars.count - visible.count
        HStack(spacing: -diameter * tokens.groupOverlap) {
            ForEach(visible) { avatar in
                avatar
                    .modifier(SwiftForgeAvatarRing(diameter: diameter))
                    .accessibilityHidden(true)
            }
            if hidden > 0 {
                SwiftForgeAvatarGlyph(
                    content: .text("+\(hidden.formatted())"),
                    fontSize: diameter * Self.countScale,
                    maxWidth: diameter * (1 - 2 * SwiftForgeAvatar.initialsInset),
                    color: theme.colors.neutral.text,
                    design: theme.typography.body.design
                )
                .frame(width: diameter, height: diameter)
                .accessibilityHidden(true)
                .background(theme.colors.neutral.subtle)
                .clipShape(theme.radius.shape(tokens.cornerRadius))
                .overlay {
                    if let width = tokens.borderWidth {
                        theme.radius.shape(tokens.cornerRadius)
                            .strokeBorder(tokens.borderColor ?? theme.colors.borderStrong, lineWidth: width)
                    }
                }
                .modifier(SwiftForgeAvatarRing(diameter: diameter))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: Self.accessibilityLabel(names: visible.map(\.name), hidden: hidden)))
        .accessibilityAddTraits(.isImage)
    }

    private var tokens: SwiftForgeAvatarTokens { theme.components.avatar }

    private static let countScale: CGFloat = 0.36  // swiftforge-lint: allow (proportion)

    /// "Ada, Grace, and 3 others", in the device language.
    static func accessibilityLabel(names: [String], hidden: Int) -> String {
        let items = hidden > 0 ? names + [SwiftForgeStrings.avatarGroupOthers(hidden)] : names
        return items.formatted(.list(type: .and))
    }
}

/// A ring in the surface color around an avatar in a group, so overlapping
/// avatars stay distinct.
private struct SwiftForgeAvatarRing: ViewModifier {

    let diameter: CGFloat

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        let tokens = theme.components.avatar
        let ring = tokens.ringWidth
        content
            .padding(ring)
            .background(theme.colors.surface, in: theme.radius.shape(tokens.cornerRadius == 0 ? 0 : tokens.cornerRadius + ring))
            .padding(-ring)
    }
}

/// Initials, a count, or a symbol drawn as part of an avatar's picture.
///
/// Drawn in a `Canvas` rather than as `Text`: an avatar is a picture labeled
/// with the person's name, and its initials don't follow Dynamic Type — the
/// avatar's size is fixed — so they mustn't be exposed as text. Text that
/// doesn't fit is scaled down.
private struct SwiftForgeAvatarGlyph: View {

    enum Content {
        case text(String)
        case symbol(String)
    }

    let content: Content
    let fontSize: CGFloat
    let maxWidth: CGFloat
    let color: SwiftForgeColor
    let design: Font.Design

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            switch content {
            case .text(let string):
                func resolved(_ size: CGFloat) -> GraphicsContext.ResolvedText {
                    context.resolve(
                        Text(verbatim: string)
                            .font(.system(size: size, weight: .semibold, design: design))
                            .foregroundStyle(color))
                }
                var text = resolved(fontSize)
                let width = text.measure(in: size).width
                if width > maxWidth, width > 0 {
                    text = resolved(fontSize * maxWidth / width)
                }
                context.draw(text, at: center)
            case .symbol(let name):
                var image = context.resolve(Image(systemName: name))
                image.shading = .style(color)
                let side = fontSize
                context.draw(image, in: CGRect(x: center.x - side / 2, y: center.y - side / 2, width: side, height: side))
            }
        }
        .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("Avatars") {
    VStack(alignment: .leading, spacing: 16) {
        HStack(spacing: 12) {
            SwiftForgeAvatar(name: "Ada Lovelace", status: .online).controlSize(.small)
            SwiftForgeAvatar(name: "Grace Hopper", status: .away)
            SwiftForgeAvatar(name: "Katherine Johnson", status: .busy).controlSize(.large)
            SwiftForgeAvatar(name: "", status: .offline)
            SwiftForgeAvatar(name: "山田 太郎")
            SwiftForgeAvatar(name: "محمد علي")
        }
        SwiftForgeAvatarGroup(
            ["Ada Lovelace", "Grace Hopper", "Katherine Johnson", "Alan Turing", "Margaret Hamilton", "Linus Pauling"].map {
                SwiftForgeAvatar(name: $0)
            },
            maxVisible: 4)
    }
    .padding()
}

#Preview("Without color, dark") {
    HStack(spacing: 12) {
        ForEach(SwiftForgeAvatar.Status.allCases, id: \.self) { status in
            SwiftForgeAvatar(name: "Ada Lovelace", status: status).controlSize(.large)
        }
    }
    .padding()
    .swiftForgeAccessibilitySimulation(differentiateWithoutColor: true)
    .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeAvatarGroup(
            ["Ada Lovelace", "Grace Hopper", "Katherine Johnson", "Alan Turing", "Linus Pauling"].map {
                SwiftForgeAvatar(name: $0, status: .online)
            },
            maxVisible: 3)
    }
}
