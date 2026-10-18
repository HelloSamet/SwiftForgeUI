//
//  SwiftForgeDisclosureGroupStyle.swift
//  SwiftForgeUI
//

import SwiftUI

/// An accordion style for SwiftUI's `DisclosureGroup`: a full-width header
/// row with a chevron that turns as the content expands and collapses.
///
/// ```swift
/// VStack(spacing: 0) {
///     DisclosureGroup("Shipping") { ShippingDetails() }
///     SwiftForgeDivider()
///     DisclosureGroup("Returns", isExpanded: $showsReturns) { ReturnsPolicy() }
/// }
/// .disclosureGroupStyle(.swiftForge)
/// ```
///
/// The whole header is the button, at least 44 pt tall, with its vertical
/// padding following ``SwiftForgeDensity``. The content slides in with the
/// theme's motion, and fades with Reduce Motion on. VoiceOver reads the
/// header as a button with "Expanded" or "Collapsed" as its value.
///
/// To let only one section open at a time, bind each group's `isExpanded`
/// to a shared selection.
public struct SwiftForgeDisclosureGroupStyle: DisclosureGroupStyle {

    /// Creates the accordion style.
    public init() {}

    /// Creates a view that represents the body of a disclosure group.
    public func makeBody(configuration: Configuration) -> some View {
        SwiftForgeDisclosureGroup(configuration: configuration)
    }
}

extension DisclosureGroupStyle where Self == SwiftForgeDisclosureGroupStyle {

    /// The SwiftForgeUI accordion style.
    public static var swiftForge: Self { SwiftForgeDisclosureGroupStyle() }
}

private struct SwiftForgeDisclosureGroup: View {

    let configuration: DisclosureGroupStyleConfiguration

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeDensity) private var density
    @SwiftForgeAccessibilityContext private var accessibility

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion)) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                HStack(spacing: theme.spacing.sm) {
                    configuration.label
                        .font(theme.typography.font(theme.typography.headline))
                        .foregroundStyle(theme.colors.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.forward")
                        .font(theme.typography.font(theme.typography.footnote).weight(.semibold))
                        .foregroundStyle(theme.colors.textSecondary)
                        // Points down when expanded. In right-to-left languages SwiftUI
                        // mirrors the rotation along with the symbol (snapshot-verified).
                        .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
                        .accessibilityHidden(true)
                }
                .padding(.vertical, density.rowPadding(in: theme.spacing))
                .frame(minHeight: theme.sizes.minimumHitTarget)
                .contentShape(Rectangle())
            }
            .buttonStyle(SwiftForgeDisclosureHeaderStyle())
            .accessibilityValue(configuration.isExpanded ? SwiftForgeStrings.expanded : SwiftForgeStrings.collapsed)

            if configuration.isExpanded {
                configuration.content
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, density.rowPadding(in: theme.spacing))
                    .transition(
                        accessibility.reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
            }
        }
        .clipped()
    }
}

/// The header's pressed and focused appearance.
private struct SwiftForgeDisclosureHeaderStyle: ButtonStyle {

    func makeBody(configuration: Configuration) -> some View {
        SwiftForgeDisclosureHeader(configuration: configuration)
    }
}

private struct SwiftForgeDisclosureHeader: View {

    let configuration: ButtonStyleConfiguration

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.isFocused) private var isFocused
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        configuration.label
            .opacity(configuration.isPressed ? theme.opacity.pressedContent : 1)
            .opacity(isEnabled ? 1 : theme.opacity.disabled)
            .swiftForgeFocusRing(isFocused, cornerRadius: theme.radius.controlSmall)
    }
}

// MARK: - Previews

private struct AccordionPreview: View {
    @State private var expanded: String? = "Shipping"

    var body: some View {
        VStack(spacing: 0) {
            ForEach(["Shipping", "Returns", "Warranty"], id: \.self) { section in
                DisclosureGroup(
                    section,
                    isExpanded: Binding(get: { expanded == section }, set: { expanded = $0 ? section : nil })
                ) {
                    Text("Orders ship within two business days. Tracking arrives by email.")
                        .foregroundStyle(.secondary)
                }
                SwiftForgeDivider()
            }
        }
        .disclosureGroupStyle(.swiftForge)
        .padding()
    }
}

#Preview("Accordion") { AccordionPreview() }

#Preview("AX3, RTL") {
    AccordionPreview()
        .environment(\.dynamicTypeSize, .accessibility3)
        .environment(\.layoutDirection, .rightToLeft)
}
