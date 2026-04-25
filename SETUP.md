# Big Text iOS App - Setup Guide

## Prerequisites Status

- [x] Project structure created
- [ ] **Apple Developer Program enrollment** - DO TODAY ($99/year)
- [ ] Xcode installed (15.x or later)
- [ ] Bundle ID decided (currently using temporary: `com.example.bigtext`)

---

## Step 1: Enroll in Apple Developer Program ⚠️ CRITICAL

1. Go to **developer.apple.com/programs**
2. Click "Enroll" → **Individual** enrollment (recommended for solo)
3. Sign in with your Apple ID
4. Pay $99/year
5. **Wait for email confirmation** (24-48 hours best case, 1-2 weeks worst case)

**You cannot submit to App Store without this. Start TODAY.**

---

## Step 2: Install Xcode

1. Open **App Store** on your Mac
2. Search for "Xcode" (by Apple)
3. Click **Get** / **Install** (~15GB download)
4. Once installed, open Xcode and accept the license
5. Install additional components when prompted

---

## Step 3: Choose Your Bundle ID

**Current temporary:** `com.example.bigtext`

**You MUST change this before App Store submission.**

Format: `com.<your-domain-or-handle>.bigtext`

Examples:
- `com.johndoe.bigtext`
- `com.mywebsite.bigtext`
- `com.githubusername.bigtext`

**This is PERMANENT after first App Store submission.**

---

## Step 4: Create Xcode Project

Once Xcode is installed:

1. Open Xcode
2. **File → New → Project**
3. Choose **iOS → App**
4. Fill in:
   - **Product Name:** `BigText`
   - **Team:** Your Apple Developer team
   - **Organization Identifier:** Use your bundle ID prefix (e.g., `com.johndoe`)
   - **Bundle Identifier:** Will be auto-generated (verify it matches your choice)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None (uncheck Core Data)
   - **Include Tests:** Unchecked (add later if needed)

5. Save location: Create a new folder, or replace the current structure

---

## Step 5: Add Existing Files to Xcode

After creating the project:

1. In Xcode Project Navigator, delete the auto-generated `ContentView.swift`
2. Right-click project → **Add Files to "BigText"**
3. Navigate to the `BigText/` folder in this repo
4. Add all folders: `Features/`, `Services/`, `Data/`, `Design/`
5. **Check "Copy items if needed"** if files are outside Xcode project
6. Add `AppRootView.swift` and ensure it's in target

---

## Step 6: Configure Info.plist

In Xcode, open `Info.plist` and add:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

This prevents export-compliance prompts on every TestFlight upload.

---

## Step 7: Configure Supported Orientations

To lock EditorView to portrait and allow DisplayView in landscape:

1. In **Info.plist**, set:
   - `Supported interface orientations` → Portrait only
2. For DisplayView landscape support, add `OrientationController.swift` (v1.0 uses portrait-with-hint approach)

---

## Step 8: Create App Icon

Quick option for v1.0:

