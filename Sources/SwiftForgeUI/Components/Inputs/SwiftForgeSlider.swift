//
//  SwiftForgeSlider.swift
//  SwiftForgeUI
//

import SwiftUI

/// A labeled slider for choosing a value from a range.
///
/// ```swift
/// SwiftForgeSlider("Volume", value: $volume, in: 0...100, step: 5) { volume in
///     Text(volume / 100, format: .percent)
/// }
/// ```
///
/// The title sits above the track with the current value beside it. The
/// filled part of the track and the thumb use the tone's text color; the
/// empty part is outlined in the strong border color. Every part contrasts
/// at least 3:1 with the surface, and the filled part differs from the empty
/// one in shape as well as color. The thumb keeps a
/// 44-pt hit area, follows the drag, and snaps to `step` if one is given.
///
/// VoiceOver sees a standard adjustable slider: swipe up or down to change
/// the value, which is read with the value label. With a hardware keyboard,
/// the arrow keys move the focused slider by one step.
///
/// For a range of values, use ``SwiftForgeRangeSlider``.
public struct SwiftForgeSlider<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {

    private let title: Text
    @Binding private var value: V
    private let bounds: ClosedRange<V>
    private let step: V.Stride?
    private let tone: SwiftForgeTone
    private let valueLabel: ((V) -> Text)?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool
    @State private var trackWidth: CGFloat = 0
    @State private var isDragging = false

    /// Creates a slider.
    ///
    /// - Parameters:
    ///   - titleKey: The slider's title, shown above it and read by VoiceOver.
    ///   - value: The selected value.
    ///   - bounds: The range of values. Defaults to `0...1`.
    ///   - step: The distance between valid values, or `nil` for any value.
    ///   - tone: The color of the filled track. Defaults to the accent.
    ///   - valueLabel: The current value as text, shown beside the title and
    ///     read by VoiceOver, or `nil` to hide it.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0...1,
        step: V.Stride? = nil,
        tone: SwiftForgeTone = .accent,
        valueLabel: ((V) -> Text)? = nil
    ) {
        self.title = Text(titleKey)
        self._value = value
        self.bounds = bounds
        self.step = step
        self.tone = tone
        self.valueLabel = valueLabel
    }

    /// The content and behavior of the view.
    public var body: some View {
        let geometry = SwiftForgeSliderGeometry(bounds: bounds, step: step)
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            SwiftForgeSliderHeader(title: title, value: valueLabel?(value))
            SwiftForgeSliderTrack(
                lower: nil, upper: geometry.fraction(of: value), tone: tone, trackWidth: $trackWidth,
                activeThumb: isDragging ? .upper : nil, focusedThumb: isFocused ? .upper : nil
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        isDragging = true
                        value = geometry.value(at: drag.location.x, in: trackWidth, thumb: thumbDiameter)
                    }
                    .onEnded { _ in isDragging = false }
            )
            .focusable(isEnabled)
            .focused($isFocused)
            .onKeyPress(keys: [.leftArrow, .rightArrow]) { press in
                let forward = (press.key == .rightArrow) == (layoutDirection == .leftToRight)
                value = geometry.stepped(value, by: forward ? 1 : -1)
                return .handled
            }
        }
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .swiftForgeHaptic(trigger: step == nil ? 0 : Double(value)) { _, _ in step == nil ? nil : .selection }
        .accessibilityRepresentation {
            Slider(value: $value, in: bounds, step: geometry.accessibilityStep) { title }
                .accessibilityValue(valueLabel?(value) ?? Text(verbatim: ""))
        }
    }

    @Environment(\.layoutDirection) private var layoutDirection

    private var thumbDiameter: CGFloat { theme.components.slider.thumbDiameter }
}

extension SwiftForgeSlider {

    /// Creates a slider with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        value: Binding<V>,
        in bounds: ClosedRange<V> = 0...1,
        step: V.Stride? = nil,
        tone: SwiftForgeTone = .accent,
        valueLabel: ((V) -> Text)? = nil
    ) {
        self.title = Text(title)
        self._value = value
        self.bounds = bounds
        self.step = step
        self.tone = tone
        self.valueLabel = valueLabel
    }
}

