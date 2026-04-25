# Big Text / 大字

A minimal iOS utility that displays text as large as possible in full-screen.

## What It Does

1. Type or paste text
2. Tap "显示" / "Show"
3. Full-screen black background, white text, as big as possible
4. (v1.1) Shake twice to toggle flashing attention pulse
5. (v1.1) Siri: "Hey Siri, big text I'm here"

Use cases: noisy environments (concerts, restaurants), distance signaling (airport pickup, classroom), temporary signage.

## Development Status

✅ **Source Code Complete** (v1.0 + v1.1) - Awaiting Xcode setup

### v1.0 Features
- [x] Text input with restore last text
- [x] Full-screen black/white display
- [x] Auto-fit text sizing
- [x] Landscape hint in portrait
- [x] Idle timer disabled during display
- [x] Tap to show back controls
- [x] Bilingual (en + zh-Hans)

### v1.1 Features
- [x] Shake-to-flash (double-shake detection)
- [x] Flash overlay (gentle pulse, not strobe)
- [x] First-use shake hint
- [x] Siri App Intent (voice activation)

### Pending
- [ ] Apple Developer enrollment
- [ ] Xcode project creation
- [ ] Real device testing
- [ ] App Store submission

## Two-Ship Strategy

Both v1.0 and v1.1 source code are complete. Ship v1.0 first (fast approval), use it, then ship v1.1 (update).

Rationale: Two App Store learning opportunities instead of one. Better dopamine schedule.

## Tech Stack

- SwiftUI
- iOS 17+
- @AppStorage for persistence
- UIKit bridge for idle timer
- Zero third-party dependencies
- 100% offline

## Setup

See **[SETUP.md](SETUP.md)** for detailed setup instructions.

Quick checklist:
1. Enroll in Apple Developer Program ($99/yr) ⚠️ **DO TODAY**
2. Install Xcode 15.x+
3. Create Xcode project (iOS App, SwiftUI)
4. Add existing files to project
5. Configure Info.plist (encryption exemption)
6. Build and run

## Project Structure

```
BigText/
 ├── BigTextApp.swift          # @main entry point
 ├── AppRootView.swift         # .editing/.displaying state machine
 │
 ├── Features/
 │    ├── Editor/              # Input screen (portrait-only)
 │    │   ├── EditorView.swift
 │    │   ├── BigTextInput.swift
 │    │   └── PrimaryActionButton.swift
 │    │
 │    └── Display/             # Full-screen display (landscape-friendly)
 │        ├── DisplayView.swift
 │        ├── AutoFitTextView.swift
 │        ├── FlashOverlay.swift       # v1.1
 │        ├── DisplayHintToast.swift
 │        └── BackControlOverlay.swift
 │
 ├── Intents/                  # v1.1
 │    └── ShowBigTextIntent.swift  # Siri App Intent
 │
 ├── Services/
 │    ├── ShakeDetector.swift  # v1.1 - Core Motion
 │    ├── IdleTimerController.swift
 │    └── (TextFitEngine.swift - future upgrade)
 │
 ├── Data/
 │    └── AppSettingsStore.swift
 │
 ├── Design/
 │    ├── BigTextColors.swift
 │    ├── BigTextTypography.swift
 │    └── BigTextSpacing.swift
 │
 ├── Localizable.xcstrings     # UI strings (en + zh-Hans)
 └── AppShortcuts.xcstrings    # Siri phrases (en + zh-Hans)
```

## Design Philosophy

> 越少越好。输入、展示、提醒，除此之外都不做。

No themes. No font selection. No history. No accounts. No analytics.

Just: Type. Show. Done.

## License

Proprietary - For personal use only.

---

**Goal:** Learn SwiftUI by shipping a real, complete iOS app. 🚀
