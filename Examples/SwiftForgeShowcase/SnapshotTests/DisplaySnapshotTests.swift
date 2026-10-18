//
//  DisplaySnapshotTests.swift
//  SnapshotTests
//

import SwiftUI
import Testing

@testable import SwiftForgeShowcase

/// The component catalog's display components, in the catalog matrix.
@MainActor
@Suite(
    "Display snapshots",
    .serialized,
    .enabled(if: Snapshot.isPinnedEnvironment, "Snapshots are recorded on iOS \(Snapshot.pinnedSystemMajorVersion)")
)
struct DisplaySnapshotTests {

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func listRows(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.ListRows(), named: "listRows", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func cardSlots(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.CardSlots(), named: "cardSlots", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func badgeSizes(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.BadgeSizes(), named: "badgeSizes", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func labeledDividers(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.LabeledDividers(), named: "labeledDividers", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func avatars(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Avatars(), named: "avatars", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func emptyStates(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.EmptyStates(), named: "emptyStates", variant: variant)
    }
}
