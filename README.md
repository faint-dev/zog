# Zog

Swift/SwiftUI macOS chrome replacement that recreates the floating-island menu bar and geometric vertical dock from the provided reference screenshots, using the same overlay approach as [SketchyBar](https://github.com/FelixKratz/SketchyBar).

## Reference layout (matched)

**Top — discrete floating capsules** (not a continuous bar):

| Position | Content |
|---|---|
| Far left | Apple mark alone in a small near-square pod |
| Left | App icon + name + File / Edit / View / Window / Help |
| Center | Media: artwork · title · artist · ⏮ ▶ ⏭ |
| Right | Envelope · utilities (B / cursor / grid / ▾) · battery+wifi+speaker · clock `dd/MM HH:mm` |

**Right — slim vertical dock** (refs 1 & 4):

- Cube mark + 3×3 dot grid  
- Colored workspace dots (yellow / blue / cyan) with micro dividers  
- Geometric glyphs (rects, 2×2 grid, pill toggle, blocks, globe) — **not** colorful app icons  
- Half-moon appearance + checkmark · minute numeral  

See [`docs/design-preview.html`](docs/design-preview.html) for a static recreation of this layout.

## Build

macOS 14+, Xcode 15+:

```bash
open Zog.xcodeproj
```

Run the **Zog** scheme. Grant Accessibility + Automation when prompted. Optional: [yabai](https://github.com/koekeishiya/yabai) for live Spaces.

On launch Zog autohides the native Dock / menu bar; quitting restores prior Dock settings.

## Stack

- Borderless `NSPanel` overlays at status/dock window levels  
- SwiftUI island views + AppKit layout  
- Services: clock, battery (IOKit), Wi‑Fi (CoreWLAN), Now Playing (MediaRemote), workspaces (yabai), apps  
