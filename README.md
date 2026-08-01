# Zog

A Swift/SwiftUI **macOS chrome replacement** — floating menu-bar islands and a vertical side dock — inspired by [SketchyBar](https://github.com/FelixKratz/SketchyBar) and the modular “pill / island” setups in the design references.

Zog does not wrap SketchyBar’s C binary. It reimplements the same *idea* (replace the system menu bar + dock with custom floating UI) as a native AppKit/`NSPanel` + SwiftUI app.

## Design

| Element | Behavior |
|---|---|
| **Apple island** | Far-left capsule with the Apple mark |
| **App menu island** | Frontmost app icon + name + File/Edit/View/Window/Help |
| **Media island** | Centered Now Playing (artwork, title, artist, transport) |
| **Status cluster** | Mail · utilities · battery (green) · Wi‑Fi · volume |
| **Clock island** | Monospaced `dd/MM HH:mm` |
| **Vertical dock** | Right-edge capsule: brand, workspace dots, apps, appearance |

Visual language matches the references: dark translucent material, high corner radii, ~12pt screen inset, discrete floating pods instead of a continuous bar.

## Architecture

```
Zog/
├── App/            Entry + AppDelegate (accessory policy, chrome hide)
├── Theme/          Design tokens (colors, radii, motion)
├── Core/           PanelWindow, ScreenLayout, SystemChrome
├── MenuBar/        MenuBarController + island views
├── Dock/           VerticalDockView + DockController
├── Services/       Clock, battery, Wi‑Fi, media, workspaces, apps
└── Views/          Shared island chrome + Settings
```

Overlays use borderless `NSPanel`s at status/dock window levels so they float above normal windows, join all Spaces, and stay non-activating.

## Requirements

- macOS 14+
- Xcode 15+
- Accessibility / Automation permission (for menu clicks & appearance toggle)
- Optional: [yabai](https://github.com/koekeishiya/yabai) for live workspace switching

## Build & run

```bash
open Zog.xcodeproj
```

Select the **Zog** scheme → Run.

Or from the CLI:

```bash
xcodebuild -scheme Zog -configuration Debug build
open ~/Library/Developer/Xcode/DerivedData/Zog-*/Build/Products/Debug/Zog.app
```

A static layout mock of the floating islands lives in [`docs/design-preview.html`](docs/design-preview.html).

On launch Zog:

1. Sets activation policy to `.accessory` (no Dock icon for itself)
2. Autohides the native Dock and requests menu-bar auto-hide
3. Shows the floating islands + vertical dock

Quitting restores the previous Dock autohide settings.

## SketchyBar mapping

| SketchyBar concept | Zog equivalent |
|---|---|
| Transparent bar + brackets | Separate `NSPanel` islands |
| `--bar position / margin / y_offset` | `ScreenLayout` + `ZogTheme.screenInset` |
| Items / plugins (scripts) | Swift `*Service` classes |
| `background.corner_radius` | `ZogTheme.islandRadius` / capsule chrome |
| Vertical bar (experimental) | First-class `VerticalDockView` |
| Events / subscribe | Combine + `NSWorkspace` notifications |

## Permissions

Grant in **System Settings → Privacy & Security**:

- **Accessibility** — menu triggering, chrome control  
- **Automation** — System Events AppleScript  
- **Files and Folders** (if prompted)

Media artwork uses the private **MediaRemote** framework (same approach as many SketchyBar media plugins).

## License

See the repository root `LICENSE`. SketchyBar itself is a separate project by Felix Kratz — Zog is an independent Swift reimplementation of the floating-chrome idea.