/// A labeled slider for choosing a range of values, with a thumb at each end.
///
/// ```swift
/// SwiftForgeRangeSlider("Price", value: $price, in: 0...500, step: 10) { price in
///     Text("\(Int(price.lowerBound))–\(Int(price.upperBound)) €")
/// }
/// ```
///
/// Dragging moves the thumb nearest to the finger; thumbs never cross. Each
/// thumb is its own adjustable element for VoiceOver, read as "Minimum" and
/// "Maximum" with its value, and the arrow keys move the focused thumb.
public struct SwiftForgeRangeSlider<V: BinaryFloatingPoint>: View where V.Stride: BinaryFloatingPoint {

    private let title: Text
    @Binding private var value: ClosedRange<V>
    private let bounds: ClosedRange<V>
    private let step: V.Stride?
    private let tone: SwiftForgeTone
    private let valueLabel: ((ClosedRange<V>) -> Text)?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @FocusState private var focusedThumb: SwiftForgeSliderThumb?
    @State private var trackWidth: CGFloat = 0
    @State private var draggedThumb: SwiftForgeSliderThumb?

    /// Creates a range slider.
    ///
    /// - Parameters:
    ///   - titleKey: The slider's title, shown above it and read by VoiceOver.
    ///   - value: The selected range.
    ///   - bounds: The range of values. Defaults to `0...1`.
    ///   - step: The distance between valid values, or `nil` for any value.
    ///   - tone: The color of the filled track. Defaults to the accent.
    ///   - valueLabel: The selected range as text, shown beside the title,
    ///     or `nil` to hide it.
    public init(
        _ titleKey: LocalizedStringKey,
        value: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 0...1,
        step: V.Stride? = nil,
        tone: SwiftForgeTone = .accent,
        valueLabel: ((ClosedRange<V>) -> Text)? = nil
    ) {
        self.title = Text(titleKey)
        self._value = value
        self.bounds = bounds
        self.step = step
        self.tone = tone
        self.valueLabel = valueLabel
    }

    /// The content and behavior of the view.
    public var body: some View {
        let geometry = SwiftForgeSliderGeometry(bounds: bounds, step: step)
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            SwiftForgeSliderHeader(title: title, value: valueLabel?(value))
            SwiftForgeSliderTrack(
                lower: geometry.fraction(of: value.lowerBound), upper: geometry.fraction(of: value.upperBound), tone: tone,
                trackWidth: $trackWidth, activeThumb: draggedThumb, focusedThumb: focusedThumb
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        let newValue = geometry.value(at: drag.location.x, in: trackWidth, thumb: thumbDiameter)
                        let thumb = draggedThumb ?? nearestThumb(to: newValue)
                        draggedThumb = thumb
                        move(thumb, to: newValue)
                    }
                    .onEnded { _ in draggedThumb = nil }
            )
            .overlay { accessibilityThumbs(geometry) }
        }
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
        .swiftForgeHaptic(trigger: step == nil ? 0 : Double(value.lowerBound + value.upperBound)) { _, _ in
            step == nil ? nil : .selection
        }
        .accessibilityElement(children: .contain)
    }

    private var thumbDiameter: CGFloat { theme.components.slider.thumbDiameter }

    private func nearestThumb(to newValue: V) -> SwiftForgeSliderThumb {
        abs(newValue - value.lowerBound) <= abs(newValue - value.upperBound) && newValue <= value.upperBound
            ? .lower : .upper
    }

    /// Moves a thumb, keeping it on its side of the other.
    private func move(_ thumb: SwiftForgeSliderThumb, to newValue: V) {
        switch thumb {
        case .lower: value = min(newValue, value.upperBound)...value.upperBound
        case .upper: value = value.lowerBound...max(newValue, value.lowerBound)
        }
    }

    /// Invisible adjustable elements over each thumb, for VoiceOver and the
    /// keyboard. They sit on top of the drawn thumbs, so their frames match.
    private func accessibilityThumbs(_ geometry: SwiftForgeSliderGeometry<V>) -> some View {
        SwiftForgeSliderThumbLayout(
            lower: geometry.fraction(of: value.lowerBound), upper: geometry.fraction(of: value.upperBound),
            thumbDiameter: thumbDiameter, hitTarget: theme.sizes.minimumHitTarget
        ) {
            ForEach([SwiftForgeSliderThumb.lower, .upper], id: \.self) { thumb in
                Color.clear
                    .contentShape(Rectangle())
                    .focusable(isEnabled)
                    .focused($focusedThumb, equals: thumb)
                    .onKeyPress(keys: [.leftArrow, .rightArrow]) { press in
                        let forward = (press.key == .rightArrow) == (layoutDirection == .leftToRight)
                        let current = thumb == .lower ? value.lowerBound : value.upperBound
                        move(thumb, to: geometry.stepped(current, by: forward ? 1 : -1))
                        return .handled
                    }
                    .accessibilityElement()
                    .accessibilityLabel(title + Text(verbatim: ", ") + thumbName(thumb))
                    .accessibilityValue(
                        Text(Double(thumb == .lower ? value.lowerBound : value.upperBound), format: .number)
                    )
                    .accessibilityAdjustableAction { direction in
                        let current = thumb == .lower ? value.lowerBound : value.upperBound
                        move(thumb, to: geometry.stepped(current, by: direction == .increment ? 1 : -1))
                    }
                    .allowsHitTesting(false)
            }
        }
    }

    private func thumbName(_ thumb: SwiftForgeSliderThumb) -> Text {
        thumb == .lower ? SwiftForgeStrings.sliderLowerValue : SwiftForgeStrings.sliderUpperValue
    }
}

