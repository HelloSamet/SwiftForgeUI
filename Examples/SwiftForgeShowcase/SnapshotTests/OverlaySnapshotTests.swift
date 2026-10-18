//
//  OverlaySnapshotTests.swift
//  SnapshotTests
//

import SwiftUI
import Testing

@testable import SwiftForgeShowcase

/// Toasts, dialogs, and the tab bar, in the catalog matrix. The dialog's
/// content is verified here: `ImageRenderer`, used by the unit tests, can't
/// draw views that take VoiceOver focus.
@MainActor
@Suite(
    "Overlay snapshots",
    .serialized,
    .enabled(if: Snapshot.isPinnedEnvironment, "Snapshots are recorded on iOS \(Snapshot.pinnedSystemMajorVersion)")
)
struct OverlaySnapshotTests {

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func toasts(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Toasts(), named: "toasts", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func dialogs(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Dialogs(), named: "dialogs", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func tabBars(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.TabBars(), named: "tabBars", variant: variant)
    }
}
