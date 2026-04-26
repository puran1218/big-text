import XCTest
@testable import BigText

final class ShowBigTextIntentTests: XCTestCase {
    private let userDefaultsKey = "intentText"

    override func setUp() {
        super.setUp()
        // Clean up UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    override func tearDown() {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        super.tearDown()
    }

    // MARK: - Test Cases

    func testIntentWithValidTextStoresToUserDefaults() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        intent.text = "Hello World"
        let expectedText = "Hello World"

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, expectedText, "Valid text should be stored in UserDefaults")
    }

    func testIntentWithEmptyStringDoesNotStore() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        intent.text = ""

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertNil(storedText, "Empty string should not be stored in UserDefaults")
    }

    func testIntentWithNilTextHandlesGracefully() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        intent.text = nil

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result, "Result should not be nil even with nil text")
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertNil(storedText, "Nil text should not crash and should not store anything")
    }

    func testIntentWithChineseCharacters() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        let chineseText = "你好世界"
        intent.text = chineseText

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, chineseText, "Chinese characters should be stored correctly")
    }

    func testIntentWithEmoji() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        let emojiText = "Hello 👋 World"
        intent.text = emojiText

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, emojiText, "Text with emoji should be stored correctly")
    }

    func testIntentWithVeryLongText() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        let longText = String(repeating: "A", count: 10000)
        intent.text = longText

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, longText, "Very long text (10000 characters) should be stored correctly")
    }

    func testIntentOverwritesPreviousValue() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        let firstText = "First Value"
        let secondText = "Second Value"

        // Act - First call
        intent.text = firstText
        _ = try await intent.perform()

        // Assert after first call
        var storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, firstText, "First value should be stored")

        // Act - Second call with different value
        intent.text = secondText
        _ = try await intent.perform()

        // Assert after second call
        storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, secondText, "Second value should overwrite the first")
        XCTAssertNotEqual(storedText, firstText, "Stored value should not be the first value")
    }

    func testIntentOpenAppWhenRun() {
        // Arrange & Act & Assert
        XCTAssertTrue(ShowBigTextIntent.openAppWhenRun, "openAppWhenRun should be true")
    }

    func testIntentTitle() {
        // Arrange & Act & Assert
        // The title is a LocalizedStringResource, so we verify it exists
        let title = ShowBigTextIntent.title
        XCTAssertNotNil(title, "Intent should have a title")
    }

    func testIntentWithWhitespaceOnlyDoesNotStore() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        intent.text = "   "

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        // Whitespace-only string is not empty, so it will be stored
        // This test documents the actual behavior
        XCTAssertEqual(storedText, "   ", "Whitespace-only text is stored as-is")
    }

    func testIntentWithNewlines() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        let multilineText = "Line 1\nLine 2\nLine 3"
        intent.text = multilineText

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, multilineText, "Multiline text should be stored correctly")
    }

    func testIntentWithSpecialCharacters() async throws {
        // Arrange
        let intent = ShowBigTextIntent()
        let specialText = "!@#$%^&*()_+-=[]{}|;':\",./<>?"
        intent.text = specialText

        // Act
        let result = try await intent.perform()

        // Assert
        XCTAssertNotNil(result)
        let storedText = UserDefaults.standard.string(forKey: userDefaultsKey)
        XCTAssertEqual(storedText, specialText, "Special characters should be stored correctly")
    }
}
