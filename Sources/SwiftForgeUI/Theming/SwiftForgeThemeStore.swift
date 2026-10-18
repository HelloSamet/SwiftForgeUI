//
//  SwiftForgeThemeStore.swift
//  SwiftForgeUI
//

import Foundation
import os

/// Persists the identifier of the theme a person chose.
///
/// ``SwiftForgeThemeManager`` reads the stored identifier once, synchronously,
/// when it's created — so the first frame already uses the chosen theme — and
/// writes it whenever the selection changes. Conform your own type to store
/// the choice elsewhere, such as in your app's settings model or in iCloud.
public protocol SwiftForgeThemeStore: Sendable {

    /// The stored theme identifier, or `nil` if none was stored.
    func loadThemeID() -> String?

    /// Stores a theme identifier, or removes it when `id` is `nil`.
    func saveThemeID(_ id: String?)
}

/// Stores the theme choice in `UserDefaults`.
public struct SwiftForgeUserDefaultsThemeStore: SwiftForgeThemeStore {

    /// The defaults key the identifier is stored under.
    public let key: String
    private let suiteName: String?

    /// Creates a store.
    ///
    /// - Parameters:
    ///   - key: The defaults key. Defaults to `"SwiftForgeUI.themeID"`.
    ///   - suiteName: An app group's suite, to share the choice with
    ///     extensions, or `nil` for the standard defaults.
    public init(key: String = "SwiftForgeUI.themeID", suiteName: String? = nil) {
        self.key = key
        self.suiteName = suiteName
    }

    private var defaults: UserDefaults {
        suiteName.flatMap(UserDefaults.init(suiteName:)) ?? .standard
    }

    /// The stored theme identifier, or `nil` if none was stored.
    public func loadThemeID() -> String? {
        defaults.string(forKey: key)
    }

    /// Stores a theme identifier, or removes it when `id` is `nil`.
    public func saveThemeID(_ id: String?) {
        if let id {
            defaults.set(id, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}

/// Keeps the theme choice in memory, for previews and tests.
public final class SwiftForgeInMemoryThemeStore: SwiftForgeThemeStore {

    private let storage: OSAllocatedUnfairLock<String?>

    /// Creates a store, optionally holding an identifier already.
    public init(themeID: String? = nil) {
        storage = OSAllocatedUnfairLock(initialState: themeID)
    }

    /// The stored theme identifier, or `nil` if none was stored.
    public func loadThemeID() -> String? {
        storage.withLock { $0 }
    }

    /// Stores a theme identifier, or removes it when `id` is `nil`.
    public func saveThemeID(_ id: String?) {
        storage.withLock { $0 = id }
    }
}
