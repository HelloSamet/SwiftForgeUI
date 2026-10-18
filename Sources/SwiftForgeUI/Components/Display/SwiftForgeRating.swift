//
//  SwiftForgeRating.swift
//  SwiftForgeUI
//

import SwiftUI

/// A star rating, either shown or chosen.
///
/// ```swift
/// SwiftForgeRating(value: 4.5)                              // read-only, with half stars
/// SwiftForgeRating("Your rating", value: $stars)            // tap or drag to choose
/// ```
///
/// Read-only ratings draw half stars for values in between and are sized
/// with the text around them. Interactive ratings choose whole stars — or
/// halves with `allowsHalfStars` — by tapping or dragging across the stars,
/// each of which keeps a 44-pt hit area.
///
/// Stars use the tone's text color, which contrasts 4.5:1 with surfaces;
/// empty stars are outlined, so the value never relies on color alone. A
/// half star mirrors in right-to-left languages.
///
/// VoiceOver reads "4.5 of 5 stars". An interactive rating is adjustable:
/// swipe up or down to change it by one step.
public struct SwiftForgeRating: View {

    private let title: Text?
    private let value: Double
    private let setValue: ((Double) -> Void)?
    private let maximum: Int
    private let allowsHalfStars: Bool
    private let tone: SwiftForgeTone

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var width: CGFloat = 0

    /// Creates a read-only rating.
    ///
    /// - Parameters:
    ///   - value: The rating, from 0 to `maximum`. Shown to the nearest half star.
    ///   - maximum: The number of stars. Defaults to 5.
    ///   - tone: The stars' color. Defaults to warning, the familiar gold.
    public init(value: Double, maximum: Int = 5, tone: SwiftForgeTone = .warning) {
        title = nil
        self.value = value
        setValue = nil
        self.maximum = max(1, maximum)
        allowsHalfStars = true
        self.tone = tone
    }

    /// Creates an interactive rating.
    ///
    /// - Parameters:
    ///   - titleKey: What's being rated, read by VoiceOver.
    ///   - value: The chosen rating, from 0 to `maximum`.
    ///   - maximum: The number of stars. Defaults to 5.
    ///   - allowsHalfStars: Whether half stars can be chosen. Defaults to `false`.
    ///   - tone: The stars' color. Defaults to warning, the familiar gold.
    public init(
        _ titleKey: LocalizedStringKey, value: Binding<Double>, maximum: Int = 5, allowsHalfStars: Bool = false,
        tone: SwiftForgeTone = .warning
    ) {
        title = Text(titleKey)
        self.value = value.wrappedValue
        setValue = { value.wrappedValue = $0 }
        self.maximum = max(1, maximum)
        self.allowsHalfStars = allowsHalfStars
        self.tone = tone
    }

    /// The content and behavior of the view.
    public var body: some View {
        let stars = HStack(spacing: setValue == nil ? theme.spacing.xxxs : 0) {
            ForEach(0..<maximum, id: \.self) { index in
                Image(systemName: Self.symbol(for: value, at: index))
                    .foregroundStyle(theme.colors[tone].text)
                    .frame(
                        minWidth: setValue == nil ? nil : theme.sizes.minimumHitTarget,
                        minHeight: setValue == nil ? nil : theme.sizes.minimumHitTarget)
            }
        }
        .opacity(isEnabled ? 1 : theme.opacity.disabled)

        if let setValue {
            stars
                .font(theme.typography.font(theme.typography.title3))
                .contentShape(Rectangle())
                .onGeometryChange(for: CGFloat.self) {
                    $0.size.width
                } action: {
                    width = $0
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in setValue(rating(at: drag.location.x)) }
                )
                .swiftForgeHaptic(trigger: value) { _, _ in .selection }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(title ?? Text(verbatim: ""))
                .accessibilityValue(accessibilityValue)
                .accessibilityAdjustableAction { direction in
                    let step = allowsHalfStars ? 0.5 : 1
                    let next = value + (direction == .increment ? step : -step)
                    setValue(min(max(next, 0), Double(maximum)))
                }
        } else {
            stars
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(accessibilityValue)
                .accessibilityAddTraits(.isImage)
        }
    }

    private var accessibilityValue: Text {
        SwiftForgeStrings.rating(value.formatted(.number.precision(.fractionLength(0...1))), of: maximum)
    }

    /// The value at a horizontal position, rounded up to the next star or
    /// half star, so touching a star selects it.
    private func rating(at x: CGFloat) -> Double {
        guard width > 0 else { return value }
        var fraction = min(max(x / width, 0), 1)
        if layoutDirection == .rightToLeft { fraction = 1 - fraction }
        let raw = fraction * Double(maximum)
        let step = allowsHalfStars ? 0.5 : 1
        return min(max((raw / step).rounded(.up) * step, step), Double(maximum))
    }

    /// The symbol for the star at `index` (0-based) for `value`: full, half,
    /// or empty, to the nearest half.
    static func symbol(for value: Double, at index: Int) -> String {
        let rounded = (value * 2).rounded() / 2
        let filled = rounded - Double(index)
        if filled >= 1 { return "star.fill" }
        if filled >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

// MARK: - Previews

private struct RatingPreview: View {
    @State private var stars = 3.0
    @State private var halves = 2.5

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SwiftForgeRating(value: 4.5)
            SwiftForgeRating(value: 2.3, maximum: 5, tone: .accent)
            SwiftForgeRating("Your rating", value: $stars)
            SwiftForgeRating("Half stars", value: $halves, allowsHalfStars: true)
        }
        .padding()
    }
}

#Preview("Rating") { RatingPreview() }

#Preview("RTL, dark") {
    RatingPreview().environment(\.layoutDirection, .rightToLeft).preferredColorScheme(.dark)
}
