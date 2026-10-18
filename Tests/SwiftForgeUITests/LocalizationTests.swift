import Foundation
import Testing

@testable import SwiftForgeUI

@Suite("Localization")
struct LocalizationTests {

    static let keys =
        [
            "swiftforge.loading", "swiftforge.loadingComplete", "swiftforge.close",
            "swiftforge.field.clear", "swiftforge.field.optional",
            "swiftforge.field.showPassword", "swiftforge.field.hidePassword",
            "swiftforge.password.strength", "swiftforge.search", "swiftforge.cancel",
            "swiftforge.slider.lowerValue", "swiftforge.slider.upperValue",
            "swiftforge.picker.prompt", "swiftforge.picker.noResults",
            "swiftforge.chip.remove %@", "swiftforge.position %lld %lld",
            "swiftforge.disclosure.expanded", "swiftforge.disclosure.collapsed", "swiftforge.stepper.decrement",
            "swiftforge.stepper.increment", "swiftforge.rating.value %@ %lld", "swiftforge.otp.progress %lld %lld",
        ] + SwiftForgeTone.allCases.map(SwiftForgeStrings.toneKey)
        + SwiftForgePasswordStrength.allCases.map(SwiftForgeStrings.passwordStrengthKey)
        + SwiftForgeAvatar.Status.allCases.map(SwiftForgeStrings.avatarStatusKey) + ["swiftforge.avatarGroup.others %lld"]

    static let languages = ["en", "tr"]

    @Test("Every library string is translated", arguments: languages)
    func everyKeyIsTranslated(language: String) throws {
        let path = try #require(Bundle.module.path(forResource: language, ofType: "lproj"), "missing \(language).lproj")
        let bundle = try #require(Bundle(path: path))
        for key in Self.keys {
            let value = bundle.localizedString(forKey: key, value: "<missing>", table: nil)
            #expect(value != "<missing>" && value != key, "\(language): \(key)")
        }
    }

    @Test("Turkish translations differ from English")
    func turkishIsTranslated() throws {
        func value(_ key: String, _ language: String) throws -> String {
            let path = try #require(Bundle.module.path(forResource: language, ofType: "lproj"))
            return try #require(Bundle(path: path)).localizedString(forKey: key, value: nil, table: nil)
        }
        #expect(try value("swiftforge.loading", "en") == "Loading")
        #expect(try value("swiftforge.loading", "tr") == "Yükleniyor")
        #expect(try value("swiftforge.tone.danger", "tr") == "Hata")
    }

    @Test("Count and character strings are pluralized or formatted, not concatenated")
    func formattedStrings() throws {
        let path = try #require(Bundle.module.path(forResource: "en", ofType: "lproj"))
        let bundle = try #require(Bundle(path: path))
        let format = bundle.localizedString(forKey: "swiftforge.badge.count %lld", value: nil, table: nil)
        #expect(String.localizedStringWithFormat(format, 1) == "1 new item")
        #expect(String.localizedStringWithFormat(format, 3) == "3 new items")
        let counter = bundle.localizedString(forKey: "swiftforge.field.characterCount %lld %lld", value: nil, table: nil)
        #expect(String(format: counter, 12, 80) == "12 of 80 characters")
        let position = bundle.localizedString(forKey: "swiftforge.position %lld %lld", value: nil, table: nil)
        #expect(String(format: position, 2, 5) == "2 of 5")
    }
}
