//
//  SwiftForgeText.swift
//  SwiftForgeUI
//

import SwiftUI

/// Text a component both displays and announces to VoiceOver.
///
/// Accessibility announcements take a `String`, which can't be recovered
/// from a SwiftUI `Text`, so components that announce their content store it
/// as a localized resource or verbatim string instead.
struct SwiftForgeText: Sendable, Equatable {

    enum Storage: Sendable, Equatable {
        case resource(LocalizedStringResource)
        case verbatim(String)
    }

    let storage: Storage

    init(_ resource: LocalizedStringResource) {
        storage = .resource(resource)
    }

    init(verbatim: String) {
        storage = .verbatim(verbatim)
    }

    var text: Text {
        switch storage {
        case .resource(let resource): Text(resource)
        case .verbatim(let string): Text(verbatim: string)
        }
    }

    var string: String {
        switch storage {
        case .resource(let resource): String(localized: resource)
        case .verbatim(let string): string
        }
    }
}
