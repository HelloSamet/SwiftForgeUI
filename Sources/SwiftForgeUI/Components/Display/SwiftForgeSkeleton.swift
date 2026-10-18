//
//  SwiftForgeSkeleton.swift
//  SwiftForgeUI
//

import SwiftUI

extension EnvironmentValues {
    /// Freezes the shimmer at a phase from 0 to 1, for deterministic snapshots.
    @Entry var swiftForgeShimmerPhase: Double? = nil
}

/// Sweeps a soft band across the view by modulating its opacity.
///
/// Masking the content itself — rather than drawing a highlight over it —
/// keeps the band inside the content's exact shape, needs no second render,
/// and reads correctly in every theme: the content fades toward whatever is
/// behind it. One `TimelineView` drives the phase from the clock, so every
/// placeholder on screen sweeps in sync and restarts correctly after lazy
/// containers recycle it.
struct SwiftForgeShimmer: ViewModifier {

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.swiftForgeShimmerPhase) private var frozenPhase
    @SwiftForgeAccessibilityContext private var accessibility

    func body(content: Content) -> some View {
        if accessibility.reduceMotion {
            content
        } else {
            content.mask {
                TimelineView(.animation(paused: frozenPhase != nil)) { context in
                    band(phase: frozenPhase ?? phase(at: context.date))
                }
            }
        }
    }

    private func phase(at date: Date) -> Double {
        let duration = theme.motion.shimmerDuration
        return date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: duration) / duration
    }

    private func band(phase: Double) -> LinearGradient {
        // The band is 60% of the width wide and travels from fully before
        // the leading edge to fully past the trailing edge.
        let width = theme.motion.shimmerBandWidth
        let start = -width + (1 + width) * phase
        var from = start
        var to = start + width
        if layoutDirection == .rightToLeft {
            from = 1 - from
            to = 1 - to
        }
        let pulse = Color.black.opacity(theme.opacity.skeletonPulse)  // swiftforge-lint: allow (mask alpha, not a color)
        return LinearGradient(
            stops: [
                .init(color: .black, location: 0),
                .init(color: pulse, location: 0.5),
                .init(color: .black, location: 1),
            ],
            startPoint: UnitPoint(x: from, y: 0.5),
            endPoint: UnitPoint(x: to, y: 0.5)
        )
    }
}

private struct SwiftForgeSkeletonModifier: ViewModifier {

    let isActive: Bool
    let label: Text?

    func body(content: Content) -> some View {
        if isActive {
            content
                .redacted(reason: .placeholder)
                .modifier(SwiftForgeShimmer())
                .disabled(true)
                // The placeholder text isn't content: hide it entirely (an
                // ignored child is still inspected by accessibility tools),
                // and say "Loading" from an element of the same frame.
                .accessibilityHidden(true)
                .overlay {
                    Color.clear
                        .accessibilityElement()
                        .accessibilityLabel(label ?? SwiftForgeStrings.loading)
                        .accessibilityAddTraits([.isStaticText, .updatesFrequently])
                }
        } else {
            content
        }
    }
}

extension View {

    /// Shows this view as a shimmering placeholder while its content loads.
    ///
    /// Render the real layout with placeholder data, so the placeholder has
    /// exactly the shape of the content that replaces it:
    ///
    /// ```swift
    /// ArticleRow(article: isLoading ? .placeholder : article)
    ///     .swiftForgeSkeleton(isActive: isLoading)
    /// ```
    ///
    /// While active, the view is redacted with SwiftUI's `.placeholder`
    /// reason (so `unredacted()` works inside it), disabled, and read by
    /// VoiceOver as a single "Loading" element. With Reduce Motion on, the
    /// placeholder doesn't shimmer.
    ///
    /// - Parameters:
    ///   - isActive: Whether to show the placeholder.
    ///   - label: What VoiceOver reads while active. Defaults to "Loading".
    public func swiftForgeSkeleton(isActive: Bool, label: Text? = nil) -> some View {
        modifier(SwiftForgeSkeletonModifier(isActive: isActive, label: label))
    }
}

/// A shimmering placeholder shape for content that has no layout of its own
/// yet, such as an image.
///
/// ```swift
/// SwiftForgeSkeletonShape(.circle).frame(width: 40, height: 40)
/// SwiftForgeSkeletonShape().frame(height: 120)
/// ```
///
/// Each shape is hidden from VoiceOver. Group placeholders and label the
/// group, or prefer ``SwiftUICore/View/swiftForgeSkeleton(isActive:label:)``,
/// which does this for you.
public struct SwiftForgeSkeletonShape: View {

    /// The placeholder's shape.
    ///
    /// New cases may be added in minor releases; when you switch over it,
    /// include a `default` case.
    public enum Shape: Sendable, Hashable {
        /// A rectangle with the theme's small radius.
        case rectangle
        /// A circle.
        case circle
        /// A capsule.
        case capsule
    }

    private let shape: Shape

    @Environment(\.swiftForgeTheme) private var theme

    /// Creates a placeholder shape.
    ///
    /// - Parameter shape: The shape. Defaults to ``Shape/rectangle``.
    public init(_ shape: Shape = .rectangle) {
        self.shape = shape
    }

    /// The content and behavior of the view.
    public var body: some View {
        Group {
            switch shape {
            case .rectangle:
                theme.radius.shape(theme.radius.sm).fill(theme.colors.fillMuted)
            case .circle:
                Circle().fill(theme.colors.fillMuted)
            case .capsule:
                theme.radius.shape(SwiftForgeRadius.capsule).fill(theme.colors.fillMuted)
            }
        }
        .modifier(SwiftForgeShimmer())
        .accessibilityHidden(true)
    }
}

private struct SkeletonPreviewRow: View {
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.sm) {
            Image(systemName: "person.crop.circle.fill").font(.largeTitle)
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text("Jane Appleseed").swiftForgeTextStyle(\.headline)
                Text("Shared three photos with you").swiftForgeTextStyle(\.subheadline)
            }
        }
    }
}

#Preview("Redacted content") {
    VStack(alignment: .leading, spacing: 24) {
        SkeletonPreviewRow().swiftForgeSkeleton(isActive: true)
        SkeletonPreviewRow().swiftForgeSkeleton(isActive: false)
        HStack {
            SwiftForgeSkeletonShape(.circle).frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                SwiftForgeSkeletonShape().frame(width: 180, height: 14)
                SwiftForgeSkeletonShape().frame(width: 120, height: 14)
            }
        }
    }
    .padding()
}

#Preview("Dark, RTL") {
    SkeletonPreviewRow()
        .swiftForgeSkeleton(isActive: true)
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SkeletonPreviewRow().swiftForgeSkeleton(isActive: true)
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        SkeletonPreviewRow().swiftForgeSkeleton(isActive: true)
    }
}
