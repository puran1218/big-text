# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BigText is a minimal iOS utility app built with SwiftUI. Type or paste text, tap "Show", and the text displays full-screen in black/white with auto-fitting font size. v1.1 adds shake-to-flash (double shake toggles a gentle pulse) and Siri voice activation.

**Design Philosophy:** 越少越好. Type, show, done. No themes, no history, no accounts.

---

## Common Commands

### Build
```bash
xcodebuild -project BigText.xcodeproj -scheme BigText -sdk iphonesimulator -destination 'id=<SIMULATOR_ID>' build
```

Find available simulators:
```bash
xcrun simctl list devices available | grep iPhone
```

### Run Tests
```bash
# All tests
xcodebuild test -project BigText.xcodeproj -scheme BigText -destination 'id=<SIMULATOR_ID>'

# Specific test suite
xcodebuild test -project BigText.xcodeproj -scheme BigText -destination 'id=<SIMULATOR_ID>' -only-testing:BigTextTests/ShakeStateMachineTests
```

### Clean Build
```bash
xcodebuild -project BigText.xcodeproj -scheme BigText clean
```

### List Project Targets/Schemes
```bash
xcodebuild -project BigText.xcodeproj -list
```

---

## Architecture

### App State Machine (AppRootView)

The app uses a simple state machine at the root level:
- `AppMode.editing` → Shows `EditorView` (text input, portrait-only)
- `AppMode.displaying` → Shows `DisplayView` (full-screen text, landscape-friendly)

`AppRootView` holds the state and handles Siri App Intent integration by checking `UserDefaults.standard.string(forKey: "intentText")` on appear.

### Shake Detection (ShakeStateMachine)

The shake detector is split into **testable pure logic** and **UIKit wrapper**:

1. **`ShakeStateMachine`** (struct) - Pure Swift, no dependencies:
   - `process(event:now:) -> Bool` returns true on double-shake
   - Window: 0.7s between shakes
   - Cooldown: 1.0s after trigger
   - Fully unit tested in `ShakeStateMachineTests.swift`

2. **`ShakeDetector`** (class, @MainActor) - UIKit wrapper:
   - Wraps `CMMotionManager` accelerometer
   - Calls state machine, triggers haptic + callback
   - Tests for state machine; integration tests needed for CoreMotion

### Directory Structure

```
BigText/
 ├── Features/Editor/      # Input screen (portrait-locked)
 ├── Features/Display/     # Full-screen display (landscape-friendly)
 ├── Services/             # ShakeDetector, IdleTimerController
 ├── Data/                 # AppSettingsStore (@AppStorage wrapper)
 ├── Design/               # Colors, Typography, Spacing constants
 └── Intents/              # ShowBigTextIntent (Siri App Intent)
```

### Key Design Patterns

- **@AppStorage for persistence** - `AppSettingsStore` wraps `@AppStorage("lastText")` and `@AppStorage("hasSeenShakeHint")`
- ** UIKit bridges for iOS-only features** - `IdleTimerController` wraps `UIApplication.shared.isIdleTimerDisabled`
- **Test-first for complex logic** - `ShakeStateMachine` has 10 unit tests covering state transitions, boundaries, and edge cases

---

## Localization

Bilingual support via `Localizable.xcstrings` (String Catalog). Keys are referenced using `LocalizableStringResource` or localized string literals. Strings exist in both `en` and `zh-Hans`.

---

## App Intent Integration

Siri shortcut "Show big text [text]" stores to `UserDefaults.standard` with key `"intentText"`. On app launch, `AppRootView` checks this key, updates `lastText`, switches to `.displaying` mode, then clears the key.

---

## Known Limitations

- SwiftUI views are opaque structs - unit tests verify they don't crash on body access, but snapshot testing would be better
- `IdleTimerController` cannot be mocked in unit tests (requires UIApplication)
- CoreMotion accelerometer integration requires device testing

---

## Code Signing Notes

- Current bundle ID `com.example.bigtext` is a placeholder
- Development team is empty - requires Apple Developer enrollment ($99/yr) for real device testing and App Store submission
- See SETUP.md for enrollment steps

---

## Test Suite

- **ShakeStateMachineTests.swift** (10 tests) - State machine unit tests
- **ShowBigTextIntentTests.swift** (12 tests) - App Intent tests
- **BigTextUITests.swift** (6 tests) - UI component unit tests
- **BigTextTests.swift** (1 test) - Entry point

All tests pass in ~0.6 seconds on simulator.
