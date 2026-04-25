# Big Text / 大字

A minimal iOS utility that displays text as large as possible in full-screen.

## What It Does

1. Type or paste text
2. Tap "显示" / "Show"
3. Full-screen black background, white text, as big as possible

Use cases: noisy environments (concerts, restaurants), distance signaling (airport pickup, classroom), temporary signage.

## v1.0 Status

🚧 **In Development** - Project structure complete, awaiting Xcode setup.

### Completed
- [x] Data layer (AppSettingsStore)
- [x] Design tokens (Colors, Typography, Spacing)
- [x] Editor view with input and button
- [x] Display view with auto-fit text
- [x] Idle timer control
- [x] Landscape hint for portrait mode
- [x] Bilingual strings (en + zh-Hans)
- [x] Project structure

### Pending
- [ ] Apple Developer enrollment
- [ ] Xcode project creation
- [ ] Real device testing
- [ ] App Store submission

## Two-Ship Strategy

**v1.0** (current): Input → Display → Done. ~2 weekends.

**v1.1** (after v1.0 ships): Shake-to-flash + Siri App Intent. ~2 more weekends.

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
 │    └── Display/             # Full-screen display (landscape-friendly)
 │
 ├── Services/                 # IdleTimer, Shake (v1.1)
 ├── Data/                     # AppSettingsStore
 ├── Design/                   # Colors, Typography, Spacing
 └── Localizable.xcstrings     # en + zh-Hans
```

## Design Philosophy

> 越少越好。输入、展示、提醒，除此之外都不做。

No themes. No font selection. No history. No accounts. No analytics.

Just: Type. Show. Done.

## License

Proprietary - For personal use only.

---

**Goal:** Learn SwiftUI by shipping a real, complete iOS app. 🚀
