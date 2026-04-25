import SwiftUI

enum AppMode {
    case editing
    case displaying
}

struct AppRootView: View {
    @StateObject private var store = AppSettingsStore()
    @State private var mode: AppMode = .editing

    var body: some View {
        Group {
            switch mode {
            case .editing:
                EditorView(
                    text: Binding(
                        get: { store.lastText },
                        set: { store.lastText = $0 }
                    ),
                    onShow: {
                        mode = .displaying
                    }
                )
            case .displaying:
                DisplayView(
                    text: store.lastText,
                    onBack: {
                        mode = .editing
                    }
                )
            }
        }
        .onAppear {
            // Check if launched from Siri App Intent
            if let intentText = UserDefaults.standard.string(forKey: "intentText"), !intentText.isEmpty {
                store.lastText = intentText
                UserDefaults.standard.removeObject(forKey: "intentText")
                mode = .displaying
            }
        }
    }
}
