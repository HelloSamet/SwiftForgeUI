import SwiftUI
import Testing
import UIKit

@testable import SwiftForgeUI

extension SwiftForgeTheme: CustomTestStringConvertible {
    /// The name shown for this value in test results.
    public var testDescription: String { id }
}

/// A rendered SwiftUI view whose pixels can be inspected. `ImageRenderer`
/// draws SwiftUI-native views faithfully; UIKit-backed controls (text fields,
/// spinners) are covered by the hosted snapshot tests in the Showcase project.
@MainActor
struct RenderedView {

    let size: CGSize
    private let pixels: [UInt8]
    private let pixelWidth: Int

    init<V: View>(_ view: V, width: CGFloat? = nil, height: CGFloat? = nil, colorScheme: ColorScheme = .light) {
        let renderer = ImageRenderer(
            content:
                view
                .frame(width: width, height: height)
                .environment(\.colorScheme, colorScheme)
        )
        renderer.scale = 1
        let image = renderer.cgImage!
        size = CGSize(width: image.width, height: image.height)
        pixelWidth = image.width
        var buffer = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let context = CGContext(
            data: &buffer, width: image.width, height: image.height, bitsPerComponent: 8,
            bytesPerRow: image.width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.draw(image, in: CGRect(origin: .zero, size: size))
        pixels = buffer
    }

    /// The pixel at (x, y), measured from the top-left corner.
    func color(x: Int, y: Int) -> (red: Int, green: Int, blue: Int, alpha: Int) {
        let index = (y * pixelWidth + x) * 4
        return (Int(pixels[index]), Int(pixels[index + 1]), Int(pixels[index + 2]), Int(pixels[index + 3]))
    }

    func matches(x: Int, y: Int, hex: UInt32, tolerance: Int = 3) -> Bool {
        let pixel = color(x: x, y: y)
        let expected = (Int((hex >> 16) & 0xFF), Int((hex >> 8) & 0xFF), Int(hex & 0xFF))
        return abs(pixel.red - expected.0) <= tolerance
            && abs(pixel.green - expected.1) <= tolerance
            && abs(pixel.blue - expected.2) <= tolerance
    }

    /// Whether the pixel at (x, y) is a token's resolved color.
    func matches(x: Int, y: Int, token: SwiftForgeColor, colorScheme: ColorScheme = .light, tolerance: Int = 3) -> Bool {
        let resolved = token.resolve(colorScheme: colorScheme, increasedContrast: false)
        let pixel = color(x: x, y: y)
        func channel(_ value: Float) -> Int { Int((value * 255).rounded()) }
        return abs(pixel.red - channel(resolved.red)) <= tolerance
            && abs(pixel.green - channel(resolved.green)) <= tolerance
            && abs(pixel.blue - channel(resolved.blue)) <= tolerance
    }
}
