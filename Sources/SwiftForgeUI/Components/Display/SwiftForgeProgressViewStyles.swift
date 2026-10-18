//
//  SwiftForgeProgressViewStyles.swift
//  SwiftForgeUI
//

import SwiftUI

/// A determinate progress bar in the theme's colors.
///
/// ```swift
/// ProgressView(value: upload.fraction) {
///     Text("Uploading")
/// } currentValueLabel: {
///     Text(upload.fraction, format: .percent)
/// }
/// .progressViewStyle(.swiftForgeLinear)
/// ```
///
/// The bar is drawn in the tone's ``SwiftForgeToneColors/text`` color, which
/// contrasts 4.5:1 with surfaces and 3:1 with the muted track, because the
/// amount it shows is information (WCAG 1.4.11). Its thickness and corners
/// come from ``SwiftForgeProgressTokens``. Without a value,
/// the style shows the native indeterminate spinner — SwiftForgeUI never
/// redraws the system spinner, which already handles VoiceOver and Reduce
/// Motion.
public struct SwiftForgeLinearProgressViewStyle: ProgressViewStyle {

    let tone: SwiftForgeTone

    /// Creates a linear style.
    ///
    /// - Parameter tone: The bar's color family. Defaults to the accent.
    public init(tone: SwiftForgeTone = .accent) {
        self.tone = tone
    }

    /// Creates a view that represents the body of a styled control.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeProgressBody(configuration: configuration, tone: tone, isCircular: false)
    }
}

/// A determinate progress ring in the theme's colors.
///
/// ```swift
/// ProgressView(value: 0.4).progressViewStyle(.swiftForgeCircular)
/// ```
///
/// The ring is 24, 32, or 48 pt across for small, regular, and large control
/// sizes; at large size it shows its current value label in the center.
/// Without a value, the style shows the native indeterminate spinner.
public struct SwiftForgeCircularProgressViewStyle: ProgressViewStyle {

    let tone: SwiftForgeTone

    /// Creates a circular style.
    ///
    /// - Parameter tone: The ring's color family. Defaults to the accent.
    public init(tone: SwiftForgeTone = .accent) {
        self.tone = tone
    }

    /// Creates a view that represents the body of a styled control.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeProgressBody(configuration: configuration, tone: tone, isCircular: true)
    }
}

extension ProgressViewStyle where Self == SwiftForgeLinearProgressViewStyle {

    /// A determinate progress bar in the theme's accent color.
    public static var swiftForgeLinear: Self { SwiftForgeLinearProgressViewStyle() }

    /// A determinate progress bar in a tone's color.
    public static func swiftForgeLinear(tone: SwiftForgeTone) -> Self { SwiftForgeLinearProgressViewStyle(tone: tone) }
}

extension ProgressViewStyle where Self == SwiftForgeCircularProgressViewStyle {

    /// A determinate progress ring in the theme's accent color.
    public static var swiftForgeCircular: Self { SwiftForgeCircularProgressViewStyle() }

    /// A determinate progress ring in a tone's color.
    public static func swiftForgeCircular(tone: SwiftForgeTone) -> Self { SwiftForgeCircularProgressViewStyle(tone: tone) }
}

private struct SwiftForgeProgressBody: View {