extension SwiftForgeRangeSlider {

    /// Creates a range slider with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        value: Binding<ClosedRange<V>>,
        in bounds: ClosedRange<V> = 0...1,
        step: V.Stride? = nil,
        tone: SwiftForgeTone = .accent,
        valueLabel: ((ClosedRange<V>) -> Text)? = nil
    ) {
        self.title = Text(title)
        self._value = value
        self.bounds = bounds
        self.step = step
        self.tone = tone
        self.valueLabel = valueLabel
    }
}

// MARK: - Shared parts

enum SwiftForgeSliderThumb: Hashable, Sendable {
    case lower, upper
}

/// Converts between values, fractions of the track, and positions.
struct SwiftForgeSliderGeometry<V: BinaryFloatingPoint> where V.Stride: BinaryFloatingPoint {

    let bounds: ClosedRange<V>
    let step: V.Stride?

    private var span: V { bounds.upperBound - bounds.lowerBound }

    /// The share of the track before `value`, from 0 to 1.
    func fraction(of value: V) -> CGFloat {
        guard span > 0 else { return 0 }
        return CGFloat((min(max(value, bounds.lowerBound), bounds.upperBound) - bounds.lowerBound) / span)
    }

    /// The value at `x` along a track `width` wide, where the thumb's center
    /// travels from half its diameter to the width minus that.
    func value(at x: CGFloat, in width: CGFloat, thumb diameter: CGFloat) -> V {
        let travel = max(width - diameter, 1)
        let fraction = min(max((x - diameter / 2) / travel, 0), 1)
        return snapped(bounds.lowerBound + V(fraction) * span)
    }

    /// `value` rounded to the nearest step and clamped to the bounds.
    func snapped(_ value: V) -> V {
        var result = min(max(value, bounds.lowerBound), bounds.upperBound)
        if let step, step > 0 {
            let steps = ((result - bounds.lowerBound) / V(step)).rounded()
            result = min(bounds.lowerBound + steps * V(step), bounds.upperBound)
        }
        return result
    }

    /// `value` moved by `count` steps — or by a twentieth of the range without one.
    func stepped(_ value: V, by count: Int) -> V {
        snapped(value + V(count) * V(accessibilityStep))
    }

    /// The increment for VoiceOver and the keyboard.
    var accessibilityStep: V.Stride {
        step ?? V.Stride(span / 20)
    }
}

/// The title and the value label above a slider's track.
struct SwiftForgeSliderHeader: View {

    let title: Text
    let value: Text?

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            title
                .foregroundStyle(theme.colors.textSecondary)
            Spacer(minLength: theme.spacing.xs)
            if let value {
                value
                    .monospacedDigit()
                    .foregroundStyle(theme.colors.textPrimary)
            }
        }
        .font(theme.typography.font(theme.typography.fieldLabel))
        .accessibilityHidden(true)
    }
}

/// The track, its filled part, and the thumbs, in a 44-pt-tall hit area.
struct SwiftForgeSliderTrack: View {

    /// The lower thumb's fraction, or `nil` for a single-value slider.
    let lower: CGFloat?
    let upper: CGFloat
    let tone: SwiftForgeTone
    @Binding var trackWidth: CGFloat
    let activeThumb: SwiftForgeSliderThumb?
    let focusedThumb: SwiftForgeSliderThumb?

