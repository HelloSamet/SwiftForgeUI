//
//  ComponentSnapshotTests.swift
//  SnapshotTests
//

import SwiftUI
import Testing

@testable import SwiftForgeShowcase

/// Every P0 component across both themes, both color schemes, AX5 Dynamic
/// Type, right-to-left layout, and Increase Contrast.
@MainActor
@Suite(
    "Component snapshots",
    .serialized,
    .enabled(if: Snapshot.isPinnedEnvironment, "Snapshots are recorded on iOS \(Snapshot.pinnedSystemMajorVersion)")
)
struct ComponentSnapshotTests {

    @Test(arguments: SnapshotVariant.matrix)
    func buttons(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Buttons(), named: "buttons", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func toggles(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Toggles(), named: "toggles", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func textFields(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.TextFields(), named: "textFields", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func banners(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Banners(), named: "banners", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func badges(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Badges(), named: "badges", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func cards(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Cards(), named: "cards", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func progress(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Progress(), named: "progress", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func skeleton(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Skeleton(), named: "skeleton", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func dividers(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Dividers(), named: "dividers", variant: variant)
    }

    @Test(arguments: SnapshotVariant.matrix)
    func surfaces(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Surfaces(), named: "surfaces", variant: variant)
    }
}
