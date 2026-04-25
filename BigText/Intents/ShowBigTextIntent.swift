import AppIntents
import SwiftUI

// Intent to show big text from Siri
struct ShowBigTextIntent: AppIntent {
    static var title: LocalizedStringResource = "Show Big Text"
    static var description = IntentDescription("Displays text in full-screen.")

    static var openAppWhenRun: Bool = true

    // Parameter for the text to display
    @Parameter(title: "Text", description: "The text to display in big letters.")
    var text: String?

    // Perform the intent
    @MainActor
    func perform() async throws -> some IntentResult {
        // Store the text in UserDefaults for the app to pick up
        if let text = text, !text.isEmpty {
            UserDefaults.standard.set(text, forKey: "intentText")
        }

        return .result()
    }
}

// App Shortcuts Provider
struct BigTextAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowBigTextIntent(),
            phrases: [
                "Show big text \(.applicationName)",
                "Big text \(.applicationName)",
                "Display \(.applicationName)",
            ],
            shortTitle: "Big Text",
            systemImageName: "text.magnifyingglass"
        )
    }
}
