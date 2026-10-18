//
//  FoundationPages.swift
//  SwiftForgeShowcase
//

import SwiftForgeUI
import SwiftUI

struct ColorsPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        CatalogPageContainer {
            Specimen("Surfaces") {
                swatches([
                    ("canvas", theme.colors.canvas), ("surface", theme.colors.surface),
                    ("surfaceRaised", theme.colors.surfaceRaised), ("fillMuted", theme.colors.fillMuted),
                ])
            }
            Specimen("Content & lines") {
                swatches([
                    ("textPrimary", theme.colors.textPrimary), ("textSecondary", theme.colors.textSecondary),
                    ("borderSubtle", theme.colors.borderSubtle), ("borderStrong", theme.colors.borderStrong),
                    ("focusRing", theme.colors.focusRing),
                ])
            }
            ForEach(SwiftForgeTone.allCases, id: \.self) { tone in
                Specimen("Tone: \(tone.rawValue)") {
                    let colors = theme.colors[tone]
                    swatches([
                        ("solid", colors.solid), ("onSolid", colors.onSolid), ("text", colors.text), ("subtle", colors.subtle),
                    ])
                    HStack {
                        Text("Aa").foregroundStyle(colors.onSolid).padding(8).background(colors.solid, in: .rect(cornerRadius: 6))
                        Text("Tinted text").foregroundStyle(colors.text).padding(8).background(
                            colors.subtle, in: .rect(cornerRadius: 6))
                    }
                }
            }
        }
    }

    private func swatches(_ items: [(String, SwiftForgeColor)]) -> some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
            ForEach(items, id: \.0) { name, color in
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                        .fill(color)
                        .frame(height: 44)
                        .overlay {
                            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
                        }
                    Text(name).swiftForgeTextStyle(\.caption1).foregroundStyle(theme.colors.textSecondary)
                }
                .accessibilityElement(children: .combine)
            }
        }
    }
}

struct TypographyPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    private let roles: [(String, KeyPath<SwiftForgeTypography, SwiftForgeTextStyle>)] = [
        ("largeTitle", \.largeTitle), ("title1", \.title1), ("title2", \.title2), ("title3", \.title3),
        ("headline", \.headline), ("body", \.body), ("callout", \.callout), ("subheadline", \.subheadline),
        ("footnote", \.footnote), ("caption1", \.caption1), ("caption2", \.caption2),
        ("controlLabel", \.controlLabel), ("fieldLabel", \.fieldLabel), ("badge", \.badge),
    ]

    var body: some View {
        CatalogPageContainer {
            Specimen("Type scale — change Dynamic Type in Preview Settings") {
                ForEach(roles, id: \.0) { name, role in
                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text("The quick brown fox").swiftForgeTextStyle(role).foregroundStyle(theme.colors.textPrimary)
                        Text(name).swiftForgeTextStyle(\.caption1).foregroundStyle(theme.colors.textSecondary)
                    }
                }
            }
        }
    }
}

struct LayoutPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        let spacing = theme.spacing
        let steps: [(String, CGFloat)] = [
            ("xxxs", spacing.xxxs), ("xxs", spacing.xxs), ("xs", spacing.xs), ("sm", spacing.sm), ("md", spacing.md),
            ("lg", spacing.lg), ("xl", spacing.xl), ("xxl", spacing.xxl), ("xxxl", spacing.xxxl),
        ]
        let radii: [(String, CGFloat)] = [
            ("controlSmall", theme.radius.controlSmall), ("control", theme.radius.control),
            ("card", theme.radius.card), ("sheet", theme.radius.sheet),
        ]
        CatalogPageContainer {
            Specimen("Spacing") {
                ForEach(steps, id: \.0) { name, value in
                    HStack {
                        Text("\(name) · \(Int(value))").swiftForgeTextStyle(\.footnote).frame(width: 90, alignment: .leading)
                        Rectangle().fill(theme.colors.accent.solid).frame(width: value, height: 12)
                    }
                }
            }
            Specimen("Radius") {
                HStack(spacing: spacing.sm) {
                    ForEach(radii, id: \.0) { name, value in
                        VStack {
                            RoundedRectangle(cornerRadius: value, style: .continuous)
                                .fill(theme.colors.accent.subtle)
                                .frame(width: 64, height: 64)
                            Text(name).swiftForgeTextStyle(\.caption2)
                        }
                    }
                }
            }
        }
    }
}

struct ElevationPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        CatalogPageContainer {
            ForEach(SwiftForgeSurfaceLevel.allCases, id: \.self) { level in
                Text(String(describing: level))
                    .swiftForgeTextStyle(\.headline)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .swiftForgeSurface(level)
            }
        }
    }
}
