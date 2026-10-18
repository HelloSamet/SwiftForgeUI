//
//  SwiftForgeBottomSheet.swift
//  SwiftForgeUI
//

import SwiftUI

/// Whether the content behind a bottom sheet stays usable.
///
/// New cases may be added in minor releases; when you switch over it,
/// include a `default` case.
public enum SwiftForgeSheetBackground: Sendable, Hashable {

    /// The content behind is dimmed and blocked, like a standard sheet.
    case dimmed

    /// The content behind stays usable while the sheet is at its smallest
    /// detent, like the sheet in Maps; it dims at larger detents.
    case interactive
}

private struct SwiftForgeBottomSheetStyle: ViewModifier {

    let detents: Set<PresentationDetent>
    let background: SwiftForgeSheetBackground

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content
            .presentationDetents(detents)
            .presentationDragIndicator(detents.count > 1 ? .visible : .automatic)
            .presentationCornerRadius(theme.radius.sheet)
            .presentationBackground(theme.components.surface.fills[.overlay] ?? .color(theme.colors.surfaceRaised))
            .presentationBackgroundInteraction(
                background == .interactive ? .enabled(upThrough: smallestDetent) : .disabled
            )
            // The presenter carries the theme in through the environment;
            // reapplying it would adjust it for Bold Text twice.
            .tint(theme.colors.accent.solid)
    }

    /// The detent the background stays usable up to: the first of the
    /// standard ones that's offered, or medium.
    private var smallestDetent: PresentationDetent {
        detents.contains(.medium) ? .medium : detents.first ?? .medium
    }
}

extension View {

    /// Presents a bottom sheet in the theme's style when a binding is `true`.
    ///
    /// ```swift
    /// .swiftForgeBottomSheet(isPresented: $showsFilters, detents: [.medium, .large]) {
    ///     FiltersView()
    /// }
    /// ```
    ///
    /// The sheet is SwiftUI's own, so dragging between detents, dismissing by
    /// swiping down, avoiding the keyboard, VoiceOver's escape gesture, and
    /// the iPad form sheet all work as people expect. SwiftForgeUI sets its
    /// corners (``SwiftForgeRadius/sheet``), background (the overlay
    /// surface: a material where the theme sets one, opaque with Reduce
    /// Transparency), drag indicator, and whether the content behind stays
    /// usable.
    ///
    /// - Parameters:
    ///   - isPresented: Whether the sheet is shown.
    ///   - detents: The heights the sheet rests at. Defaults to medium and large.
    ///   - background: Whether the content behind stays usable. Defaults to dimmed.
    ///   - onDismiss: Called after the sheet is dismissed.
    ///   - content: The sheet's content.
    public func swiftForgeBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        background: SwiftForgeSheetBackground = .dimmed,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(
            SwiftForgeBottomSheetPresenter(
                isPresented: isPresented, detents: detents, background: background, onDismiss: onDismiss, sheet: content))
    }

    /// Presents a bottom sheet in the theme's style for an item.
    ///
    /// - Parameters:
    ///   - item: The item to show, or `nil` to hide the sheet.
    ///   - detents: The heights the sheet rests at. Defaults to medium and large.
    ///   - background: Whether the content behind stays usable. Defaults to dimmed.
    ///   - onDismiss: Called after the sheet is dismissed.
    ///   - content: The sheet's content for the item.
    public func swiftForgeBottomSheet<Item: Identifiable, Content: View>(
        item: Binding<Item?>,
        detents: Set<PresentationDetent> = [.medium, .large],
        background: SwiftForgeSheetBackground = .dimmed,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping (Item) -> Content
    ) -> some View {
        modifier(
            SwiftForgeItemSheetPresenter(
                item: item, detents: detents, background: background, onDismiss: onDismiss, sheet: content))
    }
}

/// Reads the theme where the sheet is presented, to carry it into the sheet.
private struct SwiftForgeBottomSheetPresenter<Sheet: View>: ViewModifier {

    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let background: SwiftForgeSheetBackground
    let onDismiss: (() -> Void)?
    let sheet: () -> Sheet

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content.sheet(isPresented: $isPresented, onDismiss: onDismiss) {
            sheet()
                .modifier(SwiftForgeBottomSheetStyle(detents: detents, background: background))
                .environment(\.swiftForgeTheme, theme)
        }
    }
}

private struct SwiftForgeItemSheetPresenter<Item: Identifiable, Sheet: View>: ViewModifier {

    @Binding var item: Item?
    let detents: Set<PresentationDetent>
    let background: SwiftForgeSheetBackground
    let onDismiss: (() -> Void)?
    let sheet: (Item) -> Sheet

    @Environment(\.swiftForgeTheme) private var theme

    func body(content: Content) -> some View {
        content.sheet(item: $item, onDismiss: onDismiss) { item in
            sheet(item)
                .modifier(SwiftForgeBottomSheetStyle(detents: detents, background: background))
                .environment(\.swiftForgeTheme, theme)
        }
    }
}

// MARK: - Previews

private struct BottomSheetPreview: View {
    @State private var showsSheet = true

    var body: some View {
        Button("Filters") { showsSheet = true }
            .buttonStyle(.swiftForge())
            .swiftForgeBottomSheet(isPresented: $showsSheet, background: .interactive) {
                VStack(alignment: .leading, spacing: 16) {
                    SwiftForgeSectionHeader("Filters")
                    SwiftForgeChipGroup("Cuisine", selection: .constant(Set(["Thai"])), options: ["Thai", "Turkish"]) {
                        Text($0)
                    }
                }
                .padding()
            }
    }
}

#Preview("Bottom sheet") { BottomSheetPreview() }
