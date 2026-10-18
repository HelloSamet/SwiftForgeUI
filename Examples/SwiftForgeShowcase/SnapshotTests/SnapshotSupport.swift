//
//  SnapshotSupport.swift
//  SnapshotTests
//
//  Dependency-free snapshot testing (ADR-0006). Views are hosted in a real
//  window of the Showcase app — `ImageRenderer` can't draw UIKit-backed
//  controls such as text fields — and compared with reference PNGs in
//  `Examples/SwiftForgeShowcase/__Snapshots__`, a checkout of the separate
//  SwiftForgeUI-Snapshots repository that `scripts/snapshots.sh fetch` makes
//  at the revision pinned in `Examples/SwiftForgeShowcase/snapshots.revision`.
//  Keeping the images out of this repository keeps them out of every app
//  that adds SwiftForgeUI as a package.
//
//  The test bundle uses the app's copy of SwiftForgeUI (through the bundle
//  loader) instead of linking its own, so environment keys set here and read
//  by components are the same symbols. iOS never draws the contents of
//  secure text fields into screenshots, so those render empty.
//
//  Record references with:
//    TEST_RUNNER_SWIFTFORGE_RECORD_SNAPSHOTS=1 xcodebuild test -scheme SwiftForgeShowcase …
//

import SwiftForgeUI
import SwiftUI
import Testing
import UIKit

@testable import SwiftForgeShowcase

/// One cell of the snapshot matrix.
struct SnapshotVariant: CustomStringConvertible, Sendable {

    var theme: SwiftForgeTheme = .forge
    var colorScheme: ColorScheme = .light
    var dynamicTypeSize: DynamicTypeSize = .large
    var layoutDirection: LayoutDirection = .leftToRight
    var increasedContrast = false
    var reduceTransparency = false
    var boldText = false
    /// The canvas width, and whether it's the regular width of an iPad.
    var width: CGFloat = 390
    var horizontalSizeClass: UserInterfaceSizeClass = .compact

    var description: String {
        var parts = [theme.id, colorScheme == .dark ? "dark" : "light"]
        if dynamicTypeSize != .large { parts.append(String(describing: dynamicTypeSize)) }
        if layoutDirection == .rightToLeft { parts.append("rtl") }
        if increasedContrast { parts.append("hc") }
        if reduceTransparency { parts.append("reduced-transparency") }
        if boldText { parts.append("bold-text") }
        if horizontalSizeClass == .regular { parts.append("ipad") }
        return parts.joined(separator: "-")
    }

    /// Every built-in theme in both color schemes; AX5, RTL, and Increase
    /// Contrast in Forge; AX5 in the densest and the boldest theme;
    /// Reduce Transparency in the theme with glass surfaces; and Bold Text in Forge.
    static let matrix: [SnapshotVariant] =
        SwiftForgeTheme.builtIn.flatMap { [SnapshotVariant(theme: $0), SnapshotVariant(theme: $0, colorScheme: .dark)] } + [
            SnapshotVariant(dynamicTypeSize: .accessibility5),
            SnapshotVariant(layoutDirection: .rightToLeft),
            SnapshotVariant(colorScheme: .dark, increasedContrast: true),
            SnapshotVariant(theme: .neoBrutal, dynamicTypeSize: .accessibility5),
            SnapshotVariant(theme: .mono, dynamicTypeSize: .accessibility5),
            SnapshotVariant(theme: .aurora, reduceTransparency: true),
            SnapshotVariant(boldText: true),
        ]

    /// The smaller matrix for components added with the component catalog
    /// (ADR-0015): every built-in theme in both color schemes, and AX5,
    /// right to left, and Bold Text in Forge. It keeps the reference images'
    /// size in check as the catalog grows.
    static let catalogMatrix: [SnapshotVariant] =
        SwiftForgeTheme.builtIn.flatMap { [SnapshotVariant(theme: $0), SnapshotVariant(theme: $0, colorScheme: .dark)] } + [
            SnapshotVariant(dynamicTypeSize: .accessibility5),
            SnapshotVariant(layoutDirection: .rightToLeft),
            SnapshotVariant(boldText: true),
        ]

