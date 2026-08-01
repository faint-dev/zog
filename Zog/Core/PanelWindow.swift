import AppKit
import SwiftUI

/// Borderless, non-activating floating panel — the building block for
/// SketchyBar-style islands, the vertical dock, and the menu-bar shield.
///
/// `Style.island` is positioned above the native menu bar so the floating
/// islands actually replace it. `Style.shield` is a transparent full-width
/// strip that absorbs mouse events near the top edge so the user can't
/// accidentally summon the hidden native menu bar.
@MainActor
final class PanelWindow<Content: View>: NSPanel {
    private var hostingView: NSHostingView<Content>?

    init(
        rootView: Content,
        size: NSSize,
        style: Style = .island
    ) {
        super.init(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = style.windowLevel
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary,
            .ignoresCycle,
            .fullScreenAuxiliary
        ]
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true
        isExcludedFromWindowsMenu = true
        // HUD-style panels: we drive our own size/position changes and
        // don't want AppKit animating them.
        animationBehavior = .none

        let host = NSHostingView(rootView: rootView)
        host.frame = NSRect(origin: .zero, size: size)
        host.autoresizingMask = [.width, .height]
        contentView = host
        hostingView = host
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    enum Style {
        case island
        case dock
        case shield

        var windowLevel: NSWindow.Level {
            switch self {
            case .island:
                return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 2)
            case .dock:
                return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.dockWindow)) + 1)
            case .shield:
                return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 1)
            }
        }
    }
}

/// Shield panels don't need a hosting view — they're pure mouse-event
/// absorbers backed by an NSView. Free function (rather than a static on
/// the generic `PanelWindow<Content>`) so callers don't have to spell the
/// generic parameter.
@MainActor
func makeShieldPanel(frame: NSRect) -> NSPanel {
    let panel = NSPanel(
        contentRect: frame,
        styleMask: [.borderless, .nonactivatingPanel],
        backing: .buffered,
        defer: false
    )
    panel.isOpaque = false
    panel.backgroundColor = .clear
    panel.hasShadow = false
    // Just above the native menu bar so it intercepts the cursor.
    panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.mainMenuWindow)) + 1)
    panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
    panel.hidesOnDeactivate = false
    panel.becomesKeyOnlyIfNeeded = true
    panel.isExcludedFromWindowsMenu = true
    panel.ignoresMouseEvents = false
    panel.animationBehavior = .none
    let view = NSView(frame: NSRect(origin: .zero, size: frame.size))
    panel.contentView = view
    return panel
}
