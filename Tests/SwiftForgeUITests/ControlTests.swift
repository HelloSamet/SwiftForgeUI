import SwiftUI
import Testing

@testable import SwiftForgeUI

/// Behavior and layout of the selection and input controls. Visuals across
/// themes and sizes are covered by the hosted `ControlSnapshotTests`;
/// VoiceOver semantics and interaction by the UI tests.
@MainActor
@Suite("Controls")
struct ControlTests {

    private let theme = SwiftForgeTheme.forge

    // MARK: Checkbox

    @Test("A checkbox row keeps a 44-pt hit area", arguments: [DynamicTypeSize.xSmall, .large])
    func checkboxHitArea(size: DynamicTypeSize) {
        let rendered = RenderedView(
            Toggle("A", isOn: .constant(false)).toggleStyle(.swiftForgeCheckbox).environment(\.dynamicTypeSize, size),
            width: 200)
        #expect(rendered.size.height >= 44)
    }

    @Test("A checked box fills with the tone; an unchecked one shows the surface")
    func checkboxFill() {
        func center(_ isOn: Bool) -> RenderedView {
            RenderedView(
                Toggle("A", isOn: .constant(isOn)).toggleStyle(.swiftForgeCheckbox).background(Color.white), width: 200)
        }
        // The box starts at the leading edge; its border is 2 pt, so x = 4 is inside the fill.
        let y = Int(center(true).size.height) / 2 - 4
        #expect(center(true).matches(x: 4, y: y, token: theme.colors.accent.solid))
        #expect(center(false).matches(x: 4, y: y, token: theme.colors.surface))
    }

    @Test("A description adds a line under the label")
    func descriptionGrowsTheRow() {
        let plain = RenderedView(Toggle("A", isOn: .constant(false)).toggleStyle(.swiftForgeCheckbox), width: 200)
        let described = RenderedView(
            Toggle("A", isOn: .constant(false)).toggleStyle(.swiftForgeCheckbox).swiftForgeDescription("More detail."),
            width: 200)
        #expect(described.size.height > plain.size.height)
    }

    // MARK: Password strength

    @Test("Strength levels fill one more segment each and map to tones")
    func passwordStrength() {
        let all = SwiftForgePasswordStrength.allCases
        #expect(all.map(\.level) == [1, 2, 3, 4])
        #expect(all.sorted() == all)
        #expect(all.map(\.tone) == [.danger, .warning, .success, .success])
    }

    // MARK: Flow layout

    @Test("The flow layout wraps a view that doesn't fit onto a new row")
    func flowWrapping() {
        let layout = SwiftForgeFlowLayout(spacing: 10)
        let sizes = [CGSize(width: 40, height: 20), CGSize(width: 40, height: 30), CGSize(width: 40, height: 20)]
        let rows = layout.arrange(sizes: sizes, maxWidth: 100)
        #expect(rows.map { $0.items.map(\.index) } == [[0, 1], [2]])
        #expect(rows[0].width == 90 && rows[0].height == 30)
    }

    @Test("A view wider than the container gets a row of its own")
    func flowOversized() {
        let rows = SwiftForgeFlowLayout(spacing: 8).arrange(
            sizes: [CGSize(width: 20, height: 10), CGSize(width: 300, height: 10), CGSize(width: 20, height: 10)],
            maxWidth: 100)
        #expect(rows.count == 3)
    }

    @Test("The flow layout reports the height of its rows and gaps")
    func flowSize() {
        let view = SwiftForgeFlowLayout(horizontalSpacing: 10, verticalSpacing: 6) {
            ForEach(0..<3, id: \.self) { _ in Color.red.frame(width: 40, height: 20) }
        }
        #expect(RenderedView(view, width: 100).size.height == 46)
    }

    // MARK: Slider geometry

    private let geometry = SwiftForgeSliderGeometry<Double>(bounds: 0...100, step: 5)

    @Test("Values map to fractions of the track, clamped to the bounds")
    func sliderFraction() {
        #expect(geometry.fraction(of: 25) == 0.25)
        #expect(geometry.fraction(of: -10) == 0)
        #expect(geometry.fraction(of: 250) == 1)
    }

    @Test("Positions map to values the thumb's center can reach, snapped to the step")
    func sliderPosition() {
        // A 224-pt track with a 24-pt thumb: the center travels from 12 to 212.
        #expect(geometry.value(at: 12, in: 224, thumb: 24) == 0)
        #expect(geometry.value(at: 212, in: 224, thumb: 24) == 100)
        #expect(geometry.value(at: 112, in: 224, thumb: 24) == 50)
        #expect(geometry.value(at: 117, in: 224, thumb: 24) == 55)
        #expect(geometry.value(at: -50, in: 224, thumb: 24) == 0)
    }

