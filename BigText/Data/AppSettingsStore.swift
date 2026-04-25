import SwiftUI

@MainActor
final class AppSettingsStore: ObservableObject {
    @AppStorage("lastText") var lastText: String = ""
    @AppStorage("hasSeenShakeHint") var hasSeenShakeHint: Bool = false
}
