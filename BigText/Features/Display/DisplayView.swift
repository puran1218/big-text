import SwiftUI

struct DisplayView: View {
    let text: String
    let onBack: () -> Void

    @StateObject private var shakeDetector = ShakeDetector()
    @State private var controlsVisible = false
    @State private var showLandscapeHint = false
    @State private var showShakeHint = false
    @State private var isFlashing = false
    @AppStorage("hasSeenShakeHint") private var hasSeenShakeHint = false
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                AutoFitTextView(text: text)
            }

            // Flash overlay
            FlashOverlay(isEnabled: isFlashing)

            // Landscape hint (shown in portrait)
            VStack {
                Spacer()
                DisplayHintToast(
                    message: "display.landscapeHint",
                    isVisible: verticalSizeClass == .regular && showLandscapeHint
                )
                .padding(.bottom, 40)
            }

            // First-use shake hint
            VStack {
                Spacer()
                DisplayHintToast(
                    message: "display.shakeHint",
                    isVisible: showShakeHint
                )
                .padding(.bottom, showLandscapeHint && verticalSizeClass == .regular ? 80 : 40)
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

            // Show shake hint on first use
            if !hasSeenShakeHint {
                showShakeHint = true

                // Auto-hide hint after 2.5 seconds
                Task {
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    showShakeHint = false
                    hasSeenShakeHint = true
                }
            }

            // Start shake detection
            shakeDetector.onDoubleShake = {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isFlashing.toggle()
                }
            }
            shakeDetector.start()
        }
        .onDisappear {
            IdleTimerController.setDisabled(false)
            shakeDetector.stop()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.18)) {
                controlsVisible.toggle()
            }
        }
    }
}
