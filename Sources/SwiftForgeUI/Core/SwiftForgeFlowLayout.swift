//
//  SwiftForgeFlowLayout.swift
//  SwiftForgeUI
//

import SwiftUI

/// A layout that places views in a row and wraps to a new row when the
/// next view doesn't fit, like words in a paragraph.
///
/// Chip groups and horizontal radio groups use it. Use it for your own
/// tags or tokens:
///
/// ```swift
/// SwiftForgeFlowLayout(spacing: theme.spacing.xs) {
///     ForEach(tags, id: \.self) { tag in
///         SwiftForgeBadge(tag)
///     }
/// }
/// ```
///
/// Rows follow the reading direction, so they start on the right in
/// right-to-left languages. A view wider than the container gets the full
/// width and wraps its own content.
public struct SwiftForgeFlowLayout: Layout {

    /// The horizontal gap between views in a row.
    public var horizontalSpacing: CGFloat
    /// The vertical gap between rows.
    public var verticalSpacing: CGFloat
    /// How each row is aligned within the container.
    public var alignment: HorizontalAlignment

    /// Creates a flow layout.
    ///
    /// - Parameters:
    ///   - horizontalSpacing: The gap between views in a row.
    ///   - verticalSpacing: The gap between rows. Defaults to `horizontalSpacing`.
    ///   - alignment: How each row is aligned. Defaults to leading.
    public init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat? = nil, alignment: HorizontalAlignment = .leading) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing ?? horizontalSpacing
        self.alignment = alignment
    }

    /// Creates a flow layout with the same gap between views and rows.
    public init(spacing: CGFloat, alignment: HorizontalAlignment = .leading) {
        self.init(horizontalSpacing: spacing, verticalSpacing: spacing, alignment: alignment)
    }

    /// Reports the size of the rows.
    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrange(subviews, maxWidth: proposal.width ?? .infinity)
        let width = rows.map(\.width).max() ?? 0
        let height = rows.map(\.height).reduce(0, +) + verticalSpacing * CGFloat(max(rows.count - 1, 0))
        return CGSize(width: proposal.width.map { min($0, width) } ?? width, height: height)
    }

    /// Places each view in its row.
    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var y = bounds.minY
        for row in arrange(subviews, maxWidth: bounds.width) {
            let free = bounds.width - row.width
            var x = bounds.minX
            switch alignment {
            case .center: x += free / 2
            case .trailing: x += free
            default: break
            }
            for item in row.items {
                // Center each view vertically in its row.
                let itemY = y + (row.height - item.size.height) / 2
                subviews[item.index].place(
                    at: CGPoint(x: x, y: itemY), anchor: .topLeading, proposal: ProposedViewSize(item.size))
                x += item.size.width + horizontalSpacing
            }
            y += row.height + verticalSpacing
        }
    }

    struct Row {
        var items: [(index: Int, size: CGSize)] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
    }

    /// Greedy line breaking: each view goes on the current row if it fits,
    /// otherwise starts a new one.
    func arrange(_ subviews: Subviews, maxWidth: CGFloat) -> [Row] {
        arrange(
            sizes: subviews.map { subview in
                let ideal = subview.sizeThatFits(.unspecified)
                guard ideal.width > maxWidth else { return ideal }
                // Too wide for any row: give it the full width to wrap its content.
                return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            }, maxWidth: maxWidth)
    }

    func arrange(sizes: [CGSize], maxWidth: CGFloat) -> [Row] {
        var rows: [Row] = []
        var current = Row()
        for (index, size) in sizes.enumerated() {
            let proposedWidth = current.items.isEmpty ? size.width : current.width + horizontalSpacing + size.width
            if !current.items.isEmpty, proposedWidth > maxWidth {
                rows.append(current)
                current = Row()
            }
            current.width = current.items.isEmpty ? size.width : current.width + horizontalSpacing + size.width
            current.height = max(current.height, size.height)
            current.items.append((index, size))
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }
}
