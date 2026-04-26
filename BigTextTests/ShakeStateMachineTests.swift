import XCTest
import Combine
@testable import BigText

final class ShakeStateMachineTests: XCTestCase {
    var cancellables = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }

    // MARK: - Test Single Shake Does Not Trigger

    func testSingleShakeDoesNotTrigger() {
        var stateMachine = ShakeStateMachine()
        let event = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        let result = stateMachine.process(event: event)

        XCTAssertFalse(result, "A single shake should not trigger")
    }

    // MARK: - Test Second Shake Outside Window Does Not Trigger

    func testSecondShakeOutsideWindowDoesNotTrigger() {
        var stateMachine = ShakeStateMachine()
        let firstEvent = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        // First shake should not trigger
        let firstResult = stateMachine.process(event: firstEvent)
        XCTAssertFalse(firstResult, "First shake should not trigger")

        // Second shake 1 second later should not trigger (outside 0.7s window)
        let secondEvent = ShakeEvent(timestamp: firstEvent.timestamp.addingTimeInterval(1.0), acceleration: 3.0)
        let secondResult = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)

        XCTAssertFalse(secondResult, "Second shake outside the 0.7s window should not trigger")
    }

    // MARK: - Test Double Shake Within Window Triggers

    func testDoubleShakeWithinWindowTriggers() {
        var stateMachine = ShakeStateMachine()
        let firstEvent = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        // First shake should not trigger
        let firstResult = stateMachine.process(event: firstEvent)
        XCTAssertFalse(firstResult, "First shake should not trigger")

        // Second shake 0.5 seconds later should trigger (within 0.7s window)
        let secondEvent = ShakeEvent(timestamp: firstEvent.timestamp.addingTimeInterval(0.5), acceleration: 3.0)
        let secondResult = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)

        XCTAssertTrue(secondResult, "Second shake within the 0.7s window should trigger")
    }

    // MARK: - Test Double Shake At Exact Window Boundary Triggers

    func testDoubleShakeAtExactWindowBoundaryTriggers() {
        var stateMachine = ShakeStateMachine()
        let firstEvent = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        // First shake should not trigger
        let firstResult = stateMachine.process(event: firstEvent)
        XCTAssertFalse(firstResult, "First shake should not trigger")

        // Second shake at 0.699 seconds (just within the 0.7s window) should trigger
        // We use 0.699 instead of exactly 0.7 to avoid floating point precision issues
        let secondEvent = ShakeEvent(timestamp: firstEvent.timestamp.addingTimeInterval(0.699), acceleration: 3.0)
        let secondResult = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)

        XCTAssertTrue(secondResult, "Second shake within the 0.7s window (0.699s) should trigger")
    }

    // MARK: - Test Cooldown Prevents Immediate Retrigger

    func testCooldownPreventsImmediateRetrigger() {
        var stateMachine = ShakeStateMachine()
        let firstEvent = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        // First shake
        stateMachine.process(event: firstEvent)

        // Second shake within window - triggers
        let secondEvent = ShakeEvent(timestamp: firstEvent.timestamp.addingTimeInterval(0.5), acceleration: 3.0)
        let secondResult = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)
        XCTAssertTrue(secondResult, "Second shake within window should trigger")

        // Third shake immediately after trigger should not trigger (cooldown)
        let thirdEvent = ShakeEvent(timestamp: secondEvent.timestamp.addingTimeInterval(0.1), acceleration: 3.0)
        let thirdResult = stateMachine.process(event: thirdEvent, now: thirdEvent.timestamp)

        XCTAssertFalse(thirdResult, "Shake during cooldown should not trigger")
    }

    // MARK: - Test Cooldown Expires After Duration

    func testCooldownExpiresAfterDuration() {
        var stateMachine = ShakeStateMachine()
        let baseTime = Date()

        // First double shake triggers
        let firstEvent = ShakeEvent(timestamp: baseTime, acceleration: 3.0)
        stateMachine.process(event: firstEvent)

        let secondEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(0.5), acceleration: 3.0)
        let secondResult = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)
        XCTAssertTrue(secondResult, "Second shake should trigger")

        // After cooldown (1.0s), a new double shake should trigger
        let thirdEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(1.5), acceleration: 3.0)
        let thirdResult = stateMachine.process(event: thirdEvent, now: thirdEvent.timestamp)
        XCTAssertFalse(thirdResult, "First shake after cooldown should not trigger")

        let fourthEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(2.0), acceleration: 3.0)
        let fourthResult = stateMachine.process(event: fourthEvent, now: fourthEvent.timestamp)

        XCTAssertTrue(fourthResult, "New double shake after cooldown expires should trigger")
    }

    // MARK: - Test Reset Clears State

    func testResetClearsState() {
        var stateMachine = ShakeStateMachine()
        let firstEvent = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        // First shake puts us in firstShake state
        stateMachine.process(event: firstEvent)

        // Reset should clear state
        stateMachine.reset()

        // After reset, a single shake should not trigger (back to idle)
        let secondEvent = ShakeEvent(timestamp: Date().addingTimeInterval(0.1), acceleration: 3.0)
        let result = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)

        XCTAssertFalse(result, "After reset, a single shake should not trigger")
    }

    // MARK: - Test Rapid Shakes

    func testRapidShakes() {
        var stateMachine = ShakeStateMachine()
        let baseTime = Date()
        var triggerCount = 0

        // Rapid shakes: first double-shake triggers, subsequent ones during cooldown don't
        for i in 0..<10 {
            let event = ShakeEvent(timestamp: baseTime.addingTimeInterval(Double(i) * 0.1), acceleration: 3.0)
            if stateMachine.process(event: event, now: event.timestamp) {
                triggerCount += 1
            }
        }

        XCTAssertEqual(triggerCount, 1, "Only the first double-shake should trigger, rest should be in cooldown")
    }

    // MARK: - Test Exact Window Expiry

    func testExactWindowExpiry() {
        var stateMachine = ShakeStateMachine()
        let firstEvent = ShakeEvent(timestamp: Date(), acceleration: 3.0)

        // First shake
        stateMachine.process(event: firstEvent)

        // Second shake just beyond window (0.701s) should not trigger
        let secondEvent = ShakeEvent(timestamp: firstEvent.timestamp.addingTimeInterval(0.701), acceleration: 3.0)
        let secondResult = stateMachine.process(event: secondEvent, now: secondEvent.timestamp)

        XCTAssertFalse(secondResult, "Second shake just beyond the 0.7s window (0.701s) should not trigger")
    }

    // MARK: - Test Multiple Resets

    func testMultipleResets() {
        var stateMachine = ShakeStateMachine()
        let baseTime = Date()

        // First double-shake triggers
        let firstEvent = ShakeEvent(timestamp: baseTime, acceleration: 3.0)
        stateMachine.process(event: firstEvent)

        let secondEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(0.5), acceleration: 3.0)
        XCTAssertTrue(stateMachine.process(event: secondEvent, now: secondEvent.timestamp))

        // Reset
        stateMachine.reset()

        // Another double-shake should work
        let thirdEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(1.0), acceleration: 3.0)
        stateMachine.process(event: thirdEvent)

        let fourthEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(1.5), acceleration: 3.0)
        XCTAssertTrue(stateMachine.process(event: fourthEvent, now: fourthEvent.timestamp))

        // Reset again
        stateMachine.reset()

        // After reset, single shake should not trigger
        let fifthEvent = ShakeEvent(timestamp: baseTime.addingTimeInterval(2.0), acceleration: 3.0)
        XCTAssertFalse(stateMachine.process(event: fifthEvent, now: fifthEvent.timestamp))
    }
}
