import Foundation
import CoreMotion
import UIKit

// MARK: - State Machine (Testable)

struct ShakeEvent: Equatable {
    let timestamp: Date
    let acceleration: Double
}

enum ShakeState: Equatable {
    case idle
    case firstShake(ShakeEvent)
    case triggered
    case cooldown(until: Date)
}

struct ShakeStateMachine {
    private var state: ShakeState = .idle
    let doubleShakeWindow: TimeInterval = 0.7
    let cooldownDuration: TimeInterval = 1.0

    mutating func process(event: ShakeEvent, now: Date = Date()) -> Bool {
        // Check if we're in cooldown
        if case .cooldown(let until) = state {
            if now < until {
                return false
            } else {
                state = .idle
            }
        }

        switch state {
        case .idle:
            state = .firstShake(event)
            return false

        case .firstShake(let firstEvent):
            let timeSinceFirst = now.timeIntervalSince(firstEvent.timestamp)
            if timeSinceFirst <= doubleShakeWindow {
                // Double shake detected!
                state = .triggered
                enterCooldown(now: now)
                return true
            } else {
                // First shake was too long ago, start fresh
                state = .firstShake(event)
                return false
            }

        case .triggered, .cooldown:
            // Should not reach here, but reset if we do
            state = .firstShake(event)
            return false
        }
    }

    private mutating func enterCooldown(now: Date) {
        state = .cooldown(until: now.addingTimeInterval(cooldownDuration))
    }

    func reset() {
        state = .idle
    }
}

// MARK: - Core Motion Detector

@MainActor
final class ShakeDetector: ObservableObject {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var stateMachine = ShakeStateMachine()

    // Configuration
    let shakeThreshold: Double = 2.5  // 2.5g
    let sampleInterval: TimeInterval = 1.0 / 60.0  // 60Hz

    // Callback
    var onDoubleShake: (() -> Void)?

    // Haptic feedback
    private let impactGenerator = UIImpactFeedbackGenerator(style: .medium)

    var isDetecting: Bool {
        motionManager.isAccelerometerActive
    }

    init() {
        queue.maxConcurrentOperationCount = 1
        queue.name = "com.bigtext.shakedetector"
        impactGenerator.prepare()
    }

    func start() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }

        motionManager.accelerometerUpdateInterval = sampleInterval

        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, error in
            guard let self = self, let data = data else { return }

            let acceleration = data.acceleration
            let magnitude = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            )

            // Check if this qualifies as a shake
            if magnitude >= self.shakeThreshold {
                let event = ShakeEvent(timestamp: data.timestamp, acceleration: magnitude)
                let triggered = self.stateMachine.process(event: event, now: Date())

                if triggered {
                    Task { @MainActor in
                        self.handleDoubleShake()
                    }
                }
            }
        }
    }

    func stop() {
        motionManager.stopAccelerometerUpdates()
        stateMachine.reset()
    }

    private func handleDoubleShake() {
        // Haptic feedback
        impactGenerator.impactOccurred()
        impactGenerator.prepare()

        // Notify listener
        onDoubleShake?()
    }
}
