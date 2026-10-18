//
//  SwiftForgeStrings.swift
//  SwiftForgeUI
//
//  The library's own user-facing strings. `Text` values follow the SwiftUI
//  environment's locale; `String` values follow the device language and are
//  only used outside SwiftUI views (accessibility announcements).
//

import SwiftUI

enum SwiftForgeStrings {

    static var loading: Text { Text("swiftforge.loading", bundle: .module) }
    static var close: Text { Text("swiftforge.close", bundle: .module) }
    static var clearText: Text { Text("swiftforge.field.clear", bundle: .module) }
    static var optional: Text { Text("swiftforge.field.optional", bundle: .module) }
    static var showPassword: Text { Text("swiftforge.field.showPassword", bundle: .module) }
    static var hidePassword: Text { Text("swiftforge.field.hidePassword", bundle: .module) }

    static var passwordStrength: Text { Text("swiftforge.password.strength", bundle: .module) }
    static var search: Text { Text("swiftforge.search", bundle: .module) }
    static var cancel: Text { Text("swiftforge.cancel", bundle: .module) }
    static var cancelResource: LocalizedStringResource {
        LocalizedStringResource("swiftforge.cancel", bundle: .atURL(Bundle.module.bundleURL))
    }
    static var sliderLowerValue: Text { Text("swiftforge.slider.lowerValue", bundle: .module) }
    static var sliderUpperValue: Text { Text("swiftforge.slider.upperValue", bundle: .module) }
    static var pickerPrompt: Text { Text("swiftforge.picker.prompt", bundle: .module) }
    static var pickerNoResults: Text { Text("swiftforge.picker.noResults", bundle: .module) }

    static func passwordStrengthName(_ strength: SwiftForgePasswordStrength) -> Text {
        Text(LocalizedStringKey(passwordStrengthKey(strength)), bundle: .module)
    }

    /// Built as a plain string: interpolating into `LocalizedStringKey`
    /// would turn the value into a format argument.
    static func passwordStrengthKey(_ strength: SwiftForgePasswordStrength) -> String {
        "swiftforge.password." + strength.rawValue
    }

    static func avatarStatus(_ status: SwiftForgeAvatar.Status) -> Text {
        Text(LocalizedStringKey(avatarStatusKey(status)), bundle: .module)
    }

    static func avatarStatusKey(_ status: SwiftForgeAvatar.Status) -> String {
        "swiftforge.avatar." + status.rawValue
    }

    /// "3 others", for the people an avatar group doesn't show, in the device
    /// language — a string, so it can join a formatted list of names.
    static func avatarGroupOthers(_ count: Int) -> String {
        String(localized: "swiftforge.avatarGroup.others \(count)", bundle: .module)
    }

    static var expanded: Text { Text("swiftforge.disclosure.expanded", bundle: .module) }
    static var collapsed: Text { Text("swiftforge.disclosure.collapsed", bundle: .module) }
    static var decrement: Text { Text("swiftforge.stepper.decrement", bundle: .module) }
    static var increment: Text { Text("swiftforge.stepper.increment", bundle: .module) }

    /// "3.5 of 5 stars": the plural follows the maximum.
    static func rating(_ value: String, of maximum: Int) -> Text {
        Text("swiftforge.rating.value \(value) \(maximum)", bundle: .module)
    }

    /// "4 of 6 digits entered".
    static func otpProgress(_ entered: Int, of length: Int) -> Text {
        Text("swiftforge.otp.progress \(entered) \(length)", bundle: .module)
    }

    static func remove(_ title: Text) -> Text {
        Text("swiftforge.chip.remove \(title)", bundle: .module)
    }

    /// "2 of 5": an item's position in a group.
    static func position(_ index: Int, of count: Int) -> Text {
        Text("swiftforge.position \(index) \(count)", bundle: .module)
    }

    static func characterCount(_ count: Int, limit: Int) -> Text {
        Text("swiftforge.field.characterCount \(count) \(limit)", bundle: .module)
    }

    static func badgeCount(_ count: Int) -> Text {
        Text("swiftforge.badge.count \(count)", bundle: .module)
    }

    static func toneName(_ tone: SwiftForgeTone) -> Text {
        Text(LocalizedStringKey(toneKey(tone)), bundle: .module)
    }

    static func toneKey(_ tone: SwiftForgeTone) -> String {
        "swiftforge.tone.\(tone.rawValue)"
    }

    // MARK: Device-language strings, for announcements

    static var loadingString: String { String(localized: "swiftforge.loading", bundle: .module) }
    static var loadingCompleteString: String { String(localized: "swiftforge.loadingComplete", bundle: .module) }

    static func toneNameString(_ tone: SwiftForgeTone) -> String {
        String(localized: String.LocalizationValue(toneKey(tone)), bundle: .module)
    }
}
