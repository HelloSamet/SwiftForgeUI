//
//  P2Pages.swift
//  SwiftForgeShowcase
//
//  Live pages for the stepper, one-time code field, rating, bottom sheet,
//  tooltips, and accordion.
//

import SwiftForgeUI
import SwiftUI

struct StepperAndCodePage: View {

    @State private var guests = 2
    @State private var tip = 15
    @State private var code = ""

    var body: some View {
        CatalogPageContainer {
            Specimen("Stepper") {
                SwiftForgeStepper("Guests", value: $guests, in: 1...12) { Text($0, format: .number) }
                SwiftForgeStepper("Tip", value: $tip, in: 0...30, step: 5) { Text(verbatim: "\($0)%") }
                Text("Hold + or − to speed up.").swiftForgeTextStyle(\.footnote)
            }
            Specimen("One-time code") {
                SwiftForgeOTPField(
                    "Verification code", code: $code,
                    state: code.count == 6
                        ? (code == "123456" ? .success("Verified.") : .error("That code isn't right."))
                        : .helper("Try 123456. Paste or use the code from a text message."))
            }
        }
    }
}

struct RatingPage: View {

    @State private var stars = 3.0
    @State private var halves = 3.5

    var body: some View {
        CatalogPageContainer {
            Specimen("Read-only") {
                HStack {
                    SwiftForgeRating(value: 4.5)
                    Text("4.5 · 1,284 reviews").swiftForgeTextStyle(\.footnote)
                }
            }
            Specimen("Interactive") {
                SwiftForgeRating("Your rating", value: $stars)
                SwiftForgeRating("Half stars", value: $halves, allowsHalfStars: true)
                Text(verbatim: "\(stars.formatted()) and \(halves.formatted()) stars").swiftForgeTextStyle(\.footnote)
            }
        }
    }
}

struct BottomSheetPage: View {

    @State private var showsFilters = false
    @State private var showsMap = false
    @State private var cuisines: Set<String> = ["Thai"]
    @State private var distance = 5.0

    var body: some View {
        CatalogPageContainer {
            Specimen("Bottom sheet") {
                Button("Filters (dimmed)") { showsFilters = true }
                Button("Details (background stays usable)") { showsMap = true }
            }
            .buttonStyle(.swiftForge(.tinted))
        }
        .swiftForgeBottomSheet(isPresented: $showsFilters) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    SwiftForgeSectionHeader("Filters") { Button("Done") { showsFilters = false } }
                    SwiftForgeChipGroup("Cuisine", selection: $cuisines, options: ["Italian", "Thai", "Turkish", "Mexican"]) {
                        Text($0)
                    }
                    SwiftForgeSlider("Distance", value: $distance, in: 1...20, step: 1) { Text("\(Int($0)) km") }
                }
                .padding()
            }
        }
        .swiftForgeBottomSheet(isPresented: $showsMap, detents: [.height(220), .medium], background: .interactive) {
            VStack(alignment: .leading, spacing: 12) {
                SwiftForgeSectionHeader("Harbor Café")
                SwiftForgeRating(value: 4.5)
                Text("Open until 22:00 · 1.2 km").swiftForgeTextStyle(\.subheadline)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct TooltipsPage: View {

    @State private var showsFees = false
    @State private var showsShortcut = false

    var body: some View {
        CatalogPageContainer {
            Specimen("Text") {
                HStack {
                    Text("Total: $42.00").swiftForgeTextStyle(\.headline)
                    Button("About fees", systemImage: "info.circle") { showsFees.toggle() }
                        .buttonStyle(.swiftForgeIcon())
                        .swiftForgeTooltip("A 2% fee applies to card payments.", isPresented: $showsFees)
                }
            }
            Specimen("Custom content") {
                Button("Search") { showsShortcut.toggle() }
                    .buttonStyle(.swiftForge(.tinted))
                    .swiftForgeTooltip(isPresented: $showsShortcut) {
                        Label("Press ⌘K to search from anywhere", systemImage: "keyboard")
                    }
                Text("Tap outside a tooltip to close it. With a pointer, hovering shows text tooltips too.")
                    .swiftForgeTextStyle(\.footnote)
            }
        }
    }
}

struct AccordionPage: View {

    @State private var expanded: String? = "Shipping"

    private let sections = [
        ("Shipping", "Orders ship within two business days. You'll get tracking by email."),
        ("Returns", "Return any item within 30 days, in its original packaging."),
        ("Warranty", "Every product has a two-year warranty against defects."),
    ]

    var body: some View {
        CatalogPageContainer {
            Specimen("One section at a time") {
                VStack(spacing: 0) {
                    ForEach(sections, id: \.0) { title, detail in
                        DisclosureGroup(
                            LocalizedStringKey(title),
                            isExpanded: Binding(get: { expanded == title }, set: { expanded = $0 ? title : nil })
                        ) {
                            Text(detail).swiftForgeTextStyle(\.body)
                        }
                        SwiftForgeDivider()
                    }
                }
                .disclosureGroupStyle(.swiftForge)
            }
        }
    }
}
