//
//  ToolPages.swift
//  SwiftForgeShowcase
//

import SwiftForgeUI
import SwiftUI
import UIKit

struct ContrastAuditPage: View {

    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        let violations = SwiftForgeContrastAudit.run(on: theme)
        CatalogPageContainer {
            if violations.isEmpty {
                SwiftForgeBanner(
                    .success,
                    title: "\(theme.displayName) passes WCAG AA",
                    message:
                        "Every text and control color pairing meets its required contrast in light, dark, and both Increase Contrast appearances."
                )
            } else {
                SwiftForgeBanner(.danger, title: "\(violations.count) contrast violations in \(theme.displayName)")
                ForEach(violations, id: \.self) { violation in
                    Text(violation.description).swiftForgeTextStyle(\.footnote)
                }
            }
        }
    }
}

/// 500 mixed components in a lazy stack, for profiling with Instruments and
/// the scrolling performance test: cards, list rows with avatars, chips,
/// ratings, steppers, and toggles, with optional skeletons.
struct StressTestPage: View {

    /// Whether the page scrolls itself and reports, for the performance test.
    var autoScroll = false
    /// Native SwiftUI controls instead of SwiftForgeUI's, as a baseline.
    var native = false
    /// Only one kind of row (0–3), to measure components one at a time.
    var kind: Int?

    @State private var isLoading = true
    @State private var monitor = FrameMonitor()
    @State private var report = "No measurement"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(0..<500) { index in
                        Group {
                            if native {
                                NativeStressRow(index: index, kind: kind ?? index % 4)
                            } else {
                                StressRow(index: index, kind: kind ?? index % 4)
                            }
                        }
                        .swiftForgeSkeleton(isActive: isLoading && index.isMultiple(of: 2))
                        .id(index)
                    }
                }
                .padding()
            }
            .accessibilityIdentifier("stress")
            .task {
                guard autoScroll else { return }
                var results: [String] = []
                for skeletons in [true, false] {
                    isLoading = skeletons
                    results.append("skeletons:\(skeletons) " + (await scrollThrough(proxy)))
                }
                report = results.joined(separator: " | ")
            }
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Toggle("Skeletons", isOn: $isLoading).fixedSize()
                Spacer()
                Button("Reset Frames") { monitor.reset() }
                Button("Report Frames") { report = monitor.report }
            }
            .buttonStyle(.swiftForge(.plain))
            .controlSize(.small)
            .padding(.horizontal)
            .background(.bar)
        }
        .overlay(alignment: .bottom) {
            Text(verbatim: report)
                .swiftForgeTextStyle(\.footnote, color: \.textSecondary)
                .accessibilityIdentifier("frames")
        }
        .onAppear { monitor.start() }
        .onDisappear { monitor.stop() }
    }

    /// Scrolls to the end and back, 20 rows every quarter second, and
    /// returns the frame report.
    private func scrollThrough(_ proxy: ScrollViewProxy) async -> String {
        try? await Task.sleep(for: .seconds(1))
        monitor.reset()
        for row in Array(stride(from: 20, through: 480, by: 20)) + Array(stride(from: 460, through: 0, by: -20)) {
            withAnimation(.linear(duration: 0.25)) { proxy.scrollTo(row, anchor: .top) }
            try? await Task.sleep(for: .seconds(0.25))
        }
        return monitor.report
    }
}

/// The stress rows built from native SwiftUI controls.
private struct NativeStressRow: View {

    let index: Int
    let kind: Int
    @State private var isOn = false
    @State private var count = 1

    var body: some View {
        switch kind {
        case 0:
            GroupBox {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Item \(index)").font(.headline)
                        Text("Row content for profiling").font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(index % 12)").font(.caption).padding(4).background(.red, in: .capsule)
                    Button("Open", systemImage: "chevron.forward") {}.labelStyle(.iconOnly)
                }
            }
        case 1:
            HStack {
                Image(systemName: "person.crop.circle.fill").font(.largeTitle)
                VStack(alignment: .leading) {
                    Text("Person \(index)")
                    Text("Last seen today").font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .padding()
            .background(.background.secondary, in: .rect(cornerRadius: 12))
        case 2:
            HStack {
                ForEach(["Swift", "UI", "Design", "Testing"], id: \.self) { tag in
                    Button(tag) {}.buttonStyle(.bordered)
                }
            }
        default:
            VStack(alignment: .leading, spacing: 8) {
                HStack { ForEach(0..<5) { Image(systemName: $0 < index % 6 ? "star.fill" : "star") } }
                Stepper("Quantity \(count)", value: $count, in: 1...9)
                Toggle("Notify \(index)", isOn: $isOn)
            }
        }
    }
}

/// Measures main-thread hitches with a display link: the time by which
/// frames arrived later than the display's frame duration, per second.
/// Stats are read on demand so that measuring doesn't update the view.
@MainActor
final class FrameMonitor: NSObject {

    private var link: CADisplayLink?
    private var lastTimestamp: CFTimeInterval = 0
    private var elapsed: CFTimeInterval = 0
    private var hitchTime: CFTimeInterval = 0
    private var worstFrame: CFTimeInterval = 0
    private var hitches = 0

    func start() {
        guard link == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick(_:)))
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    func stop() {
        link?.invalidate()
        link = nil
    }

    func reset() {
        lastTimestamp = 0
        elapsed = 0
        hitchTime = 0
        worstFrame = 0
        hitches = 0
    }

    var report: String {
        let ratio = elapsed > 0 ? hitchTime * 1000 / elapsed : 0
        return String(
            format: "hitchRatio:%.2f hitches:%d worstFrame:%.1f elapsed:%.2f", ratio, hitches, worstFrame * 1000, elapsed)
    }

    @objc private func tick(_ link: CADisplayLink) {
        defer { lastTimestamp = link.timestamp }
        guard lastTimestamp > 0 else { return }
        let delta = link.timestamp - lastTimestamp
        elapsed += delta
        worstFrame = max(worstFrame, delta)
        // A frame more than half a frame late counts as a hitch.
        if delta > link.duration * 1.5 {
            hitchTime += delta - link.duration
            hitches += 1
        }
    }
}

private struct StressRow: View {

    let index: Int
    let kind: Int
    @State private var isOn = false
    @State private var count = 1
    @State private var tags: Set<String> = ["Swift"]

    var body: some View {
        switch kind {
        case 0:
            SwiftForgeCard(style: index.isMultiple(of: 3) ? .elevated : .outlined) {
                HStack {
                    CardContent(title: "Item \(index)", subtitle: "Row content for profiling")
                    Spacer()
                    SwiftForgeBadge(count: index % 12)
                    Button("Open", systemImage: "chevron.forward") {}.buttonStyle(.swiftForgeIcon(.tinted))
                }
            }
        case 1:
            SwiftForgeListRow("Person \(index)", subtitle: Text("Last seen today"), accessory: .chevron) {
                SwiftForgeAvatar(name: "Person \(index)", status: index.isMultiple(of: 5) ? .online : nil)
            } trailing: {
                SwiftForgeBadge.dot(tone: .accent)
            }
            .swiftForgeSurface()
        case 2:
            SwiftForgeChipGroup("Tags \(index)", selection: $tags, options: ["Swift", "UI", "Design", "Testing"]) {
                Text($0)
            }
        default:
            VStack(alignment: .leading, spacing: 8) {
                SwiftForgeRating(value: Double(index % 11) / 2)
                SwiftForgeStepper("Quantity", value: $count, in: 1...9) { Text($0, format: .number) }
                Toggle("Notify \(index)", isOn: $isOn).toggleStyle(.swiftForge)
            }
        }
    }
}
