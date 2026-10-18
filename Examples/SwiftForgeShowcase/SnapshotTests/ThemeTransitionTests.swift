//
//  ThemeTransitionTests.swift
//  SnapshotTests
//
//  Runtime theme switching, rendered in a real window: the change animates
//  through intermediate colors, and happens at once with Reduce Motion.
//

import SwiftForgeUI
import SwiftUI
import Testing
import UIKit

@testable import SwiftForgeShowcase

@MainActor
@Suite("Theme transitions", .serialized)
struct ThemeTransitionTests {

    private struct AccentProbe: View {
        @Environment(\.swiftForgeTheme) private var theme
        var body: some View {
            Rectangle().fill(theme.colors.accent.solid).frame(width: 40, height: 40)
        }
    }

    /// Forge's accent in light mode, and Paper's.
    private let forgeAccent = (red: 0x00, green: 0x62, blue: 0xD1)
    private let paperAccent = (red: 0x1C, green: 0x1A, blue: 0x17)

    @Test("Switching themes animates through intermediate colors")
    func animates() async throws {
        let manager = SwiftForgeThemeManager(store: nil)
        let window = host(AccentProbe().swiftForgeTheme(manager))
        defer { window.isHidden = true }
        try await Task.sleep(for: .milliseconds(300))
        #expect(close(pixel(window), forgeAccent))

        manager.select(.paper)
        try await Task.sleep(for: .milliseconds(90))
        let midway = pixel(window)
        #expect(!close(midway, forgeAccent) && !close(midway, paperAccent), "\(midway)")

        try await Task.sleep(for: .milliseconds(900))
        #expect(close(pixel(window), paperAccent))
    }

    @Test("With Reduce Motion, the theme changes at once")
    func reduceMotion() async throws {
        let manager = SwiftForgeThemeManager(store: nil)
        let window = host(AccentProbe().swiftForgeTheme(manager).swiftForgeAccessibilitySimulation(reduceMotion: true))
        defer { window.isHidden = true }
        try await Task.sleep(for: .milliseconds(300))

        manager.select(.paper)
        try await Task.sleep(for: .milliseconds(50))
        #expect(close(pixel(window), paperAccent))
    }

    // MARK: Helpers

    private func host<V: View>(_ view: V) -> UIWindow {
        let controller = UIHostingController(rootView: view.environment(\.colorScheme, .light))
        controller.overrideUserInterfaceStyle = .light
        controller.safeAreaRegions = []
        let scene = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first!
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        window.rootViewController = controller
        window.isHidden = false
        return window
    }

    /// The color at the center of the window, as currently displayed.
    private func pixel(_ window: UIWindow) -> (red: Int, green: Int, blue: Int) {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
        var rgba = [UInt8](repeating: 0, count: 4)
        let context = CGContext(
            data: &rgba, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.draw(image.cgImage!, in: CGRect(x: -20, y: -20, width: 40, height: 40))
        return (Int(rgba[0]), Int(rgba[1]), Int(rgba[2]))
    }

    private func close(_ a: (red: Int, green: Int, blue: Int), _ b: (red: Int, green: Int, blue: Int)) -> Bool {
        abs(a.red - b.red) <= 6 && abs(a.green - b.green) <= 6 && abs(a.blue - b.blue) <= 6
    }
}