    let configuration: ProgressViewStyleConfiguration
    let tone: SwiftForgeTone
    let isCircular: Bool

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.controlSize) private var controlSize
    @Environment(\.colorScheme) private var colorScheme
    @SwiftForgeAccessibilityContext private var accessibility
    /// Grows the ring with Dynamic Type so its value label always fits.
    @ScaledMetric(relativeTo: .caption) private var ringScale: CGFloat = 1

    var body: some View {
        if let fraction = configuration.fractionCompleted {
            let clamped = min(max(fraction, 0), 1)
            Group {
                if isCircular {
                    ring(clamped)
                } else {
                    bar(clamped)
                }
            }
            .animation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion), value: clamped)
            .accessibilityElement(children: .combine)
            .accessibilityValue(
                configuration.currentValueLabel == nil
                    ? Text(clamped, format: .percent.precision(.fractionLength(0)))
                    : Text(verbatim: "")
            )
            .accessibilityAddTraits(.updatesFrequently)
        } else {
            ProgressView(configuration)
                .progressViewStyle(.circular)
                .tint(
                    Color(
                        theme.colors[tone].text.resolve(
                            colorScheme: colorScheme, increasedContrast: accessibility.increasedContrast)))
        }
    }

    private var size: SwiftForgeControlSize { SwiftForgeControlSize(controlSize) }

    private var tokens: SwiftForgeProgressTokens { theme.components.progress }

    private var barShape: SwiftForgeShape { theme.radius.shape(tokens.barCornerRadius) }

    private func bar(_ fraction: Double) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            if configuration.label != nil || configuration.currentValueLabel != nil {
                HStack(alignment: .firstTextBaseline) {
                    configuration.label
                        .foregroundStyle(theme.colors.textPrimary)
                    Spacer(minLength: theme.spacing.xs)
                    configuration.currentValueLabel
                        .monospacedDigit()
                        .foregroundStyle(theme.colors.textSecondary)
                }
                .font(theme.typography.font(theme.typography.footnote))
            }
            FractionFillLayout(fraction: fraction) {
                barShape.fill(theme.colors[tone].text)
            }
            .frame(height: size == .large ? tokens.barHeightLarge : tokens.barHeight)
            .background(theme.colors.fillMuted, in: barShape)
            .overlay {
                if accessibility.increasedContrast {
                    barShape.strokeBorder(theme.colors.borderStrong, lineWidth: theme.borders.thin)
                }
            }
        }
    }

    private func ring(_ fraction: Double) -> some View {
        let diameter = tokens.ringDiameters[size] * max(ringScale, 1)
        let lineWidth = size == .large ? tokens.ringLineWidthLarge : tokens.ringLineWidth
        return ZStack {
            Circle()
                .stroke(theme.colors.fillMuted, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(theme.colors[tone].text, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if size == .large {
                configuration.currentValueLabel
                    .font(theme.typography.font(theme.typography.caption1))
                    .monospacedDigit()
                    .foregroundStyle(theme.colors.textPrimary)
            }
        }
        .padding(lineWidth / 2)  // swiftforge-lint: allow (keeps the stroke inside the frame)
        .frame(width: diameter, height: diameter)
    }
}

/// Sizes its single subview to a fraction of the proposed width. Mirrors
/// automatically in right-to-left layouts, and animates the fraction.
private struct FractionFillLayout: Layout {

    var fraction: Double

    var animatableData: Double {
        get { fraction }
        set { fraction = newValue }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        subviews.first?.place(
            at: bounds.origin,
            anchor: .topLeading,
            proposal: ProposedViewSize(width: bounds.width * fraction, height: bounds.height)
        )
    }
}

#Preview("Progress") {
    VStack(spacing: 24) {
        ProgressView(value: 0.4) {
            Text("Uploading")
        } currentValueLabel: {
            Text("40%")
        }
        .progressViewStyle(.swiftForgeLinear)

        ProgressView(value: 0.75).progressViewStyle(.swiftForgeLinear(tone: .success)).controlSize(.large)

        HStack(spacing: 24) {
            ProgressView(value: 0.3).progressViewStyle(.swiftForgeCircular).controlSize(.small)
            ProgressView(value: 0.6).progressViewStyle(.swiftForgeCircular)
            ProgressView(value: 0.9) {
                EmptyView()
            } currentValueLabel: {
                Text("90%")
            }
            .progressViewStyle(.swiftForgeCircular)
            .controlSize(.large)
            ProgressView().progressViewStyle(.swiftForgeCircular)
        }
    }
    .padding()
}

#Preview("RTL, dark") {
    ProgressView(value: 0.3).progressViewStyle(.swiftForgeLinear)
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        VStack(spacing: 12) {
            ProgressView(value: 0.4) {
                Text("Uploading")
            } currentValueLabel: {
                Text("40%")
            }
            .progressViewStyle(.swiftForgeLinear)
            HStack(spacing: 16) {
                ProgressView(value: 0.6).progressViewStyle(.swiftForgeCircular)
                ProgressView(value: 0.9) {
                    EmptyView()
                } currentValueLabel: {
                    Text("90%")
                }
                .progressViewStyle(.swiftForgeCircular).controlSize(.large)
            }
        }
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        VStack(spacing: 12) {
            ProgressView(value: 0.4) {
                Text("Uploading")
            } currentValueLabel: {
                Text("40%")
            }
            .progressViewStyle(.swiftForgeLinear)
            HStack(spacing: 16) {
                ProgressView(value: 0.6).progressViewStyle(.swiftForgeCircular)
                ProgressView(value: 0.9) {
                    EmptyView()
                } currentValueLabel: {
                    Text("90%")
                }
                .progressViewStyle(.swiftForgeCircular).controlSize(.large)
            }
        }
    }
}
