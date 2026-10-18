//
//  ControlPages.swift
//  SwiftForgeShowcase
//
//  Live pages for the selection and input controls of the component catalog.
//

import SwiftForgeUI
import SwiftUI

struct SelectionPage: View {

    @State private var terms = false
    @State private var newsletter = true
    @State private var permissions = [true, false, true]
    @State private var delivery = "Express"
    @State private var size: String?
    @State private var showsErrors = false

    private let permissionNames = ["Camera", "Microphone", "Location"]

    var body: some View {
        CatalogPageContainer {
            Specimen("Checkboxes") {
                Toggle("I agree to the terms", isOn: $terms)
                Toggle("Send me the newsletter", isOn: $newsletter)
                    .swiftForgeDescription("About once a month. Unsubscribe any time.")
                Toggle("Disabled", isOn: .constant(true)).disabled(true)
            }
            .toggleStyle(.swiftForgeCheckbox)
            Specimen("Mixed state") {
                Toggle(sources: $permissions, isOn: \.self) { Text("All permissions") }
                ForEach(permissionNames.indices, id: \.self) { index in
                    Toggle(permissionNames[index], isOn: $permissions[index])
                        .padding(.leading, 32)
                }
            }
            .toggleStyle(.swiftForgeCheckbox)
            Specimen("Radio groups") {
                SwiftForgeRadioGroup("Delivery", selection: $delivery, options: ["Standard", "Express", "Store pickup"]) {
                    Text($0)
                }
                SwiftForgeRadioGroup(
                    "Size", selection: $size, options: ["S", "M", "L", "XL"],
                    state: showsErrors && size == nil ? .error("Choose a size.") : .normal, axis: .horizontal
                ) { Text($0) }
                Toggle("Show validation", isOn: $showsErrors).toggleStyle(.swiftForge)
            }
        }
    }
}

struct ChipsPage: View {

    @State private var cuisines: Set<String> = ["Thai"]
    @State private var price: String?
    @State private var vegan = false
    @State private var recipients = ["Ada Lovelace", "Grace Hopper", "Katherine Johnson"]

    var body: some View {
        CatalogPageContainer {
            Specimen("Multiple choice") {
                SwiftForgeChipGroup(
                    "Cuisine", selection: $cuisines,
                    options: ["Italian", "Thai", "Turkish", "Mexican", "Japanese", "Indian", "Ethiopian"]
                ) { Text($0) }
            }
            Specimen("Single choice") {
                SwiftForgeChipGroup("Price", selection: $price, options: ["$", "$$", "$$$", "$$$$"]) { Text($0) }
            }
            Specimen("Filter, input, and action chips") {
                SwiftForgeChip("Vegan", systemImage: "leaf", isSelected: $vegan)
                SwiftForgeFlowLayout(spacing: 8) {
                    ForEach(recipients, id: \.self) { name in
                        SwiftForgeChip(name, onRemove: { recipients.removeAll { $0 == name } })
                    }
                    SwiftForgeChip("Add", systemImage: "plus", action: { recipients.append("Alan Turing") })
                }
            }
            Specimen("Density") {
                ForEach(SwiftForgeDensity.allCases, id: \.self) { density in
                    SwiftForgeChipGroup(
                        LocalizedStringKey(density.rawValue.capitalized), selection: $cuisines,
                        options: ["Italian", "Thai", "Turkish"]
                    ) { Text($0) }
                    .swiftForgeDensity(density)
                }
            }
        }
    }
}

struct SegmentedControlPage: View {

    @State private var period = "Week"
    @State private var layout = "List"

    var body: some View {
        CatalogPageContainer {
            Specimen("Text") {
                SwiftForgeSegmentedControl("Period", selection: $period, options: ["Day", "Week", "Month", "Year"]) {
                    Text($0)
                }
            }
            Specimen("Icon and text, small") {
                SwiftForgeSegmentedControl("Layout", selection: $layout, options: ["List", "Grid"]) { option in
                    Label(option, systemImage: option == "List" ? "list.bullet" : "square.grid.2x2")
                }
                .controlSize(.small)
            }
            Specimen("Disabled") {
                SwiftForgeSegmentedControl("Disabled", selection: .constant("On"), options: ["On", "Off"]) { Text($0) }
                    .disabled(true)
            }
        }
    }
}

struct SlidersPage: View {

    @State private var volume = 40.0
    @State private var brightness = 0.7
    @State private var price = 80.0...240.0

    var body: some View {
        CatalogPageContainer {
            Specimen("Single value") {
                SwiftForgeSlider("Volume", value: $volume, in: 0...100, step: 5) { Text(Int($0), format: .number) }
                SwiftForgeSlider("Brightness", value: $brightness, tone: .warning) {
                    Text($0, format: .percent.precision(.fractionLength(0)))
                }
            }
            Specimen("Range") {
                SwiftForgeRangeSlider("Price", value: $price, in: 0...500, step: 10) { range in
                    Text(verbatim: "\(Int(range.lowerBound))–\(Int(range.upperBound)) €")
                }
            }
            Specimen("Disabled") {
                SwiftForgeSlider("Disabled", value: .constant(0.3)).disabled(true)
            }
        }
    }
}

struct InputsPage: View {

    @State private var note = ""
    @State private var query = ""
    @State private var lastSearch = ""
    @State private var country = "Türkiye"
    @State private var size: String?
    @State private var zone: String?
    @State private var password = ""

    var body: some View {
        CatalogPageContainer {
            Specimen("Text area") {
                SwiftForgeTextArea("Delivery note", text: $note, prompt: Text("Gate code, landmarks…"))
                    .swiftForgeCharacterLimit(200)
            }
            Specimen("Search field") {
                SwiftForgeSearchField(text: $query) { lastSearch = $0 }
                Text(verbatim: lastSearch.isEmpty ? "Type to search; results update when you pause." : "Searched “\(lastSearch)”")
                    .swiftForgeTextStyle(\.footnote)
            }
            Specimen("Pickers") {
                SwiftForgePicker("Country", selection: $country, options: ["Germany", "Japan", "Türkiye", "Brazil"]) {
                    Text($0)
                }
                SwiftForgePicker("Size", selection: $size, options: ["S", "M", "L"], prompt: Text("Choose a size")) {
                    Text($0)
                }
                SwiftForgePicker(
                    "Time zone", selection: $zone, options: TimeZone.knownTimeZoneIdentifiers, searchText: { $0 }
                ) { Text($0) }
            }
            Specimen("Password strength") {
                SwiftForgeSecureField("New password", text: $password, state: .helper("Use 12 or more characters."))
                    .textContentType(.newPassword)
                    .swiftForgePasswordStrength(password.isEmpty ? nil : PasswordRules.strength(of: password))
            }
        }
    }
}

/// An example of the app-side rules the password strength meter shows.
/// SwiftForgeUI doesn't judge passwords itself.
enum PasswordRules {
    static func strength(of password: String) -> SwiftForgePasswordStrength {
        let classes = [
            password.contains(where: \.isLowercase), password.contains(where: \.isUppercase),
            password.contains(where: \.isNumber), password.contains(where: { !$0.isLetter && !$0.isNumber }),
        ].filter { $0 }.count
        switch (password.count, classes) {
        case (16..., 3...): return .strong
        case (12..., 2...): return .good
        case (8..., _): return .fair
        default: return .weak
        }
    }
}
