//
//  SwiftForgeControlLabel.swift
//  SwiftForgeUI
//

import SwiftUI

private struct SwiftForgeControlDescriptionKey: EnvironmentKey {
    static var defaultValue: Text? { nil }
}

extension EnvironmentValues {
    /// Secondary text shown under a toggle's or checkbox's label.
    var swiftForgeControlDescription: Text? {
        get { self[SwiftForgeControlDescriptionKey.self] }
        set { self[SwiftForgeControlDescriptionKey.self] = newValue }
    }
}

extension View {

    /// Adds secondary text under the label of a SwiftForgeUI switch or
    /// checkbox, such as what turning it on does.
    ///
    /// ```swift
    /// Toggle("Wi-Fi Assist", isOn: $assist)
    ///     .toggleStyle(.swiftForge)
    ///     .swiftForgeDescription("Use cellular data when Wi-Fi is poor.")
    /// ```
    ///
    /// VoiceOver reads the description as the control's hint. Apply it to
    /// the control itself: every switch and checkbox beneath the view shows it.
    public func swiftForgeDescription(_ description: Text?) -> some View {
        environment(\.swiftForgeControlDescription, description)
    }

    /// Adds localized secondary text under the label of a SwiftForgeUI switch
    /// or checkbox.
    public func swiftForgeDescription(_ descriptionKey: LocalizedStringKey) -> some View {
        environment(\.swiftForgeControlDescription, Text(descriptionKey))
    }

    /// Adds secondary text that isn't localized under the label of a
    /// SwiftForgeUI switch or checkbox.
    @_disfavoredOverload
    public func swiftForgeDescription<S: StringProtocol>(_ description: S) -> some View {
        environment(\.swiftForgeControlDescription, Text(description))
    }
}

/// A control's label in the body style, with its description, if any, below
/// in the secondary style. Shared by switches, checkboxes, and radio buttons.
struct SwiftForgeControlLabel<Label: View>: View {

    let label: Label

    @Environment(\.swiftForgeTheme) private var theme
    @Environment(\.swiftForgeControlDescription) private var description

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            label
                .font(theme.typography.font(theme.typography.body))
                .foregroundStyle(theme.colors.textPrimary)
            if let description {
                description
                    .font(theme.typography.font(theme.typography.subheadline))
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}

/// Reads whether labels are hidden with SwiftUI's `labelsHidden()`, which
/// custom toggle styles must honor themselves. The environment value is
/// public from iOS 18 and visionOS 2; earlier, labels always show.
struct SwiftForgeLabelsVisibilityReader<Content: View>: View {

    @ViewBuilder let content: (_ labelsHidden: Bool) -> Content

    var body: some View {
        if #available(iOS 18.0, visionOS 2.0, *) {
            SwiftForgeLabelsVisibilityReader18(content: content)
        } else {
            content(false)
        }
    }
}

@available(iOS 18.0, visionOS 2.0, *)
private struct SwiftForgeLabelsVisibilityReader18<Content: View>: View {

    let content: (Bool) -> Content

    @Environment(\.labelsVisibility) private var visibility

    var body: some View {
        content(visibility == .hidden)
    }
}

extension View {

    /// Keeps a hidden label in the accessibility tree without drawing it or
    /// taking space, so a control with `labelsHidden()` still has a name.
    func swiftForgeVisuallyHidden() -> some View {
        fixedSize()
            .frame(width: 0, height: 0)
            .clipped()
    }
}
