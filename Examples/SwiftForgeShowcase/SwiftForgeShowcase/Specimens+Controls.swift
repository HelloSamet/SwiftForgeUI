//
//  Specimens+Controls.swift
//  SwiftForgeShowcase
//
//  Specimens of the selection and input controls added with the component
//  catalog: checkboxes, radio groups, chips, segmented controls, and fields.
//

import SwiftForgeUI
import SwiftUI

extension Specimens {

    struct Checkboxes: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Toggle("Checked", isOn: .constant(true))
                Toggle("Unchecked", isOn: .constant(false))
                    .swiftForgeDescription("A description below the label.")
                Toggle(sources: Binding.constant([true, false]), isOn: \.self) { Text("Partially checked") }
                Toggle("Danger", isOn: .constant(true)).toggleStyle(.swiftForgeCheckbox(tone: .danger))
                Toggle("Disabled", isOn: .constant(true)).disabled(true)
                Toggle("Switch with a description", isOn: .constant(true))
                    .toggleStyle(.swiftForge)
                    .swiftForgeDescription("Secondary text in the theme's secondary color.")
            }
            .toggleStyle(.swiftForgeCheckbox)
        }
    }

    struct RadioGroups: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                SwiftForgeRadioGroup(
                    "Delivery", selection: .constant("Express"), options: ["Standard", "Express", "Store pickup"]
                ) { Text($0) }
                SwiftForgeRadioGroup(
                    "Size", selection: .constant(String?.none), options: ["S", "M", "L", "XL"],
                    state: .error("Choose a size."), axis: .horizontal
                ) { Text($0) }
            }
        }
    }

    struct Chips: View {
        var body: some View {
            VStack(alignment: .leading, spacing: 16) {
                SwiftForgeChipGroup(
                    "Cuisine", selection: .constant(Set(["Thai", "Turkish"])),
                    options: ["Italian", "Thai", "Turkish", "Mexican", "Japanese", "Indian"]
                ) { Text($0) }
                HStack {
                    SwiftForgeChip("Vegan", systemImage: "leaf", isSelected: .constant(true))
                    SwiftForgeChip("Nearby", systemImage: "location", isSelected: .constant(false))
                    SwiftForgeChip("Disabled", isSelected: .constant(false)).disabled(true)
                }
                HStack {
                    SwiftForgeChip("Ada Lovelace", onRemove: {})
                    SwiftForgeChip("Add", systemImage: "plus", action: {})
                }
            }
        }
    }

    struct PasswordStrength: View {
        var body: some View {
            VStack(spacing: 12) {
                ForEach(SwiftForgePasswordStrength.allCases, id: \.self) { strength in
                    SwiftForgeSecureField("Password", text: .constant("correct horse"))
                        .swiftForgePasswordStrength(strength)
                }
            }
        }
    }

    struct SegmentedControls: View {
        var body: some View {
            VStack(spacing: 16) {
                SwiftForgeSegmentedControl("Period", selection: .constant("Week"), options: ["Day", "Week", "Month", "Year"]) {
                    Text($0)
                }
                SwiftForgeSegmentedControl("Layout", selection: .constant("Grid"), options: ["List", "Grid"]) { option in
                    Label(option, systemImage: option == "List" ? "list.bullet" : "square.grid.2x2")
                }
                .controlSize(.small)
                SwiftForgeSegmentedControl("Disabled", selection: .constant("On"), options: ["On", "Off"]) { Text($0) }
                    .disabled(true)
            }
        }
    }

    struct TextAreas: View {
        var body: some View {
            VStack(spacing: 12) {
                SwiftForgeTextArea(
                    "Delivery note", text: .constant("Leave the parcel with the neighbor at number 12 if nobody answers."),
                    state: .helper("Shown to the courier.")
                )
                .swiftForgeCharacterLimit(200)
                SwiftForgeTextArea("Message", text: .constant(""), prompt: Text("Write a message…"), lineLimit: 2...4)
            }
        }
    }

    struct SearchFields: View {
        var body: some View {
            VStack(spacing: 12) {
                SwiftForgeSearchField(text: .constant(""))
                SwiftForgeSearchField("Search contacts", text: .constant("Ada"), showsCancelButton: false)
            }
        }
    }

    struct Sliders: View {
        var body: some View {
            VStack(spacing: 16) {
                SwiftForgeSlider("Volume", value: .constant(40.0), in: 0...100, step: 5) { Text(Int($0), format: .number) }
                SwiftForgeRangeSlider("Price", value: .constant(80.0...240.0), in: 0...500, step: 10) { range in
                    Text(verbatim: "\(Int(range.lowerBound))–\(Int(range.upperBound)) €")
                }
                SwiftForgeSlider("Disabled", value: .constant(0.3)).disabled(true)
            }
        }
    }

    struct Pickers: View {
        var body: some View {
            VStack(spacing: 12) {
                SwiftForgePicker("Country", selection: .constant("Türkiye"), options: ["Germany", "Japan", "Türkiye"]) {
                    Text($0)
                }
                SwiftForgePicker(
                    "Size", selection: .constant(String?.none), options: ["S", "M", "L"], prompt: Text("Choose a size"),
                    state: .error("Choose a size.")
                ) { Text($0) }
                SwiftForgePicker(
                    "Time zone", selection: .constant(String?.some("Europe/Istanbul")), options: ["Europe/Istanbul"],
                    searchText: { $0 }
                ) { Text($0) }
            }
        }
    }
}
