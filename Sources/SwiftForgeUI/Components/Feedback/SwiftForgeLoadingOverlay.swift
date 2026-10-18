//
//  SwiftForgeLoadingOverlay.swift
//  SwiftForgeUI
//

import SwiftUI

private struct SwiftForgeLoadingOverlayModifier: ViewModifier {

    /// Work that finishes sooner than this never shows the overlay, which
    /// avoids a distracting flash.
    private static let showDelay: Duration = .milliseconds(150)  // swiftforge-lint: allow (behavior timing, not a visual token)
    /// Once shown, the overlay stays at least this long so it never flickers.
    private static let minimumVisibleDuration: TimeInterval = 0.4  // swiftforge-lint: allow (behavior timing, not a visual token)

    let isPresented: Bool
    let message: SwiftForgeText?

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @SwiftForgeAccessibilityContext private var accessibility
    @State private var isVisible = false
    @State private var shownAt: Date?
    @AccessibilityFocusState private var isOverlayFocused: Bool

    func body(content: Content) -> some View {
        content
            .allowsHitTesting(!isPresented)
            .accessibilityHidden(isPresented)
            .overlay {
                ZStack {
                    if isVisible {
                        overlay
                            .transition(.opacity)
                    }
                }
                .animation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion), value: isVisible)
            }
            .task(id: isPresented) {
                await update()
            }
    }

    private var overlay: some View {
        let scrimOpacity = accessibility.reduceTransparency ? theme.opacity.scrimReducedTransparency : theme.opacity.scrim
        return ZStack {
            Rectangle()
                .fill((theme.components.loadingOverlay.scrim ?? theme.colors.canvas).withOpacity(scrimOpacity))
                .ignoresSafeArea()

            if let message {
                VStack(spacing: theme.spacing.sm) {
                    spinner
                    message.text
                        .font(theme.typography.font(theme.typography.callout))
                        .foregroundStyle(theme.colors.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .padding(theme.spacing.lg)
                .swiftForgeSurface(.overlay)
                .padding(theme.spacing.xl)
            } else {
                spinner
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityAddTraits([.isStaticText, .updatesFrequently])
        .accessibilityFocused($isOverlayFocused)
    }

    private var spinner: some View {
        ProgressView()
            .controlSize(.large)
            .tint(
                Color(
                    theme.colors.accent.solid.resolve(
                        colorScheme: colorScheme, increasedContrast: accessibility.increasedContrast)))
    }

    private var accessibilityLabel: Text {
        guard let message else { return SwiftForgeStrings.loading }
        return SwiftForgeStrings.loading + Text(verbatim: ", ") + message.text
    }

    private func update() async {
        if isPresented {
            guard !isVisible else { return }
            try? await Task.sleep(for: Self.showDelay)
            guard !Task.isCancelled else { return }
            isVisible = true
            shownAt = .now
            let announcement = [SwiftForgeStrings.loadingString, message?.string].compactMap { $0 }.joined(separator: ", ")
            AccessibilityNotification.Announcement(announcement).post()
            isOverlayFocused = true
        } else if isVisible {
            let elapsed = Date.now.timeIntervalSince(shownAt ?? .distantPast)
            if elapsed < Self.minimumVisibleDuration {
                try? await Task.sleep(for: .seconds(Self.minimumVisibleDuration - elapsed))
            }
            guard !Task.isCancelled else { return }
            isVisible = false
            AccessibilityNotification.Announcement(SwiftForgeStrings.loadingCompleteString).post()
        }
    }
}

extension View {

    /// Covers this view with a loading indicator and blocks interaction with
    /// it while `isPresented` is `true`.
    ///
    /// ```swift
    /// CheckoutForm()
    ///     .swiftForgeLoadingOverlay(isPresented: isSubmitting, message: "Placing your order…")
    /// ```
    ///
    /// Use it when the whole section is unusable until work finishes; for a
    /// single action, prefer the button's own loading state.
    ///
    /// Interaction is blocked as soon as `isPresented` becomes `true`, but the
    /// overlay only appears if the work takes longer than 150 ms, and then
    /// stays for at least 400 ms, so it never flashes. While shown, the
    /// covered content is hidden from VoiceOver, the overlay takes VoiceOver
    /// focus and is announced, and its scrim becomes nearly opaque with
    /// Reduce Transparency on.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the work is in progress.
    ///   - message: Text shown below the indicator.
    public func swiftForgeLoadingOverlay(isPresented: Bool, message: LocalizedStringResource? = nil) -> some View {
        modifier(SwiftForgeLoadingOverlayModifier(isPresented: isPresented, message: message.map(SwiftForgeText.init)))
    }
}

private struct LoadingOverlayPreview: View {
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 16) {
            SwiftForgeCard(style: .elevated) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment details").swiftForgeTextStyle(\.headline)
                    Text("Your card will be charged $12.00.").swiftForgeTextStyle(\.subheadline)
                }
            }
            Button(isLoading ? "Stop" : "Start") { isLoading.toggle() }
                .buttonStyle(.swiftForge(.outlined))
        }
        .padding()
        .swiftForgeLoadingOverlay(isPresented: isLoading, message: "Processing payment…")
    }
}

#Preview("Loading overlay") { LoadingOverlayPreview() }

#Preview("Dark, reduced transparency") {
    LoadingOverlayPreview()
        .swiftForgeAccessibilitySimulation(reduceTransparency: true)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeCard { Text("Payment details").frame(maxWidth: .infinity, minHeight: 80) }
            .swiftForgeLoadingOverlay(isPresented: true, message: "Processing…")
    }
}

#Preview("All themes, AX3") {
    SwiftForgeThemeMatrix(dynamicTypeSize: .accessibility3) {
        SwiftForgeCard { Text("Payment details").frame(maxWidth: .infinity, minHeight: 80) }
            .swiftForgeLoadingOverlay(isPresented: true, message: "Processing…")
    }
}
