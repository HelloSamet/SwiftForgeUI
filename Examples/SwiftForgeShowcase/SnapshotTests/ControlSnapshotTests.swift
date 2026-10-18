//
//  ControlSnapshotTests.swift
//  SnapshotTests
//

import SwiftUI
import Testing

@testable import SwiftForgeShowcase

/// The component catalog's controls in every built-in theme and color
/// scheme, and Forge at AX5, right to left, and with Bold Text.
@MainActor
@Suite(
    "Control snapshots",
    .serialized,
    .enabled(if: Snapshot.isPinnedEnvironment, "Snapshots are recorded on iOS \(Snapshot.pinnedSystemMajorVersion)")
)
struct ControlSnapshotTests {

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func checkboxes(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Checkboxes(), named: "checkboxes", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func radioGroups(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.RadioGroups(), named: "radioGroups", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func chips(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Chips(), named: "chips", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func passwordStrength(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.PasswordStrength(), named: "passwordStrength", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func segmentedControls(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.SegmentedControls(), named: "segmentedControls", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func textAreas(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.TextAreas(), named: "textAreas", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func searchFields(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.SearchFields(), named: "searchFields", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func sliders(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Sliders(), named: "sliders", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func pickers(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Pickers(), named: "pickers", variant: variant)
    }
}
