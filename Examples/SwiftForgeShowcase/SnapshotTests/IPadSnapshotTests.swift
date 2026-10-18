//
//  IPadSnapshotTests.swift
//  SnapshotTests
//

import SwiftUI
import Testing

@testable import SwiftForgeShowcase

/// Components whose layout depends on the available width, at an iPad's
/// regular width: toasts, dialogs, and empty states stop at a readable width;
/// full-width controls, banners, cards, and rows stretch.
@MainActor
@Suite(
    "iPad snapshots",
    .serialized,
    .enabled(if: Snapshot.isPinnedEnvironment, "Snapshots are recorded on iOS \(Snapshot.pinnedSystemMajorVersion)")
)
struct IPadSnapshotTests {

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func buttons(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Buttons(), named: "buttons", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func textFields(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.TextFields(), named: "textFields", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func banners(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Banners(), named: "banners", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func cards(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Cards(), named: "cards", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func listRows(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.ListRows(), named: "listRows", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func segmentedControls(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.SegmentedControls(), named: "segmentedControls", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func emptyStates(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.EmptyStates(), named: "emptyStates", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func toasts(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Toasts(), named: "toasts", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func dialogs(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Dialogs(), named: "dialogs", variant: variant)
    }

    @Test(arguments: SnapshotVariant.iPadMatrix)
    func tabBars(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.TabBars(), named: "tabBars", variant: variant)
    }
}
