//
//  SwiftForgeTooltip.swift
//  SwiftForgeUI
//

import SwiftUI

extension View {

    /// Shows a short explanation next to this view while a binding is `true`.
    ///
    /// ```swift
    /// Button("About fees", systemImage: "info.circle") { showsFeeInfo.toggle() }
    ///     .buttonStyle(.swiftForgeIcon())
    ///     .swiftForgeTooltip("A 2% fee applies to card payments.", isPresented: $showsFeeInfo)
    /// ```
    ///
    /// SwiftUI's `help(_:)` only appears on hover, so it never shows on an
    /// iPhone. This tooltip is a popover that stays a popover in compact
    /// width — pointing at its source instead of becoming a sheet — in the
    /// theme's overlay surface and text colors. Tapping outside dismisses it,
    /// VoiceOver moves into it and leaves with the escape gesture, and the
    /// text also becomes the view's `help(_:)`, so hovering with a pointer on
    /// iPad or looking at it on visionOS shows it too. It never dismisses on
    /// a timer, so people read it at their own pace.
    ///
    /// Keep tooltips to a sentence or two of supplementary detail; anything
    /// people need to complete a task belongs on the screen.
    ///
    /// - Parameters:
    ///   - titleKey: The tooltip's text.
    ///   - isPresented: Whether the tooltip is shown.
    public func swiftForgeTooltip(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>) -> some View {
        swiftForgeTextTooltip(Text(titleKey), isPresented: isPresented)
    }

    /// Shows a short explanation next to this view while a binding is `true`.
    ///
    /// - Parameters:
    ///   - title: The tooltip's text, shown verbatim.
    ///   - isPresented: Whether the tooltip is shown.
    @_disfavoredOverload
    public func swiftForgeTooltip<S: StringProtocol>(_ title: S, isPresented: Binding<Bool>) -> some View {
        swiftForgeTextTooltip(Text(title), isPresented: isPresented)
    }

    /// Shows custom content in a tooltip next to this view while a binding is
    /// `true`.
    ///
    /// Content is set in the theme's ``SwiftForgeTypography/subheadline``
    /// role and primary text color unless it sets its own.
    ///
    /// ```swift
    /// .swiftForgeTooltip(isPresented: $showsShortcut) {
    ///     Label("Press ⌘K to search", systemImage: "keyboard")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isPresented: Whether the tooltip is shown.
    ///   - content: The tooltip's content.
    public func swiftForgeTooltip<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SwiftForgeTooltipPresenter(isPresented: isPresented, tooltip: content))
    }

    private func swiftForgeTextTooltip(_ text: Text, isPresented: Binding<Bool>) -> some View {
        help(text).swiftForgeTooltip(isPresented: isPresented) { text }
    }
}

/// Reads the theme where the tooltip is attached, to carry it into the popover.
private struct SwiftForgeTooltipPresenter<Tooltip: View>: ViewModifier {

    @Binding var isPresented: Bool
    let tooltip: () -> Tooltip

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content.popover(isPresented: $isPresented) {
            tooltip()
                .swiftForgeTextStyle(\.subheadline, color: \.textPrimary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: theme.components.tooltip.maxWidth, alignment: .leading)
                .padding(.horizontal, theme.spacing.md)
                .padding(.vertical, theme.spacing.sm)
                .presentationCompactAdaptation(.popover)
                .presentationBackground(theme.components.surface.fills[.overlay] ?? .color(theme.colors.surfaceRaised))
                // The presenter carries the theme in through the environment;
                // reapplying it would adjust it for Bold Text twice.
                .tint(theme.colors.accent.solid)
                .environment(\.swiftForgeTheme, theme)
        }
    }
}

// MARK: - Previews

private struct TooltipPreview: View {
    @State private var showsFees = true
    @State private var showsShortcut = false

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Total: $42.00")
                Button("About fees", systemImage: "info.circle") { showsFees.toggle() }
                    .buttonStyle(.swiftForgeIcon())
                    .swiftForgeTooltip("A 2% fee applies to card payments.", isPresented: $showsFees)
            }
            Button("Shortcut") { showsShortcut.toggle() }
                .buttonStyle(.swiftForge(.tinted))
                .swiftForgeTooltip(isPresented: $showsShortcut) {
                    Label("Press ⌘K to search", systemImage: "keyboard")
                }
        }
    }
}

#Preview("Tooltip") { TooltipPreview() }

#Preview("Tooltip — Sunset dark") {
    TooltipPreview().swiftForgeTheme(.sunset).preferredColorScheme(.dark)
}
