//
//  SwiftForgeToggleStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// A switch in the theme's colors and shapes, for any native `Toggle`.
///
/// ```swift
/// Toggle("Notifications", isOn: $notificationsOn)
///     .toggleStyle(.swiftForge)
/// ```
///
/// The whole row is tappable and at least 44 pt tall. The thumb's position,
/// not its color, tells the state: on, the track fills with the tone and the
/// thumb moves to the trailing edge; off, the track is outlined and the
/// thumb sits at the leading edge. With Differentiate Without Color on, the
/// track also shows on and off glyphs. VoiceOver, Voice Control, and Full
/// Keyboard Access see a standard switch.
///
/// Add secondary text under the label with
/// ``SwiftUICore/View/swiftForgeDescription(_:)-(Text?)``; VoiceOver reads it
/// as the hint:
///
/// ```swift
/// Toggle("Wi-Fi Assist", isOn: $assist)
///     .toggleStyle(.swiftForge)
///     .swiftForgeDescription("Use cellular data when Wi-Fi is poor.")
/// ```
///
/// The track's size, corners, and border come from ``SwiftForgeToggleTokens``.
public struct SwiftForgeToggleStyle: ToggleStyle {

    let tone: SwiftForgeTone

    /// Creates a switch style.
    ///
    /// - Parameter tone: The track's color when on. Defaults to the accent.
    public init(tone: SwiftForgeTone = .accent) {
        self.tone = tone
    }

    /// Creates a view that represents the body of a toggle.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeSwitch(configuration: configuration, tone: tone)
    }
}

private struct SwiftForgeSwitch: View {

    let configuration: ToggleStyleConfiguration
    let tone: SwiftForgeTone

    @Environment(\.swiftForgeControlDescription) private var description

    var body: some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            configuration.label
        }
        .buttonStyle(SwiftForgeToggleRowStyle(isOn: configuration.isOn, tone: tone))
        .accessibilityRepresentation {
            // The system switch's semantics: the switch trait and an on/off value.
            Toggle(isOn: configuration.$isOn) { configuration.label }
                .toggleStyle(.switch)
                .accessibilityHint(description ?? Text(verbatim: ""))
        }
        .swiftForgeHaptic(trigger: configuration.isOn) { _, _ in .selection }
    }
}

extension ToggleStyle where Self == SwiftForgeToggleStyle {

    /// A switch in the theme's accent color.
    public static var swiftForge: Self { SwiftForgeToggleStyle() }

    /// A switch in a tone's color.
    public static func swiftForge(tone: SwiftForgeTone) -> Self { SwiftForgeToggleStyle(tone: tone) }
}

/// Lays out the label and the switch, and reads the pressed state.
private struct SwiftForgeToggleRowStyle: ButtonStyle {

    let isOn: Bool
    let tone: SwiftForgeTone

    func makeBody(configuration: Configuration) -> some View {
        SwiftForgeToggleRow(label: configuration.label, isOn: isOn, isPressed: configuration.isPressed, tone: tone)
    }
}

private struct SwiftForgeToggleRow<Label: View>: View {

    let label: Label
    let isOn: Bool
    let isPressed: Bool
    let tone: SwiftForgeTone

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isFocused) private var isFocused
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        SwiftForgeLabelsVisibilityReader { labelsHidden in
            HStack(spacing: theme.spacing.sm) {
                // With `labelsHidden()`, only the switch shows; VoiceOver still
                // reads the label through the accessibility representation.
                if !labelsHidden {
                    SwiftForgeControlLabel(label: label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                track
            }
        }
        .frame(minHeight: theme.sizes.minimumHitTarget)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : theme.opacity.disabled)
    }

    private var tokens: SwiftForgeToggleTokens { theme.components.toggle }
    private var colors: SwiftForgeToneColors { theme.colors[tone] }
    private var thumbDiameter: CGFloat { tokens.trackHeight - 2 * tokens.thumbInset }

    private var track: some View {
        let trackShape = theme.radius.shape(tokens.cornerRadius)
        let thumbShape = theme.radius.shape(SwiftForgeRadius.concentric(outer: tokens.cornerRadius, inset: tokens.thumbInset))
        return ZStack(alignment: isOn ? .trailing : .leading) {
            trackShape.fill(isOn ? colors.solidPaint : .color(theme.colors.fillMuted))
            if accessibility.differentiateWithoutColor {
                glyph
            }
            thumbShape
                .fill(isOn ? colors.onSolid : theme.colors.neutral.solid)
                .overlay {
                    if isPressed {
                        thumbShape.fill(theme.colors.pressedOverlay)
                    }
                }
                .swiftForgeShadow(theme.elevation[tokens.thumbElevation])
                .frame(width: thumbDiameter, height: thumbDiameter)
                .padding(tokens.thumbInset)
        }
        .frame(width: tokens.trackWidth, height: tokens.trackHeight)
        .overlay {
            if let border {
                trackShape.strokeBorder(border.color, lineWidth: border.width)
            }
        }
        .swiftForgeFocusRing(isFocused, cornerRadius: tokens.cornerRadius)
        .animation(theme.motion.fast.animation(reduceMotion: accessibility.reduceMotion), value: isOn)
    }

    /// The off track is outlined so its edge contrasts 3:1 with the surface;
    /// a border width token outlines both states.
    private var border: (width: CGFloat, color: SwiftForgeColor)? {
        let color = tokens.borderColor ?? theme.colors.borderStrong
        if let width = tokens.borderWidth { return (width, color) }
        return isOn ? nil : (theme.borders.thin, color)
    }

    /// An "I" on the empty side of an on switch, an "O" on the empty side of
    /// an off one, as in the system's On/Off Labels setting.
    @ViewBuilder
    private var glyph: some View {
        let length = tokens.trackHeight / 3
        let center = tokens.thumbInset + thumbDiameter / 2
        let ringInset = center - length / 2
        if isOn {
            Rectangle()
                .fill(colors.onSolid)
                .frame(width: theme.borders.thick, height: length)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, center)
        } else {
            Circle()
                .strokeBorder(theme.colors.textSecondary, lineWidth: theme.borders.thick)
                .frame(width: length, height: length)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, ringInset)
        }
    }
}

// MARK: - Previews

private struct TogglePreview: View {
    @State private var notifications = true
    @State private var sounds = false

    var body: some View {
        VStack(spacing: 8) {
            Toggle("Notifications", isOn: $notifications)
            Toggle("Sounds", isOn: $sounds)
                .swiftForgeDescription("Play a sound for new messages.")
            Toggle("Danger zone", isOn: .constant(true)).toggleStyle(.swiftForge(tone: .danger))
            Toggle("Disabled", isOn: .constant(true)).disabled(true)
        }
        .toggleStyle(.swiftForge)
        .padding()
    }
}

#Preview("Toggle") { TogglePreview() }

#Preview("Dark, AX5, RTL") {
    TogglePreview()
        .environment(\.dynamicTypeSize, .accessibility5)
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("Mono, without color") {
    TogglePreview()
        .swiftForgeTheme(.mono)
        .swiftForgeAccessibilitySimulation(differentiateWithoutColor: true)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack {
            Toggle("On", isOn: .constant(true))
            Toggle("Off", isOn: .constant(false))
            Toggle("Disabled", isOn: .constant(true)).disabled(true)
        }
        .toggleStyle(.swiftForge)
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack {
            Toggle("On", isOn: .constant(true))
            Toggle("Off", isOn: .constant(false))
            Toggle("Disabled", isOn: .constant(true)).disabled(true)
        }
        .toggleStyle(.swiftForge)
    }
}
