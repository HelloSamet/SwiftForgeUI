//
//  SwiftForgeNavigationHeader.swift
//  SwiftForgeUI
//

import SwiftUI

/// A large title at the top of a scrolling screen, with an optional
/// subtitle and trailing accessory, that hands the title to the navigation
/// bar once it scrolls away.
///
/// ```swift
/// NavigationStack {
///     ScrollView {
///         SwiftForgeNavigationHeader("Inbox", subtitle: Text("12 unread")) {
///             SwiftForgeAvatar(name: user.name).controlSize(.small)
///         }
///         MessageList()
///     }
/// }
/// ```
///
/// Put the header first inside a `ScrollView` or `List` in a
/// `NavigationStack`. It sets the screen's navigation title — used by the
/// back button and the app switcher — and shows it inline in the
/// navigation bar only while the large title is scrolled out of view, like
/// the system's large titles but in the theme's typography. Toolbar items,
/// the back button, and search stay the navigation bar's own.
///
/// The title is a VoiceOver heading. The inline copy exists only while the
/// large title is scrolled away, so the title is read once. The handoff fades
/// with the theme's motion, and without movement when Reduce Motion is on.
public struct SwiftForgeNavigationHeader<Accessory: View>: View {

    private var title: Text
    private let subtitle: Text?
    private let accessory: Accessory

    @Environment(\.swiftForgeTheme) private var theme
    @SwiftForgeAccessibilityContext private var accessibility
    @State private var isTitleHidden = false

    /// Creates a navigation header with a trailing accessory.
    ///
    /// - Parameters:
    ///   - titleKey: The screen's title.
    ///   - subtitle: A line under the title, such as a count or date.
    ///   - accessory: A view at the trailing edge, such as an avatar or a button.
    public init(_ titleKey: LocalizedStringKey, subtitle: Text? = nil, @ViewBuilder accessory: () -> Accessory) {
        title = Text(titleKey)
        self.subtitle = subtitle
        self.accessory = accessory()
    }

    /// The content and behavior of the view.
    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                title
                    .font(theme.typography.font(theme.typography.largeTitle))
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                if let subtitle {
                    subtitle
                        .font(theme.typography.font(theme.typography.subheadline))
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            accessory
        }
        .padding(.top, theme.spacing.xs)
        .padding(.bottom, theme.spacing.md)
        // Hidden once its bottom edge passes the top of the scroll view.
        .onGeometryChange(for: Bool.self) { proxy in
            proxy.frame(in: .scrollView).maxY <= 0
        } action: { hidden in
            withAnimation(theme.motion.standard.animation(reduceMotion: accessibility.reduceMotion)) {
                isTitleHidden = hidden
            }
        }
        .navigationTitle(title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .principal) {
                // Added only once the large title is gone, so the title is
                // never on screen — or read — twice. Like the system's bar
                // titles, it's capped in size and offers the Large Content Viewer.
                if isTitleHidden {
                    title
                        .font(theme.typography.font(theme.typography.headline))
                        .foregroundStyle(theme.colors.textPrimary)
                        .accessibilityShowsLargeContentViewer()
                        .transition(.opacity)
                } else {
                    // An empty principal item would let the bar show the
                    // navigation title itself.
                    Color.clear
                        .frame(width: theme.spacing.xxxs, height: theme.spacing.xxxs)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}

extension SwiftForgeNavigationHeader where Accessory == EmptyView {

    /// Creates a navigation header.
    ///
    /// - Parameters:
    ///   - titleKey: The screen's title.
    ///   - subtitle: A line under the title, such as a count or date.
    public init(_ titleKey: LocalizedStringKey, subtitle: Text? = nil) {
        self.init(titleKey, subtitle: subtitle) { EmptyView() }
    }

    /// Creates a navigation header with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ title: S, subtitle: Text? = nil) {
        self.init("", subtitle: subtitle) { EmptyView() }
        self.title = Text(title)
    }
}

// MARK: - Previews

#Preview("Navigation header") {
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                SwiftForgeNavigationHeader("Inbox", subtitle: Text("12 unread")) {
                    SwiftForgeAvatar(name: "Ada Lovelace").controlSize(.small)
                }
                ForEach(0..<30) { index in
                    SwiftForgeListRow("Message \(index)", subtitle: Text("Preview of the message"))
                }
            }
            .padding(.horizontal)
        }
        .toolbar {
            Button("Compose", systemImage: "square.and.pencil") {}
        }
    }
}
