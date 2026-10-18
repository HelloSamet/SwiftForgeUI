//
//  CatalogView.swift
//  SwiftForgeShowcase
//

import SwiftForgeUI
import SwiftUI

enum CatalogPage: String, CaseIterable, Identifiable, Hashable {
    case colors, typography, layout, elevation
    case buttons, toggles, fields, banners, badges, cards, progress, skeleton, loadingOverlay, dividers
    case selection, chips, segmentedControl, sliders, inputs
    case listRows, avatars, emptyState
    case toastsAndDialogs, tabBarAndHeader
    case stepperAndCode, rating, bottomSheet, accordion, tooltips
    case themeGallery, themeComparison, states
    case authExample, settingsExample, inboxExample
    case contrastAudit, stress

    var id: Self { self }

    var title: String {
        switch self {
        case .colors: "Color"
        case .typography: "Typography"
        case .layout: "Spacing & Radius"
        case .elevation: "Elevation"
        case .buttons: "Buttons & Icon Buttons"
        case .toggles: "Switches"
        case .fields: "Text Fields"
        case .banners: "Banners"
        case .badges: "Badges"
        case .cards: "Cards & Surfaces"
        case .progress: "Progress"
        case .skeleton: "Skeleton"
        case .loadingOverlay: "Loading Overlay"
        case .dividers: "Dividers"
        case .selection: "Checkboxes & Radios"
        case .chips: "Chips"
        case .segmentedControl: "Segmented Control"
        case .sliders: "Sliders"
        case .inputs: "Text Area, Search & Pickers"
        case .listRows: "List Rows"
        case .avatars: "Avatars"
        case .emptyState: "Empty State"
        case .toastsAndDialogs: "Toasts & Dialogs"
        case .tabBarAndHeader: "Tab Bar & Header"
        case .stepperAndCode: "Stepper & Code Field"
        case .rating: "Rating"
        case .bottomSheet: "Bottom Sheet"
        case .accordion: "Accordion"
        case .tooltips: "Tooltips"
        case .themeGallery: "Theme Gallery"
        case .themeComparison: "Compare Themes"
        case .states: "State Matrix"
        case .authExample: "Sign In & Sign Up"
        case .settingsExample: "Settings"
        case .inboxExample: "Inbox"
        case .contrastAudit: "Contrast Audit"
        case .stress: "Performance Stress Test"
        }
    }

    var systemImage: String {
        switch self {
        case .colors: "paintpalette"
        case .typography: "textformat"
        case .layout: "square.dashed"
        case .elevation: "square.stack.3d.up"
        case .buttons: "rectangle.and.hand.point.up.left"
        case .toggles: "switch.2"
        case .fields: "character.cursor.ibeam"
        case .banners: "exclamationmark.bubble"
        case .badges: "app.badge"
        case .cards: "rectangle.on.rectangle"
        case .progress: "chart.bar.fill"
        case .skeleton: "rectangle.dashed"
        case .loadingOverlay: "hourglass"
        case .dividers: "minus"
        case .selection: "checkmark.square"
        case .chips: "tag"
        case .segmentedControl: "rectangle.split.3x1"
        case .sliders: "slider.horizontal.3"
        case .inputs: "text.cursor"
        case .listRows: "list.bullet.rectangle"
        case .avatars: "person.crop.circle"
        case .emptyState: "tray"
        case .toastsAndDialogs: "bubble.left.and.exclamationmark.bubble.right"
        case .tabBarAndHeader: "dock.rectangle"
        case .stepperAndCode: "plusminus"
        case .rating: "star"
        case .bottomSheet: "rectangle.bottomhalf.inset.filled"
        case .accordion: "chevron.down.square"
        case .tooltips: "text.bubble"
        case .themeGallery: "paintbrush"
        case .themeComparison: "rectangle.split.2x1"
        case .states: "square.grid.3x3"
        case .authExample: "person.badge.key"
        case .settingsExample: "gearshape"
        case .inboxExample: "envelope"
        case .contrastAudit: "checkmark.seal"
        case .stress: "speedometer"
        }
    }

    /// The catalog's sections, in the brief's categories.
    static let sections: [(title: String, pages: [CatalogPage])] = [
        ("Theming", [.themeGallery, .themeComparison, .states]),
        ("Foundations", [.colors, .typography, .layout, .elevation]),
        ("Actions", [.buttons, .chips, .segmentedControl]),
        ("Inputs & Forms", [.fields, .inputs, .toggles, .selection, .sliders, .stepperAndCode]),
        ("Display", [.cards, .badges, .avatars, .listRows, .dividers, .progress, .skeleton, .emptyState, .rating]),
        ("Feedback & Overlays", [.toastsAndDialogs, .banners, .bottomSheet, .tooltips, .loadingOverlay]),
        ("Navigation", [.tabBarAndHeader, .accordion]),
        ("Example Screens", [.authExample, .settingsExample, .inboxExample]),
        ("Tools", [.contrastAudit, .stress]),
    ]

