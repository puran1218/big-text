import SwiftUI

struct DisplayView: View {
    let text: String
    let onBack: () -> Void

    @State private var controlsVisible = false
    @State private var showLandscapeHint = false
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                AutoFitTextView(text: text)
            }

            // Landscape hint (shown in portrait)
            VStack {
                Spacer()
                DisplayHintToast(
                    message: "Turn phone for better display",
                    isVisible: verticalSizeClass == .regular && showLandscapeHint
                )
                .padding(.bottom, 40)
            }

            // Back control overlay
            BackControlOverlay(
                isVisible: controlsVisible,
                onBack: onBack
            )
        }
        .statusBar(hidden: true)
        .onAppear {
            IdleTimerController.setDisabled(true)
            showLandscapeHint = true
        }
        .onDisappear {
            IdleTimerController.setDisabled(false)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) {
                controlsVisible.toggle()
            }
        }
    }
}
