# AGENTS.md

## Cursor Cloud specific instructions

### Platform constraint (read first)

Zog is a **native macOS app** (Swift/SwiftUI + AppKit, plus Apple-only frameworks
`CoreWLAN`, `IOKit`, `SystemConfiguration`, `ApplicationServices`). It has **zero
third-party dependencies** — there is no `Package.swift`, `Podfile`, or `Cartfile`;
everything comes from the Apple SDK. It is built and run exclusively with **Xcode /
`xcodebuild`** on **macOS 14+** (see `README.md` for the exact commands), and CI runs
on `macos-14` (`.github/workflows/build.yml`).

Cursor Cloud Agent VMs are **Linux x86_64**. This app therefore **cannot be built,
run, tested, or lint-checked on the Cloud VM**: there is no `swift`/`xcodebuild`
toolchain, and the required frameworks (AppKit, SwiftUI, CoreWLAN, IOKit, …) are
macOS-only and cannot be installed on Linux. This is a fundamental platform mismatch,
not a missing-dependency problem — do not attempt to install a Swift toolchain to
"fix" it (Linux Swift still lacks these Apple frameworks). There are also no unit/UI
test targets in the project to run.

### What you CAN do on the Linux Cloud VM

- Read, edit, and reason about the Swift sources under `Zog/` and the Xcode project
  (`Zog.xcodeproj/project.pbxproj`).
- Preview the static design mock `docs/design-preview.html` in a browser — it is a
  self-contained HTML/CSS reference of the intended UI (menu-bar "islands" + vertical
  dock) and is the only artifact that renders cross-platform. Serve it with e.g.
  `python3 -m http.server 8099 --directory docs` and open
  `http://localhost:8099/design-preview.html`. Note: this is a design reference, NOT
  the compiled application.

### What requires macOS (cannot be verified on the Cloud VM)

- Build: `xcodebuild -project Zog.xcodeproj -scheme Zog -configuration Debug build`
- Run: open the built `Zog.app` (or `open Zog.xcodeproj` and Run in Xcode). At runtime
  the app autohides the native Dock/menu bar and needs **Accessibility** + **Automation**
  permissions to read/click the frontmost app's menus.
- Any compile/lint feedback on the Swift code. Validate Swift changes via the macOS CI
  workflow (or a local macOS machine); the Linux VM cannot surface Swift build errors.

### No update/setup script is needed

There is nothing to install on Linux for this repo (no package manifests, no
dependencies). The Cloud environment update script is intentionally a no-op.
