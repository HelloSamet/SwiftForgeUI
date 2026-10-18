import Foundation
import Observation
import SwiftUI
import Testing

@testable import SwiftForgeUI

@MainActor
@Suite("Theme manager")
struct ThemeManagerTests {

    @Test("Without a stored choice, the manager uses the default theme")
    func defaultTheme() {
        #expect(SwiftForgeThemeManager(store: nil).theme == .forge)
        #expect(SwiftForgeThemeManager(defaultTheme: .paper, store: nil).theme == .paper)
        #expect(SwiftForgeThemeManager(themes: [.mono, .aurora], store: nil).theme == .mono)
        #expect(SwiftForgeThemeManager(themes: [], store: nil).theme == .forge)
    }

    @Test("The stored choice is restored before the first frame")
    func restoresSynchronously() {
        let manager = SwiftForgeThemeManager(store: SwiftForgeInMemoryThemeStore(themeID: "neo-brutal"))
        #expect(manager.theme == .neoBrutal)
    }

    @Test("An unknown stored identifier falls back to the default theme")
    func unknownStoredID() {
        let manager = SwiftForgeThemeManager(store: SwiftForgeInMemoryThemeStore(themeID: "retired-theme"))
        #expect(manager.theme == .forge)
    }

    @Test("Selecting a theme persists it for the next launch")
    func selectionPersists() {
        let store = SwiftForgeInMemoryThemeStore()
        let manager = SwiftForgeThemeManager(store: store)
        #expect(manager.select(id: "midnight"))
        #expect(manager.theme == .midnight)
        #expect(store.loadThemeID() == "midnight")
        #expect(SwiftForgeThemeManager(store: store).theme == .midnight)
    }

    @Test("Selecting an unknown identifier changes nothing")
    func unknownSelection() {
        let store = SwiftForgeInMemoryThemeStore(themeID: "paper")
        let manager = SwiftForgeThemeManager(store: store)
        #expect(!manager.select(id: "nope"))
        #expect(manager.theme == .paper)
        #expect(store.loadThemeID() == "paper")
    }

    @Test("Custom themes can be offered, selected, and restored")
    func customTheme() {
        let acme = SwiftForgeTheme(id: "acme", displayName: "Acme", basedOn: .forge) { $0.radius.control = 20 }
        let store = SwiftForgeInMemoryThemeStore()
        let manager = SwiftForgeThemeManager(themes: SwiftForgeTheme.builtIn + [acme], store: store)
        manager.select(acme)
        #expect(SwiftForgeThemeManager(themes: SwiftForgeTheme.builtIn + [acme], store: store).theme == acme)
    }

    @Test("Reset returns to the default theme and forgets the choice")
    func reset() {
        let store = SwiftForgeInMemoryThemeStore(themeID: "aurora")
        let manager = SwiftForgeThemeManager(store: store)
        manager.reset()
        #expect(manager.theme == .forge)
        #expect(store.loadThemeID() == nil)
    }

    @Test("Views observing the manager update when the theme changes")
    func observation() {
        let manager = SwiftForgeThemeManager(store: nil)
        let changed = Box()
        withObservationTracking {
            _ = manager.theme
        } onChange: {
            changed.value = true
        }
        manager.select(.mono)
        #expect(changed.value)
    }

    @Test("A theme applied with the manager reaches components")
    func appliesTheme() {
        struct Probe: View {
            @Environment(\.swiftForgeTheme) private var theme
            var body: some View { Rectangle().fill(theme.colors.accent.solid).frame(width: 10, height: 10) }
        }
        let manager = SwiftForgeThemeManager(store: SwiftForgeInMemoryThemeStore(themeID: "paper"))
        #expect(RenderedView(Probe().swiftForgeTheme(manager)).matches(x: 5, y: 5, hex: 0x1C1A17))
    }

    private final class Box: @unchecked Sendable {
        var value = false
    }
}

@Suite("Theme stores")
struct ThemeStoreTests {

    @Test("The UserDefaults store round-trips and removes the identifier")
    func userDefaults() throws {
        let suite = "SwiftForgeUITests.\(UUID().uuidString)"
        defer { UserDefaults().removePersistentDomain(forName: suite) }
        let store = SwiftForgeUserDefaultsThemeStore(suiteName: suite)
        #expect(store.loadThemeID() == nil)
        store.saveThemeID("mono")
        #expect(store.loadThemeID() == "mono")
        #expect(SwiftForgeUserDefaultsThemeStore(suiteName: suite).loadThemeID() == "mono")
        store.saveThemeID(nil)
        #expect(store.loadThemeID() == nil)
    }

    @Test("Stores with different keys don't share a choice")
    func keys() {
        let suite = "SwiftForgeUITests.\(UUID().uuidString)"
        defer { UserDefaults().removePersistentDomain(forName: suite) }
        SwiftForgeUserDefaultsThemeStore(key: "a", suiteName: suite).saveThemeID("paper")
        #expect(SwiftForgeUserDefaultsThemeStore(key: "b", suiteName: suite).loadThemeID() == nil)
    }
}