    @MainActor @ViewBuilder
    var destination: some View {
        switch self {
        case .colors: ColorsPage()
        case .typography: TypographyPage()
        case .layout: LayoutPage()
        case .elevation: ElevationPage()
        case .buttons: ButtonsPage()
        case .toggles: TogglesPage()
        case .fields: FieldsPage()
        case .banners: BannersPage()
        case .badges: BadgesPage()
        case .cards: CardsPage()
        case .progress: ProgressPage()
        case .skeleton: SkeletonPage()
        case .loadingOverlay: LoadingOverlayPage()
        case .dividers: DividersPage()
        case .selection: SelectionPage()
        case .chips: ChipsPage()
        case .segmentedControl: SegmentedControlPage()
        case .sliders: SlidersPage()
        case .inputs: InputsPage()
        case .listRows: ListRowsPage()
        case .avatars: AvatarsPage()
        case .emptyState: EmptyStatePage()
        case .toastsAndDialogs: ToastsAndDialogsPage()
        case .tabBarAndHeader: TabBarAndHeaderPage()
        case .themeGallery: ThemeGalleryPage()
        case .themeComparison: ThemeComparisonPage()
        case .states: StateMatrixPage()
        case .authExample: AuthExample()
        case .settingsExample: SettingsExample()
        case .inboxExample: InboxExample()
        case .stepperAndCode: StepperAndCodePage()
        case .rating: RatingPage()
        case .bottomSheet: BottomSheetPage()
        case .tooltips: TooltipsPage()
        case .accordion: AccordionPage()
        case .contrastAudit: ContrastAuditPage()
        case .stress: StressTestPage()
        }
    }
}

struct CatalogView: View {

    @State private var selection: CatalogPage? = nil
    @State private var isShowingSettings = false
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(CatalogPage.sections, id: \.title) { section in
                    self.section(section.title, section.pages)
                }
            }
            .navigationTitle("SwiftForgeUI")
            .toolbar {
                Button("Preview Settings", systemImage: "slider.horizontal.3") { isShowingSettings = true }
            }
        } detail: {
            if let selection {
                // A stack in the detail column lets pages push screens, such as
                // the inbox's message detail.
                NavigationStack {
                    selection.destination
                        .navigationTitle(selection.title)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .id(selection)
            } else {
                ContentUnavailableView("Choose a page", systemImage: "square.grid.2x2")
            }
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
                .presentationDetents([.medium, .large])
        }
    }

    private func section(_ title: String, _ pages: [CatalogPage]) -> some View {
        Section(title) {
            ForEach(pages) { page in
                NavigationLink(value: page) {
                    Label(page.title, systemImage: page.systemImage)
                }
            }
        }
    }
}

struct SettingsView: View {

    @Environment(ShowcaseSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                Section("Theme") {
                    Picker(
                        "Theme",
                        selection: Binding(get: { settings.themes.theme.id }, set: { settings.themes.select(id: $0) })
                    ) {
                        ForEach(settings.themes.themes) { theme in
                            Text(theme.displayName).tag(theme.id)
                        }
                    }
                    Picker("Appearance", selection: $settings.appearance) {
                        ForEach(ShowcaseSettings.Appearance.allCases) { Text($0.rawValue.capitalized).tag($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("Content") {
                    Picker("Dynamic Type", selection: $settings.dynamicTypeSize) {
                        Text("System").tag(DynamicTypeSize?.none)
                        ForEach(DynamicTypeSize.allCases, id: \.self) { size in
                            Text(String(describing: size)).tag(DynamicTypeSize?.some(size))
                        }
                    }
                    Toggle("Right-to-left layout", isOn: $settings.isRightToLeft)
                    Picker("Library language", selection: $settings.language) {
                        ForEach(ShowcaseSettings.Language.allCases) { Text($0.name).tag($0) }
                    }
                }
                Section {
                    Toggle("Increase Contrast", isOn: $settings.increasedContrast)
                    Toggle("Reduce Motion", isOn: $settings.reduceMotion)
                    Toggle("Reduce Transparency", isOn: $settings.reduceTransparency)
                } header: {
                    Text("Accessibility simulation")
                } footer: {
                    Text(
                        "Simulated with swiftForgeAccessibilitySimulation(). Settings turned on in the Settings app always apply."
                    )
                }
            }
            .navigationTitle("Preview Settings")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
}

/// A scrolling page with consistent spacing and the theme's canvas.
struct CatalogPageContainer<Content: View>: View {

    @ViewBuilder let content: Content
    @Environment(\.swiftForgeTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.section) {
                content
            }
            .padding(theme.spacing.screenHorizontal)
            .frame(maxWidth: 672)
            .frame(maxWidth: .infinity)
        }
        .background(theme.colors.canvas)
    }
}

/// A titled group of specimens on a catalog page.
struct Specimen<Content: View>: View {

    let title: String
    @ViewBuilder let content: Content
    @Environment(\.swiftForgeTheme) private var theme

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(title)
                .swiftForgeTextStyle(\.headline, color: \.textPrimary)
                .accessibilityAddTraits(.isHeader)
            content
        }
    }
}