1. Create a 1024×1024 PNG:
   - Black background (#000000)
   - White "大" character in center (huge, ~600pt)
   - Use system font: Heavy/Bold

2. Add to `Assets.xcassets/AppIcon.appiconset/1024.png`

3. In Xcode: Select `AppIcon` → Verify all sizes are filled

---

## Step 9: Build and Run

1. Select a simulator (iPhone 15 Pro or iPhone 16 Pro Max)
2. **Product → Run** (⌘R)
3. Test the basic flow:
   - Type text in editor
   - Tap "显示" / "Show"
   - Should go to full-screen display
   - Tap to show back button
   - Verify landscape rotation works

---

## Step 10: Test on Real Device (Before App Store!)

1. Connect your iPhone via cable
2. In Xcode: **Window → Devices and Simulators**
3. Enable development on your device (follow prompts)
4. Select your device as run target
5. Build and run
6. **Actually use it for 5 minutes** in a real scenario

---

## Project Structure

```
BigText/
 ├── BigTextApp.swift          # App entry point
 ├── AppRootView.swift         # State machine (.editing/.displaying)
 │
 ├── Features/
 │    ├── Editor/
 │    │    ├── EditorView.swift
 │    │    ├── BigTextInput.swift
 │    │    └── PrimaryActionButton.swift
 │    │
 │    └── Display/
 │         ├── DisplayView.swift
 │         ├── AutoFitTextView.swift
 │         ├── DisplayHintToast.swift
 │         └── BackControlOverlay.swift
 │
 ├── Services/
 │    ├── ShakeDetector.swift     # v1.1
 │    ├── TextFitEngine.swift     # v1.1 (upgrade)
 │    ├── IdleTimerController.swift
 │    └── OrientationController.swift  # v1.1 (if force-landscape needed)
 │
 ├── Data/
 │    └── AppSettingsStore.swift
 │
 ├── Design/
 │    ├── BigTextColors.swift
 │    ├── BigTextTypography.swift
 │    └── BigTextSpacing.swift
 │
 └── Localizable.xcstrings        # en + zh-Hans strings
```

---

## v1.0 Features (Complete)

✅ Text input with restore last text
✅ Full-screen black/white display
✅ Auto-fit text sizing (using minimumScaleFactor)
✅ Landscape hint in portrait mode
✅ Idle timer disabled during display
✅ Tap to show back controls
✅ Bilingual (en + zh-Hans)

---

## v1.1 Features (Complete)

✅ ShakeDetector (double-shake to toggle flash)
✅ FlashOverlay (gentle 2.5s pulse, not strobe)
✅ First-use shake hint
✅ Siri App Intent ("Hey Siri, big text I'm here")

**All source code for v1.0 and v1.1 is complete and ready for Xcode setup.**

---

## App Store Submission Checklist (v1.0)

### Pre-submission
- [ ] Real device tested (caught all obvious bugs)
- [ ] Screenshots prepared (6.9" + 6.5" or 6.7")
- [ ] App Icon final (1024×1024)
- [ ] Bundle ID finalized (cannot change after submission)

### App Store Connect
- [ ] App name reserved (free, 180-day hold)
- [ ] Create app record
- [ ] Privacy Nutrition: "Data Not Collected" (all ~30 questions)
- [ ] Age Rating: 4+
- [ ] Pricing: Free
- [ ] Availability: US + China (or more)
- [ ] Metadata in en + zh-Hans:
  - Title: "Big Text" / "大字"
  - Subtitle: "Type one line. Show it big." / "输入一句话，全屏放大给别人看。"
  - Description, Keywords, Promo Text
- [ ] Screenshots uploaded

### Submission
- [ ] Archive in Xcode (Product → Archive)
- [ ] Distribute to App Store
- [ ] Wait for TestFlight processing
- [ ] Install from TestFlight → smoke test again
- [ ] Submit for Review
- [ ] Wait 1-3 days (plan for one rejection round-trip)

---

## Common Issues

### "No such module 'UIKit'"
- This is expected when viewing files outside Xcode
- Will resolve once added to Xcode project

### Build fails with missing files
- Ensure all `.swift` files are added to target
- Check "Target Membership" in File Inspector (⌥⌘1)

### Localization not working
- Ensure `Localizable.xcstrings` is added to project
- Verify "Localizable String Catalog" is selected in File Inspector

### Portrait/landscape not working as expected
- v1.0 uses portrait-with-hint approach (simpler)
- Force-landscape deferred to v1.1 if needed

---

## Next Steps

1. **Set up Xcode project** (Steps 1-5 above)
2. **Test v1.0 and v1.1 on real device**
3. **Ship v1.0 to App Store** (minimal, fast approval)
4. **Use the app in real life** — concert, airport pickup, noisy bar
5. **Ship v1.1 update** with shake-flash + Siri

**Both v1.0 and v1.1 source code are complete.** The two-ship strategy lets you learn the App Store pipeline twice.

---

## Resources

- Design spec: `docs/research/initial-design.md`
- Plan review: `~/.gstack/projects/big-text/xuewen-unknown-design-20260425-201328.md`
- Apple Developer Documentation: [developer.apple.com](https://developer.apple.com)

---

**Remember:** The goal is learning + shipping + ownership. v1.0 should be small enough to actually finish. 🚀
