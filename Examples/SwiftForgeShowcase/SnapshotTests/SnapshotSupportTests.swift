//
//  SnapshotSupportTests.swift
//  SnapshotTests
//

import Foundation
import Testing

@Suite("Snapshot support")
struct SnapshotSupportTests {

    @Test("Only a Git checkout counts as the reference images")
    func referenceCheckout() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }

        #expect(!Snapshot.isReferenceCheckout(directory))
        #expect(!Snapshot.isReferenceCheckout(directory.appendingPathComponent("missing")))

        try FileManager.default.createDirectory(at: directory.appendingPathComponent(".git"), withIntermediateDirectories: true)
        #expect(Snapshot.isReferenceCheckout(directory))
    }
}
