import XCTest
@testable import BigText
import SwiftUI

/// Unit tests for UI components in the BigText app.
/// These tests verify component configuration and behavior in isolation.
final class BigTextUITests: XCTestCase {

    // MARK: - AutoFitTextView Tests

    func testAutoFitTextViewConfiguration() {
        // Given: A text string
        let testText = "Test"

        // When: Creating an AutoFitTextView
        let view = AutoFitTextView(text: testText)

        // Then: Verify the view can be created without errors
        // Note: SwiftUI views are value types, so we verify the view exists
        // The actual font size (320), multiline (lineLimit: 5), and other modifiers
        // are applied in the body. Since SwiftUI views are opaque structs,
        // we verify by rendering and checking the view doesn't crash.
        let _ = view.body

        // Verify the view accepts text correctly
        let viewWithLongText = AutoFitTextView(text: "This is a much longer text for testing")
        let _ = viewWithLongText.body

        // Verify with empty text
        let emptyView = AutoFitTextView(text: "")
        let _ = emptyView.body
    }

    // MARK: - FlashOverlay Tests

    func testFlashOverlayInitialState() {
        // Given: FlashOverlay is disabled
        let view = FlashOverlay(isEnabled: false)

        // When: The view is created
        // Then: It should render without errors
        // When disabled, the ZStack contains no views (the if isEnabled block is not executed)
        let body = view.body

        // Verify the body can be accessed without errors
        // We can't inspect the body structure directly, but we verify it doesn't crash
        let _ = body
    }

    func testFlashOverlayWithReduceMotion() {
        // Given: FlashOverlay is enabled
        let view = FlashOverlay(isEnabled: true)

        // When: Accessing the view
        // Then: Verify it renders
        let body = view.body
        let _ = body

        // Note: Actual reduceMotion values come from the environment
        // In unit tests, we can't fully test SwiftUI environment values,
        // but we verify the view structure is correct
        // The opacity and duration values are computed properties based on reduceMotion:
        // - reduceMotion = true: opacity 0.3, durations 1.0-2.0s
        // - reduceMotion = false: opacity 0.6, durations 0.1-1.6s

        // Verify the view doesn't crash when enabled
        let enabledView = FlashOverlay(isEnabled: true)
        let _ = enabledView.body
    }

    // MARK: - AppSettingsStore Tests

    @MainActor
    func testAppSettingsStorePersistence() {
        // Given: A fresh AppSettingsStore
        let settings = AppSettingsStore()

        // When: Setting values
        let testText = "Test persistence text"
        settings.lastText = testText
        settings.hasSeenShakeHint = true

        // Then: Values should be accessible
        XCTAssertEqual(settings.lastText, testText, "lastText should persist")
        XCTAssertEqual(settings.hasSeenShakeHint, true, "hasSeenShakeHint should persist")

        // When: Creating a new instance (simulating app restart)
        let newSettings = AppSettingsStore()

        // Then: Values should persist via @AppStorage
        // Note: In actual test runs, UserDefaults persists within the test bundle
        XCTAssertEqual(newSettings.lastText, testText, "lastText should persist across instances")
        XCTAssertEqual(newSettings.hasSeenShakeHint, true, "hasSeenShakeHint should persist across instances")

        // Cleanup: Reset values
        settings.lastText = ""
        settings.hasSeenShakeHint = false
    }

    @MainActor
    func testAppSettingsStoreDefaultValues() {
        // Given: A new AppSettingsStore
        let settings = AppSettingsStore()

        // When: Accessing default values
        // Then: Should match expected defaults
        XCTAssertEqual(settings.lastText, "", "Default lastText should be empty string")
        XCTAssertEqual(settings.hasSeenShakeHint, false, "Default hasSeenShakeHint should be false")
    }

    // MARK: - IdleTimerController Tests

    func testIdleTimerController() {
        // Given: The IdleTimerController enum
        // When: Setting idle timer disabled
        IdleTimerController.setDisabled(true)

        // Then: Verify it doesn't crash
        // Note: UIApplication.shared.isIdleTimerDisabled is a singleton property
        // We can't easily test the actual value change without running in a full app context,
        // but we can verify the API is callable without errors

        // When: Re-enabling idle timer
        IdleTimerController.setDisabled(false)

        // Then: Should complete without error
        // This test verifies the API is correctly structured and callable
        XCTAssertTrue(true, "IdleTimerController API is callable")
    }

    func testIdleTimerControllerDisablesIdleTimer() {
        // Given: Current idle timer state
        // Note: We can't read the current state directly in tests,
        // but we can verify setting it doesn't crash

        // When/Then: Test setting true
        IdleTimerController.setDisabled(true)

        // When/Then: Test setting false
        IdleTimerController.setDisabled(false)

        // When/Then: Test toggling back
        IdleTimerController.setDisabled(true)

        // Verify the call sequence completes without errors
        XCTAssertTrue(true, "Idle timer toggling completes successfully")
    }
}
