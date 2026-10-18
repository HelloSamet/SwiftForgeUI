//
//  SwiftForgeEmptyState.swift
//  SwiftForgeUI
//

import SwiftUI

/// A placeholder for a screen or section with nothing to show yet: a
/// symbol or illustration, a title, a description, and actions.
///
/// ```swift
/// SwiftForgeEmptyState("No Messages", systemImage: "tray", description: Text("Messages you receive appear here.")) {
///     Button("Compose") { compose() }
/// }
/// ```
///
/// Use your own illustration in place of a symbol:
///
/// ```swift
/// SwiftForgeEmptyState("Nothing Planned", description: Text("Add a trip to see it here.")) {
///     Image("empty-trips").resizable().scaledToFit().frame(maxWidth: 200)
/// } actions: {
///     Button("Add Trip") { addTrip() }
///     Button("Browse Ideas") { browse() }
///         .buttonStyle(.swiftForge(.plain))
/// }
/// ```
///
/// Actions stack vertically and use the filled button style; give secondary
/// actions their own style, as above. Text is centered and kept
/// to a readable width (``SwiftForgeEmptyStateTokens/maxContentWidth``).
///
/// VoiceOver reads the title as a heading followed by the description; the
/// symbol is decorative. Like SwiftUI's `ContentUnavailableView`, which
/// it complements, it fills the space it's given and centers its content.
///
/// - Do: say what's missing and how to add it — "No Messages", "Compose".
/// - Don't: use an empty state for errors that need attention; use a
///   ``SwiftForgeBanner``.
public struct SwiftForgeEmptyState<Illustration: View, Actions: View>: View {

    private var title: Text
    private let description: Text?
    private let image: Illustration
    private let actions: Actions

    @Environment(\.swiftForgeTheme) private var theme

    /// Creates an empty state with a custom image and actions.
    ///
    /// - Parameters:
    ///   - titleKey: What's missing, such as "No Messages".
    ///   - description: What will appear here, or how to add it.
    ///   - image: A symbol or illustration above the title.
    ///   - actions: Buttons that resolve the empty state.
    public init(
        _ titleKey: LocalizedStringKey,
        description: Text? = nil,
        @ViewBuilder image: () -> Illustration,
        @ViewBuilder actions: () -> Actions
    ) {
        self.title = Text(titleKey)
        self.description = description
        self.image = image()
        self.actions = actions()
    }

    /// The content and behavior of the view.
    public var body: some View {
        VStack(spacing: theme.spacing.md) {
            image
                .foregroundStyle(theme.colors.textSecondary)
                .accessibilityHidden(true)
            VStack(spacing: theme.spacing.xs) {
                title
                    .font(theme.typography.font(theme.typography.title3))
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if let description {
                    description
                        .font(theme.typography.font(theme.typography.body))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .multilineTextAlignment(.center)
            VStack(spacing: theme.spacing.xs) {
                actions
            }
            .buttonStyle(.swiftForge(.filled))
            .padding(.top, theme.spacing.xs)
        }
        .frame(maxWidth: theme.components.emptyState.maxContentWidth)
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension SwiftForgeEmptyState where Illustration == SwiftForgeEmptyStateSymbol {

    /// Creates an empty state with an SF Symbol and actions.
    ///
    /// - Parameters:
    ///   - titleKey: What's missing, such as "No Messages".
    ///   - systemImage: A symbol above the title.
    ///   - description: What will appear here, or how to add it.
    ///   - actions: Buttons that resolve the empty state.
    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        description: Text? = nil,
        @ViewBuilder actions: () -> Actions
    ) {
        self.init(
            titleKey, description: description, image: { SwiftForgeEmptyStateSymbol(systemName: systemImage) }, actions: actions)
    }
}

extension SwiftForgeEmptyState where Illustration == SwiftForgeEmptyStateSymbol, Actions == EmptyView {

    /// Creates an empty state with an SF Symbol and no actions.
    public init(_ titleKey: LocalizedStringKey, systemImage: String, description: Text? = nil) {
        self.init(titleKey, systemImage: systemImage, description: description) { EmptyView() }
    }
}

/// An empty state's symbol, sized by ``SwiftForgeEmptyStateTokens/iconSize``
/// and scaled with Dynamic Type.
public struct SwiftForgeEmptyStateSymbol: View {

    let systemName: String

    @Environment(\.swiftForgeTheme) private var theme
    @ScaledMetric(relativeTo: .largeTitle) private var scale: CGFloat = 1

    /// The content and behavior of the view.
    public var body: some View {
        Image(systemName: systemName)
            .font(.system(size: theme.components.emptyState.iconSize * scale))
            .symbolRenderingMode(.hierarchical)
    }
}

// MARK: - Previews

#Preview("Empty state") {
    SwiftForgeEmptyState("No Messages", systemImage: "tray", description: Text("Messages you receive appear here.")) {
        Button("Compose") {}
    }
}

#Preview("Dark, AX3") {
    SwiftForgeEmptyState("No Results", systemImage: "magnifyingglass", description: Text("Try a different search."))
        .environment(\.dynamicTypeSize, .accessibility3)
        .preferredColorScheme(.dark)
}

#Preview("All themes") {
    SwiftForgeThemeMatrix {
        SwiftForgeEmptyState("No Messages", systemImage: "tray", description: Text("Messages appear here.")) {
            Button("Compose") {}
        }
    }
}
