//
//  SwiftForgeThemeMatrix.swift
//  SwiftForgeUI
//

import SwiftUI

/// Shows content in every built-in theme, in light and dark mode, side by
/// side — the preview matrix each component file uses:
///
/// ```swift
/// #Preview("All themes") {
///     SwiftForgeThemeMatrix { Button("Save") {}.buttonStyle(.swiftForge()) }
/// }
/// ```
struct SwiftForgeThemeMatrix<Content: View>: View {

    var dynamicTypeSize: DynamicTypeSize = .large
    @ViewBuilder let content: () -> Content

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(SwiftForgeTheme.builtIn) { theme in
                    HStack(alignment: .top, spacing: 0) {
                        cell(theme: theme, colorScheme: .light)
                        cell(theme: theme, colorScheme: .dark)
                    }
                }
            }
        }
        .environment(\.dynamicTypeSize, dynamicTypeSize)
    }

    private func cell(theme: SwiftForgeTheme, colorScheme: ColorScheme) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(verbatim: "\(theme.displayName) · \(colorScheme == .dark ? "dark" : "light")")
                .swiftForgeTextStyle(\.caption1)
                .foregroundStyle(theme.colors.textSecondary)
            content()
        }
        .padding(theme.spacing.md)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(theme.colors.canvas)
        .swiftForgeTheme(theme)
        .environment(\.colorScheme, colorScheme)
    }
}