    @Test("Keyboard and VoiceOver steps move by the step, or a twentieth of the range without one")
    func sliderSteps() {
        #expect(geometry.stepped(50, by: 1) == 55)
        #expect(geometry.stepped(100, by: 1) == 100)
        let free = SwiftForgeSliderGeometry<Double>(bounds: 0...1, step: nil)
        #expect(abs(free.stepped(0.5, by: -1) - 0.45) < 0.000_1)
    }

    // MARK: Chips

    @Test("Chips keep a 44-pt hit area around a shorter outline")
    func chipHitArea() {
        let rendered = RenderedView(SwiftForgeChip("Thai", isSelected: .constant(false)))
        #expect(rendered.size.height >= 44)
    }

    @Test("A removable chip is as tall as a selectable one")
    func removableChipHeight() {
        let selectable = RenderedView(SwiftForgeChip("Ada", isSelected: .constant(false)))
        let removable = RenderedView(SwiftForgeChip("Ada", onRemove: {}))
        #expect(removable.size.height == selectable.size.height)
    }

    @Test("A selected chip fills with the tone's subtle color", arguments: [true, false])
    func chipFill(isSelected: Bool) {
        let rendered = RenderedView(
            SwiftForgeChip("Thai", isSelected: .constant(isSelected)).background(Color.white))
        let middle = Int(rendered.size.height) / 2
        // Just inside the outline, before the label.
        let x = Int(theme.borders.thin) + 2
        #expect(rendered.matches(x: x, y: middle, token: isSelected ? theme.colors.accent.subtle : theme.colors.surface))
    }

    @Test("Chips flow onto rows within the container")
    func chipGroupWraps() {
        let group = SwiftForgeChipGroup(
            "Cuisine", selection: .constant(Set<String>()), options: ["Italian", "Thai", "Turkish", "Mexican", "Japanese"]
        ) { Text(verbatim: $0) }
        let narrow = RenderedView(group, width: 160)
        let wide = RenderedView(group, width: 600)
        #expect(narrow.size.height > wide.size.height)
    }

    // MARK: Segmented control

    @Test("Small segmented controls are shorter than regular ones")
    func segmentedHeight() {
        func height(_ size: ControlSize) -> CGFloat {
            RenderedView(
                SwiftForgeSegmentedControl("P", selection: .constant("A"), options: ["A", "B"]) { Text(verbatim: $0) }
                    .controlSize(size),
                width: 200
            ).size.height
        }
        #expect(height(.small) == theme.sizes.controlHeightSmall)
        #expect(height(.regular) == theme.sizes.controlHeightRegular)
    }

    // The control hosts its segments in a ScrollView, which ImageRenderer
    // can't draw; the layout that places the indicator is tested directly,
    // and the control in the hosted snapshots.
    @Test("The segment layout places the indicator behind the selected segment", arguments: [0, 1, 2])
    func segmentedIndicator(selected: Int) {
        let view = SwiftForgeSegmentLayout(selectedIndex: selected, inset: 0) {
            Color(red: 1, green: 0, blue: 0)
            ForEach(0..<3, id: \.self) { _ in Color.clear.frame(height: 20) }
        }
        let rendered = RenderedView(view, width: 300)
        for segment in 0..<3 {
            let pixel = rendered.color(x: segment * 100 + 50, y: 10)
            #expect((pixel.red > 200) == (segment == selected), "segment \(segment)")
        }
    }

    @Test("Segments share the width equally")
    func segmentWidths() {
        let view = SwiftForgeSegmentLayout(selectedIndex: nil, inset: 0) {
            Color.clear
            Color(red: 1, green: 0, blue: 0).frame(height: 20)
            Color(red: 0, green: 0, blue: 1).frame(height: 20)
        }
        let rendered = RenderedView(view, width: 200)
        #expect(rendered.color(x: 98, y: 10).red > 200)
        #expect(rendered.color(x: 102, y: 10).blue > 200)
    }

    // MARK: Tokens

    @Test("Every built-in theme's control tokens stay within accessible sizes", arguments: SwiftForgeTheme.builtIn)
    func controlTokens(theme: SwiftForgeTheme) {
        let components = theme.components
        #expect(components.selectionControl.size >= 16)
        #expect(components.slider.thumbDiameter >= 16 && components.slider.trackHeight > 0)
        #expect(components.segmentedControl.indicatorInset >= 0)
        #expect((components.chip.height ?? theme.sizes.controlHeightSmall) <= theme.sizes.minimumHitTarget)
    }
}
