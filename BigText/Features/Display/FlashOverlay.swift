import SwiftUI

struct FlashOverlay: View {
    let isEnabled: Bool

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    @State private var pulsePhase: PulsePhase = .idle

    private enum PulsePhase: Equatable {
        case idle
        case fadeIn
        case hold
        case fadeOut
    }

    private var pulseOpacity: Double {
        switch pulsePhase {
        case .idle:
            return 0.0
        case .fadeIn:
            return reduceMotion ? 0.3 : 0.6
        case .hold:
            return reduceMotion ? 0.3 : 0.6
        case .fadeOut:
            return reduceMotion ? 0.3 : 0.6
        }
    }

    private var phaseDuration: TimeInterval {
        switch pulsePhase {
        case .idle:
            return reduceMotion ? 2.0 : 1.6
        case .fadeIn:
            return reduceMotion ? 1.0 : 0.4
        case .hold:
            return reduceMotion ? 0.0 : 0.1
        case .fadeOut:
            return reduceMotion ? 1.0 : 0.4
        }
    }

    var body: some View {
        ZStack {
            if isEnabled {
                Color.white
                    .opacity(pulseOpacity)
                    .ignoresSafeArea()
            }
        }
        .animation(.easeInOut(duration: phaseDuration), value: pulsePhase)
        .onAppear {
            if isEnabled {
                startPulse()
            }
        }
        .onChange(of: isEnabled) { _, newValue in
            if newValue {
                startPulse()
            } else {
                pulsePhase = .idle
            }
        }
    }

    private func startPulse() {
        guard isEnabled else { return }

        Task {
            while isEnabled {
                if reduceMotion {
                    // Reduced motion: simple in-out cycle
                    await fadeIn()
                    await fadeOut()
                    await idle()
                } else {
                    // Normal: two-stage pulse
                    await fadeIn()
                    await hold()
                    await fadeOut()
                    await idle()
                }
            }
        }
    }

    @MainActor
    private func fadeIn() async {
        guard isEnabled else { return }
        pulsePhase = .fadeIn
        try? await Task.sleep(nanoseconds: UInt64(phaseDuration * 1_000_000_000))
    }

    @MainActor
    private func hold() async {
        guard isEnabled && !reduceMotion else { return }
        pulsePhase = .hold
        try? await Task.sleep(nanoseconds: UInt64(phaseDuration * 1_000_000_000))
    }

    @MainActor
    private func fadeOut() async {
        guard isEnabled else { return }
        pulsePhase = .fadeOut
        try? await Task.sleep(nanoseconds: UInt64(phaseDuration * 1_000_000_000))
    }

    @MainActor
    private func idle() async {
        guard isEnabled else { return }
        pulsePhase = .idle
        try? await Task.sleep(nanoseconds: UInt64(phaseDuration * 1_000_000_000))
    }
}
