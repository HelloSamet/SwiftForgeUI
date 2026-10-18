//
//  P2SnapshotTests.swift
//  SnapshotTests
//

import SwiftUI
import Testing

@testable import SwiftForgeShowcase

/// The P2 components in the catalog matrix.
@MainActor
@Suite(
    "P2 snapshots",
    .serialized,
    .enabled(if: Snapshot.isPinnedEnvironment, "Snapshots are recorded on iOS \(Snapshot.pinnedSystemMajorVersion)")
)
struct P2SnapshotTests {

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func steppers(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Steppers(), named: "steppers", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func otpFields(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.OTPFields(), named: "otpFields", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func ratings(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Ratings(), named: "ratings", variant: variant)
    }

    @Test(arguments: SnapshotVariant.catalogMatrix)
    func accordions(variant: SnapshotVariant) async {
        await Snapshot.verify(Specimens.Accordions(), named: "accordions", variant: variant)
    }
}