    /// An iPad in portrait (820 pt, regular width), in the default theme and
    /// in a dark theme, for components whose layout depends on width.
    static let iPadMatrix: [SnapshotVariant] = [
        SnapshotVariant(width: 820, horizontalSizeClass: .regular),
        SnapshotVariant(theme: .midnight, colorScheme: .dark, width: 820, horizontalSizeClass: .regular),
    ]
}

@MainActor
enum Snapshot {

    static let scale: CGFloat = 2
    /// A channel may differ by this much before a pixel counts as changed.
    static let channelTolerance = 8
    /// The share of pixels that may change before a snapshot fails.
    static let pixelTolerance = 0.002

    /// Snapshots are only comparable on the OS they were recorded on, because
    /// font rendering changes between major releases.
    nonisolated static let pinnedSystemMajorVersion = 18

    nonisolated static var isPinnedEnvironment: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion == pinnedSystemMajorVersion
    }

    nonisolated static var isRecording: Bool {
        ProcessInfo.processInfo.environment["SWIFTFORGE_RECORD_SNAPSHOTS"] == "1"
    }

    /// Renders `view` in `variant` and compares it with its reference image.
    static func verify<V: View>(
        _ view: V,
        named name: String,
        variant: SnapshotVariant,
        filePath: String = #filePath,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        let root = URL(fileURLWithPath: filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
        // Without the checkout every reference would look missing and be
        // recorded into a folder that isn't a repository.
        guard isReferenceCheckout(root) else {
            Issue.record(
                "Snapshot references aren't checked out. Run `scripts/snapshots.sh fetch`.", sourceLocation: sourceLocation)
            return
        }
        let image = await render(view, variant: variant)
        let directory = root.appendingPathComponent(URL(fileURLWithPath: filePath).deletingPathExtension().lastPathComponent)
        let reference = directory.appendingPathComponent("\(name).\(variant).png")

        if isBlank(image) {
            Issue.record(
                "\(name) [\(variant)] rendered as a single color; not comparing or recording it.", sourceLocation: sourceLocation)
            return
        }

        guard !isRecording, let expected = UIImage(contentsOfFile: reference.path) else {
            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
                try image.pngData()?.write(to: reference)
            } catch {
                Issue.record("Couldn't write \(reference.path): \(error)", sourceLocation: sourceLocation)
                return
            }
            Issue.record(
                "Recorded \(reference.lastPathComponent). Review it and run again without recording.",
                sourceLocation: sourceLocation
            )
            return
        }

        let difference = Self.difference(image, expected)
        if difference > pixelTolerance {
            let failures = directory.deletingLastPathComponent().appendingPathComponent(".failures")
            try? FileManager.default.createDirectory(at: failures, withIntermediateDirectories: true)
            let actualURL = failures.appendingPathComponent("\(name).\(variant).actual.png")
            try? image.pngData()?.write(to: actualURL)
            Issue.record(
                "\(name) [\(variant)] differs from its reference in \(String(format: "%.2f", difference * 100))% of pixels. Actual image: \(actualURL.path)",
                sourceLocation: sourceLocation
            )
        }
    }

    /// Hosts `view` in a window of the running app and draws it.
    ///
    /// Under load, `drawHierarchy` occasionally captures a window before it
    /// has drawn, producing a single flat color. No specimen renders as one
    /// color, so such a capture is retried with a longer wait.
    static func render<V: View>(_ view: V, variant: SnapshotVariant) async -> UIImage {
        let host = host(view, variant: variant)
        defer { host.window.isHidden = true }
        var image = UIImage()
        for attempt in 1...3 {
            // Let SwiftUI commit and UIKit-backed controls draw.
            try? await Task.sleep(for: .milliseconds(150 * attempt))
            host.controller.view.layoutIfNeeded()

            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            format.opaque = true
            image = UIGraphicsImageRenderer(bounds: host.window.bounds, format: format).image { _ in
                host.window.drawHierarchy(in: host.window.bounds, afterScreenUpdates: true)
            }
            if !isBlank(image) { break }
        }
        return image
    }

    /// Whether `directory` is a Git checkout, such as the one
    /// `scripts/snapshots.sh fetch` makes of the reference repository.
    nonisolated static func isReferenceCheckout(_ directory: URL) -> Bool {
        FileManager.default.fileExists(atPath: directory.appendingPathComponent(".git").path)
    }

    /// Whether every pixel of the image has the same color.
    static func isBlank(_ image: UIImage) -> Bool {
        guard let rgba = rgba(image), rgba.pixels.count >= 4 else { return true }
        let first = rgba.pixels[0..<4]
        return stride(from: 0, to: rgba.pixels.count, by: 4).allSatisfy { rgba.pixels[$0..<$0 + 4] == first }
    }

    /// A view hosted in a real window, sized to fit its content at the snapshot width.
    static func host<V: View>(_ view: V, variant: SnapshotVariant) -> (window: UIWindow, controller: UIViewController) {
        let root =
            view
            .padding(16)
            .frame(width: variant.width, alignment: .topLeading)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(variant.theme.colors.canvas)
            .swiftForgeTheme(variant.theme)
            .swiftForgeAccessibilitySimulation(
                increasedContrast: variant.increasedContrast, reduceMotion: true,
                reduceTransparency: variant.reduceTransparency
            )
            .environment(\.dynamicTypeSize, variant.dynamicTypeSize)
            .environment(\.layoutDirection, variant.layoutDirection)
            .environment(\.colorScheme, variant.colorScheme)
            .environment(\.locale, Locale(identifier: "en"))
            .environment(\.legibilityWeight, variant.boldText ? .bold : .regular)
            .environment(\.horizontalSizeClass, variant.horizontalSizeClass)

        let controller = UIHostingController(rootView: root)
        controller.safeAreaRegions = []
        controller.overrideUserInterfaceStyle = variant.colorScheme == .dark ? .dark : .light
        controller.traitOverrides.displayScale = scale
        controller.traitOverrides.layoutDirection = variant.layoutDirection == .rightToLeft ? .rightToLeft : .leftToRight
        controller.traitOverrides.preferredContentSizeCategory = UIContentSizeCategory(variant.dynamicTypeSize)
        controller.traitOverrides.legibilityWeight = variant.boldText ? .bold : .regular
        controller.traitOverrides.horizontalSizeClass = variant.horizontalSizeClass == .regular ? .regular : .compact

        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!
        let window = UIWindow(windowScene: scene)
        // Measure only once the controller is in a window, so the trait
        // overrides (Dynamic Type, layout direction) are in effect.
        window.frame = CGRect(x: 0, y: 0, width: variant.width, height: 4_000)
        window.rootViewController = controller
        window.isHidden = false
        controller.view.layoutIfNeeded()
        let size = controller.sizeThatFits(in: CGSize(width: variant.width, height: .greatestFiniteMagnitude))
        window.frame = CGRect(x: 0, y: 0, width: variant.width, height: ceil(size.height))
        controller.view.layoutIfNeeded()
        return (window, controller)
    }

    /// The share of pixels that differ beyond the channel tolerance; 1 if sizes differ.
    static func difference(_ lhs: UIImage, _ rhs: UIImage) -> Double {
        guard let a = rgba(lhs), let b = rgba(rhs), a.width == b.width, a.height == b.height else { return 1 }
        var changed = 0
        for index in stride(from: 0, to: a.pixels.count, by: 4) {
            for channel in 0..<4 where abs(Int(a.pixels[index + channel]) - Int(b.pixels[index + channel])) > channelTolerance {
                changed += 1
                break
            }
        }
        return Double(changed) / Double(a.width * a.height)
    }

    private static func rgba(_ image: UIImage) -> (pixels: [UInt8], width: Int, height: Int)? {
        guard let cgImage = image.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        var pixels = [UInt8](repeating: 0, count: width * height * 4)
        guard
            let context = CGContext(
                data: &pixels, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
                space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        return (pixels, width, height)
    }
}

private extension UIContentSizeCategory {
    init(_ size: DynamicTypeSize) {
        switch size {
        case .xSmall: self = .extraSmall
        case .small: self = .small
        case .medium: self = .medium
        case .large: self = .large
        case .xLarge: self = .extraLarge
        case .xxLarge: self = .extraExtraLarge
        case .xxxLarge: self = .extraExtraExtraLarge
        case .accessibility1: self = .accessibilityMedium
        case .accessibility2: self = .accessibilityLarge
        case .accessibility3: self = .accessibilityExtraLarge
        case .accessibility4: self = .accessibilityExtraExtraLarge
        case .accessibility5: self = .accessibilityExtraExtraExtraLarge
        @unknown default: self = .large
        }
    }
}