    @Environment(\.swiftForgeTheme) private var theme
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        let travel = max(trackWidth - tokens.thumbDiameter, 0)
        let trackShape = theme.radius.shape(SwiftForgeRadius.capsule)
        ZStack(alignment: .leading) {
            // The empty track is outlined in a color that contrasts 3:1 with
            // the surface (WCAG 1.4.11); the filled part is solid. Shape, not
            // only color, separates them — themes whose tone text and border
            // colors match stay readable.
            trackShape
                .fill(theme.colors.fillMuted)
                .overlay { trackShape.strokeBorder(theme.colors.borderStrong, lineWidth: theme.borders.thin) }
                .frame(height: tokens.trackHeight)
            trackShape
                .fill(theme.colors[tone].text)
                .frame(
                    width: (upper - (lower ?? 0)) * travel + (lower == nil ? tokens.thumbDiameter / 2 : 0),
                    height: tokens.trackHeight
                )
                .offset(x: (lower ?? 0) * travel + (lower == nil ? 0 : tokens.thumbDiameter / 2))
            if let lower {
                thumb(.lower).offset(x: lower * travel)
            }
            thumb(.upper).offset(x: upper * travel)
        }
        .frame(maxWidth: .infinity, minHeight: theme.sizes.minimumHitTarget, alignment: .leading)
        .contentShape(Rectangle())
        .onGeometryChange(for: CGFloat.self) {
            $0.size.width
        } action: {
            trackWidth = $0
        }
        .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: activeThumb)
    }

    private var tokens: SwiftForgeSliderTokens { theme.components.slider }

    private func thumb(_ thumb: SwiftForgeSliderThumb) -> some View {
        let shape = theme.radius.shape(tokens.thumbCornerRadius)
        // The thumb is filled with the tone's text color, which contrasts
        // 4.5:1 with every surface, so its position is always visible.
        return
            shape
            .fill(theme.colors[tone].text)
            .overlay {
                if let width = tokens.thumbBorderWidth {
                    shape.strokeBorder(tokens.thumbBorderColor ?? theme.colors.borderStrong, lineWidth: width)
                }
            }
            .swiftForgeShadow(theme.elevation[tokens.thumbElevation])
            .frame(width: tokens.thumbDiameter, height: tokens.thumbDiameter)
            .swiftForgeFocusRing(focusedThumb == thumb, cornerRadius: min(tokens.thumbCornerRadius, tokens.thumbDiameter / 2))
            .scaleEffect(activeThumb == thumb && !accessibility.reduceMotion ? Self.activeScale : 1)
    }

    /// The dragged thumb grows slightly so it stays visible around a finger.
    private static let activeScale: CGFloat = 1.15  // swiftforge-lint: allow (proportion, not a size)
}

/// Places a 44-pt element centered on each thumb, for the range slider's
/// accessibility elements.
struct SwiftForgeSliderThumbLayout: Layout {

    let lower: CGFloat
    let upper: CGFloat
    let thumbDiameter: CGFloat
    let hitTarget: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let travel = max(bounds.width - thumbDiameter, 0)
        for (subview, fraction) in zip(subviews, [lower, upper]) {
            let center = CGPoint(x: bounds.minX + thumbDiameter / 2 + fraction * travel, y: bounds.midY)
            subview.place(at: center, anchor: .center, proposal: ProposedViewSize(width: hitTarget, height: hitTarget))
        }
    }
}

// MARK: - Previews

private struct SliderPreview: View {
    @State private var volume = 40.0
    @State private var brightness = 0.7
    @State private var price = 80.0...240.0

    var body: some View {
        VStack(spacing: 24) {
            SwiftForgeSlider("Volume", value: $volume, in: 0...100, step: 5) { Text(Int($0), format: .number) }
            SwiftForgeSlider("Brightness", value: $brightness) { Text($0, format: .percent.precision(.fractionLength(0))) }
            SwiftForgeRangeSlider("Price", value: $price, in: 0...500, step: 10) { range in
                Text(verbatim: "\(Int(range.lowerBound))–\(Int(range.upperBound)) €")
            }
            SwiftForgeSlider("Disabled", value: .constant(0.3)).disabled(true)
        }
        .padding()
    }
}

#Preview("Sliders") { SliderPreview() }

#Preview("Dark, AX5, RTL") {
    SliderPreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeSlider("Volume", value: .constant(60.0), in: 0...100) { Text(Int($0), format: .number) }
    }
}
