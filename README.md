# Zog

Swift/SwiftUI macOS chrome replacement: floating menu-bar islands + a vertical dock, in the style of the reference screenshots / [SketchyBar](https://github.com/FelixKratz/SketchyBar).

## Layout

**Top islands** (replace the system menu bar):

| | |
|---|---|
| Apple pod | System Apple menu |
| App pod | **Currently frontmost app** — icon, name, and that app’s normal menu-bar items (File / Edit / …), read live via Accessibility |
| Media | Now Playing when something is playing |
| Status + clock | Mail / utilities / battery · wifi · volume / `dd/MM HH:mm` |

**Right side** = custom **Dock replacement** (geometric glyphs, workspace dots, circular action buttons below). Not part of the menu bar.

`Cursor Nightly` in the design preview is just an example of whatever app happens to be focused.

## Build

macOS 14+, Xcode 15+:

```bash
open Zog.xcodeproj
```

Run **Zog**. Grant **Accessibility** + **Automation** (needed to read/click the frontmost app’s menus). Optional: [yabai](https://github.com/koekeishiya/yabai) for Spaces.

On launch, native Dock / menu bar are autohidden; quitting restores Dock settings.
