//
//  Specimens+P2.swift
//  SwiftForgeShowcase
//
//  Specimens of the P2 components: stepper, one-time code field, rating,
//  and accordion. The bottom sheet is SwiftUI's own presentation and is
//  checked in the running app.
//

import SwiftForgeUI
import SwiftUI

extension Specimens {

    struct Steppers: View {
        var body: some View {
            VStack(spacing: 4) {
                SwiftForgeStepper("Guests", value: .constant(2), in: 1...12) { Text($0, format: .number) }
                SwiftForgeStepper("Minimum", value: .constant(1), in: 1...12) { Text($0, format: .number) }
                SwiftForgeStepper("Disabled", value: .constant(3), in: 0...5) { Text($0, format: .number) }
                    .disabled(true)
            }
        }
    }

    struct OTPFields: View {
        var body: some View {
            VStack(spacing: 16) {
                SwiftForgeOTPField("Verification code", code: .constant("4821"), state: .helper("Sent by text message."))
                SwiftForgeOTPField("PIN", code: .constant("12"), length: 4, state: .error("That PIN isn't right."))
            }
        }
    }

    struct Ratings: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                SwiftForgeRating(value: 4.5)
                SwiftForgeRating(value: 2, tone: .accent)
                SwiftForgeRating("Your rating", value: .constant(3))
                SwiftForgeRating("Half stars", value: .constant(2.5), allowsHalfStars: true)
            }
        }
    }

    struct Accordions: View {
        var body: some View {
            VStack(spacing: 0) {
                DisclosureGroup("Shipping", isExpanded: .constant(true)) {
                    Text("Orders ship within two business days.")
                }
                SwiftForgeDivider()
                DisclosureGroup("Returns", isExpanded: .constant(false)) {
                    Text("Return within 30 days.")
                }
                SwiftForgeDivider()
            }
            .disclosureGroupStyle(.swiftForge)
        }
    }
}
