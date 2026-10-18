//
//  SwiftForgeIcon.swift
//  SwiftForgeUI
//

import SwiftUI

/// An icon sized by the theme's icon tokens for the current control size,
/// scaled with Dynamic Type.
///
/// Components size their own icons; use `SwiftForgeIcon` for icons you
/// place in a component's slot — a list row's leading view, an empty state —
/// so they match the theme:
///
/// ```swift
/// SwiftForgeIcon("bell.badge")
///     .foregroundStyle(theme.colors.accent.text)
/// ```
///
/// The size comes from ``SwiftForgeSizes/iconSmall``,
/// ``SwiftForgeSizes/iconRegular``, or ``SwiftForgeSizes/iconLarge`` for the
/// environment's `controlSize`, and grows with Dynamic Type like body text.
///
/// - Do: use symbols with `forward` and `backward` in their names, such as
///   `chevron.forward`; they mirror in right-to-left languages.
/// - Don't: use `chevron.right` for "next": it points the wrong way in
///   right-to-left languages.
///
/// Like `Image`, an icon is read by VoiceOver when its symbol has a
/// description. Hide decorative icons with `accessibilityHidden(true)`, and
/// label meaningful ones with `accessibilityLabel(_:)`.
public struct SwiftForgeIcon: View {

    private enum Source {
        case symbol(String)
        case image(Image)
    }

    private let source: Source

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize
    @ScaledMetric(relativeTo: .body) private var scale: CGFloat = 1

    /// Creates an icon from an SF Symbol.
    ///
    /// - Parameter systemName: The name of the symbol.
    public init(_ systemName: String) {
        source = .symbol(systemName)
    }

    /// Creates an icon from an image, such as a template image in your asset
    /// catalog. The image is scaled to fit a square of the icon size.
    ///
    /// - Parameter image: The image to show.
    public init(_ image: Image) {
        source = .image(image)
    }

    /// The content and behavior of the view.
    public var body: some View {
        let size = theme.sizes.iconSize(for: controlSize) * scale
        switch source {
        case .symbol(let name):
            Image(systemName: name)
                .font(.system(size: size))
                .frame(minWidth: size, minHeight: size)
        case .image(let image):
            image
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
}

extension SwiftForgeSizes {

    /// The base icon size for a SwiftUI control size, before Dynamic Type.
    func iconSize(for controlSize: ControlSize) -> CGFloat {
        switch SwiftForgeControlSize(controlSize) {
        case .small: iconSmall
        case .regular: iconRegular
        case .large: iconLarge
        }
    }
}

/// Where a component places its icon relative to its title.
///
/// Cases are added only in major releases, so you can switch over it
/// exhaustively.
public enum SwiftForgeIconPlacement: Sendable, Hashable, CaseIterable {

    /// Before the title: on the left in left-to-right languages. The default.
    case leading

    /// After the title, such as a forward arrow on a "Continue" button.
    case trailing
}

extension EnvironmentValues {

    /// Where SwiftForgeUI components place icons relative to their titles.
    /// Defaults to ``SwiftForgeIconPlacement/leading``.
    @Entry public var swiftForgeIconPlacement: SwiftForgeIconPlacement = .leading
}

extension View {

    /// Places the icons of SwiftForgeUI buttons and chips beneath this view
    /// before or after their titles.
    ///
    /// ```swift
    /// Button("Continue", systemImage: "arrow.forward") { next() }
    ///     .buttonStyle(.swiftForge(.filled))
    ///     .swiftForgeIconPlacement(.trailing)
    /// ```
    ///
    /// Placement is relative to reading direction: a trailing icon appears on
    /// the left in right-to-left languages.
    public func swiftForgeIconPlacement(_ placement: SwiftForgeIconPlacement) -> some View {
        environment(\.swiftForgeIconPlacement, placement)
    }
}

#Preview("Icons") {
    VStack(spacing: 12) {
        HStack(spacing: 16) {
            SwiftForgeIcon("bell.badge").controlSize(.small)
            SwiftForgeIcon("bell.badge")
            SwiftForgeIcon("bell.badge").controlSize(.large)
            SwiftForgeIcon(Image(systemName: "star.fill"))
        }
        HStack(spacing: 16) {
            SwiftForgeIcon("chevron.forward")
            SwiftForgeIcon("arrow.forward")
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
    .padding()
}

#Preview("AX5") {
    HStack(spacing: 16) {
        SwiftForgeIcon("bell.badge").controlSize(.small)
        SwiftForgeIcon("bell.badge")
        SwiftForgeIcon("bell.badge").controlSize(.large)
    }
    .padding()
    .environment(\.dynamicTypeSize, .accessibility5)
}
