import AppKit
import SwiftUI

/// Borderless, non-activating floating panel — the building block for
/// SketchyBar-style islands and the vertical dock.
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

        var windowLevel: NSWindow.Level {
            switch self {
            case .island: return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)) + 1)
            case .dock:   return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.dockWindow)) + 1)
            }
        }
    }
}
