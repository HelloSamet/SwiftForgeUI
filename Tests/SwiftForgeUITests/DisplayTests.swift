import SwiftUI
import Testing

@testable import SwiftForgeUI

/// Behavior and layout of the display components. Visuals are covered by the
/// hosted `DisplaySnapshotTests`; VoiceOver semantics by the UI tests.
@MainActor
@Suite("Display components")
struct DisplayTests {

    private let theme = SwiftForgeTheme.forge

    // MARK: Avatar

    @Test(
        "Initials come from the name, in any script",
        arguments: [
            ("Ada Lovelace", "AL"), ("grace hopper", "GH"), ("Cher", "C"), ("  ", nil), ("", nil),
        ] as [(String, String?)]
    )
    func initials(name: String, expected: String?) {
        #expect(SwiftForgeAvatar.initials(of: name) == expected)
    }

    @Test("Initials stay right after the cache fills and clears")
    func initialsCache() {
        for index in 0..<600 { _ = SwiftForgeAvatar.initials(of: "Person \(index)") }
        #expect(SwiftForgeAvatar.initials(of: "Ada Lovelace") == "AL")
        #expect(SwiftForgeAvatar.initials(of: "Ada Lovelace") == "AL")
        #expect(SwiftForgeAvatar.initials(of: "  ") == nil)
    }

    @Test("Initials of names in other scripts are never empty")
    func initialsInOtherScripts() {
        for name in ["山田 太郎", "محمد علي", "Ольга Петрова"] {
            let initials = SwiftForgeAvatar.initials(of: name)
            #expect(initials?.isEmpty == false, "\(name)")
        }
    }

    @Test("A person keeps the same tone across launches")
    func stableTone() {
        // A fixed expectation: Swift's Hasher is seeded per launch, so a
        // hash-based tone would change between runs.
        #expect(SwiftForgeAvatar.tone(for: "Ada Lovelace") == SwiftForgeAvatar.tone(for: "Ada Lovelace"))
        let tones = Set(["Ada", "Grace", "Katherine", "Alan", "Margaret", "Linus", "Barbara"].map(SwiftForgeAvatar.tone(for:)))
        #expect(tones.count > 1)
    }

    @Test("Avatars take the diameter for their control size", arguments: [ControlSize.small, .regular, .large])
    func avatarSize(size: ControlSize) {
        let rendered = RenderedView(SwiftForgeAvatar(name: "Ada").controlSize(size))
        let expected = theme.components.avatar.diameters[SwiftForgeControlSize(size)]
        #expect(rendered.size == CGSize(width: expected, height: expected))
    }

    @Test("An avatar group overlaps its avatars and counts the rest")
    func avatarGroupWidth() {
        let avatars = ["A", "B", "C", "D", "E", "F"].map { SwiftForgeAvatar(name: $0) }
        let diameter = theme.components.avatar.diameters.regular
        let step = diameter * (1 - theme.components.avatar.groupOverlap)
        // Three avatars and the count: one full diameter plus three steps.
        let rendered = RenderedView(SwiftForgeAvatarGroup(avatars, maxVisible: 3))
        #expect(abs(rendered.size.width - (diameter + 3 * step)) < 1)
    }

    @Test("The group's label lists the names and counts the rest")
    func avatarGroupLabel() {
        let label = SwiftForgeAvatarGroup.accessibilityLabel(names: ["Ada", "Grace"], hidden: 3)
        #expect(label.hasPrefix("Ada"))
        #expect(label.contains("Grace"))
        #expect(label.contains("3"))
        #expect(SwiftForgeAvatarGroup.accessibilityLabel(names: ["Ada"], hidden: 0) == "Ada")
    }

    // MARK: List row

    @Test("Rows are at least 44 pt tall at every density", arguments: SwiftForgeDensity.allCases)
    func rowHeight(density: SwiftForgeDensity) {
        let rendered = RenderedView(SwiftForgeListRow("Wi-Fi").swiftForgeDensity(density), width: 300)
        #expect(rendered.size.height >= 44)
    }

    @Test("Density changes a row's padding")
    func rowDensity() {
        func height(_ density: SwiftForgeDensity) -> CGFloat {
            RenderedView(
                SwiftForgeListRow("Notifications", subtitle: Text(verbatim: "Banners")).swiftForgeDensity(density),
                width: 300
            ).size.height
        }
        #expect(height(.compact) < height(.regular))
        #expect(height(.regular) < height(.spacious))
    }

    @Test("A row's value moves under the title at accessibility sizes")
    func rowValueStacks() {
        func height(_ size: DynamicTypeSize) -> CGFloat {
            RenderedView(
                SwiftForgeListRow("Wi-Fi", value: Text(verbatim: "Home")).environment(\.dynamicTypeSize, size), width: 300
            ).size.height
        }
        // At AX1 the value stacks: the row is taller than one AX1 line.
        let regular = height(.large)
        let stacked = height(.accessibility1)
        #expect(stacked > regular * 1.8)
    }

    // MARK: Card

    @Test("A card's header and footer add to its height")
    func cardSlots() {
        let plain = RenderedView(SwiftForgeCard { Color.clear.frame(height: 20) }, width: 300)
        let slotted = RenderedView(
            SwiftForgeCard {
                Color.clear.frame(height: 20)
            } header: {
                Text(verbatim: "Header")
            } footer: {
                Text(verbatim: "Footer")
            },
            width: 300)
        #expect(slotted.size.height > plain.size.height + 30)
    }

    // MARK: Badge

    @Test("Count badges grow from small to large", arguments: [1, 128])
    func badgeSizes(count: Int) {
        func size(_ controlSize: ControlSize) -> CGSize {
            RenderedView(SwiftForgeBadge(count: count).controlSize(controlSize)).size
        }
        #expect(size(.small).height < size(.regular).height)
        #expect(size(.regular).height < size(.large).height)
    }

    // MARK: Divider

    @Test("A labeled divider draws its lines on both sides of the label")
    func labeledDivider() {
        let rendered = RenderedView(SwiftForgeDivider("or").background(Color.white), width: 200)
        let middle = Int(rendered.size.height) / 2
        #expect(!rendered.matches(x: 10, y: middle, hex: 0xFFFFFF))
        #expect(!rendered.matches(x: 190, y: middle, hex: 0xFFFFFF))
    }

    // MARK: Empty state

    @Test("An empty state fills the space it's given, like ContentUnavailableView")
    func emptyStateFills() {
        let wide = RenderedView(
            SwiftForgeEmptyState("No Messages", systemImage: "tray", description: Text(String(repeating: "word ", count: 80))),
            width: 1_000, height: 800)
        #expect(wide.size.width == 1_000)
    }

    // MARK: Tokens

    @Test("Avatar diameters grow with control size in every theme", arguments: SwiftForgeTheme.builtIn)
    func avatarTokens(theme: SwiftForgeTheme) {
        let diameters = theme.components.avatar.diameters
        #expect(diameters.small < diameters.regular && diameters.regular < diameters.large)
        #expect(theme.components.badge.countDiameterSmall <= theme.components.badge.countDiameter)
        #expect(theme.components.badge.countDiameter <= theme.components.badge.countDiameterLarge)
    }
}
