//
//  SwiftForgeButton.swift
//  SwiftForgeUI
//

import SwiftUI

/// A button that runs an `async` action and shows its loading state while
/// the action is in flight.
///
/// ```swift
/// SwiftForgeButton("Save") {
///     try await store.save(draft)
/// } onError: { error in
///     saveError = error
/// }
/// ```
///
/// While the action runs, the button shows a progress indicator without
/// changing size and ignores further taps, so the action never runs twice.
/// Errors are passed to `onError`; SwiftForgeUI never presents them itself.
///
/// > Important: The action's task is cancelled when the button disappears,
/// > including when it scrolls out of a `List` or lazy stack. If the button
/// > comes back before the action returns, it keeps showing its loading
/// > state, and taps are still ignored. Run work that must finish whether
/// > or not the button is visible — such as saving — in your model, and
/// > have the button await it.
///
/// The button uses ``SwiftForgeButtonStyle``, so `controlSize(_:)`,
/// ``SwiftUICore/View/swiftForgeFullWidth(_:)``, and `disabled(_:)` work as they
/// do for a styled `Button`.
public struct SwiftForgeButton<Label: View>: View {

    private let variant: SwiftForgeButtonStyle.Variant
    private let tone: SwiftForgeTone?
    private let role: ButtonRole?
    private let action: @MainActor () async throws -> Void
    private let onError: (@MainActor (any Error) -> Void)?
    private let label: Label

    @State private var flight = SwiftForgeSingleFlight()

    /// Creates a button with a custom label.
    ///
    /// - Parameters:
    ///   - variant: The level of emphasis. Defaults to ``SwiftForgeButtonStyle/Variant/filled``.
    ///   - tone: The color family. Defaults to the accent, or danger for destructive buttons.
    ///   - role: The button's role, such as `.destructive`.
    ///   - action: The async action to run.
    ///   - onError: Called on the main actor if `action` throws an error
    ///     other than `CancellationError`.
    ///   - label: The button's label.
    public init(
        variant: SwiftForgeButtonStyle.Variant = .filled,
        tone: SwiftForgeTone? = nil,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () async throws -> Void,
        onError: (@MainActor (any Error) -> Void)? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.tone = tone
        self.role = role
        self.action = action
        self.onError = onError
        self.label = label()
    }

    /// The content and behavior of the view.
    public var body: some View {
        Button(role: role, action: run) { label }
            .buttonStyle(SwiftForgeButtonStyle(variant, tone: tone))
            .swiftForgeLoading(flight.isRunning)
            .onDisappear { flight.cancel() }
    }

    private func run() {
        let action = action
        let onError = onError
        flight.run {
            do {
                try await action()
            } catch is CancellationError {
                // The button disappeared; there's no one left to tell.
            } catch {
                onError?(error)
            }
        }
    }
}

extension SwiftForgeButton where Label == Text {

    /// Creates a button with a localized title.
    public init(
        _ titleKey: LocalizedStringKey,
        variant: SwiftForgeButtonStyle.Variant = .filled,
        tone: SwiftForgeTone? = nil,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () async throws -> Void,
        onError: (@MainActor (any Error) -> Void)? = nil
    ) {
        self.init(variant: variant, tone: tone, role: role, action: action, onError: onError) { Text(titleKey) }
    }

    /// Creates a button with a title that isn't localized.
    @_disfavoredOverload
    public init<S: StringProtocol>(
        _ title: S,
        variant: SwiftForgeButtonStyle.Variant = .filled,
        tone: SwiftForgeTone? = nil,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () async throws -> Void,
        onError: (@MainActor (any Error) -> Void)? = nil
    ) {
        self.init(variant: variant, tone: tone, role: role, action: action, onError: onError) { Text(title) }
    }
}

extension SwiftForgeButton where Label == SwiftUI.Label<Text, Image> {

    /// Creates a button with a localized title and an SF Symbol.
    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        variant: SwiftForgeButtonStyle.Variant = .filled,
        tone: SwiftForgeTone? = nil,
        role: ButtonRole? = nil,
        action: @escaping @MainActor () async throws -> Void,
        onError: (@MainActor (any Error) -> Void)? = nil
    ) {
        self.init(variant: variant, tone: tone, role: role, action: action, onError: onError) {
            SwiftUI.Label(titleKey, systemImage: systemImage)
        }
    }
}

#Preview("Async action") {
    VStack(spacing: 12) {
        SwiftForgeButton("Save") { try await Task.sleep(for: .seconds(2)) }
        SwiftForgeButton("Upload", systemImage: "icloud.and.arrow.up", variant: .tinted) {
            try await Task.sleep(for: .seconds(2))
        }
        .controlSize(.large)
    }
    .padding()
}
