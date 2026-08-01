import AppKit
import SwiftUI

/// Borderless, non-activating floating panel — the building block for
/// SketchyBar-style islands and the vertical dock.
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
        animationBehavior = .utilityWindow

        let host = NSHostingView(rootView: rootView)
        host.frame = NSRect(origin: .zero, size: size)
        host.autoresizingMask = [.width, .height]
        contentView = host
        hostingView = host
    }

    func setRootView(_ view: Content) {
        hostingView?.rootView = view
    }

    func resize(to size: NSSize, anchor: Anchor = .topLeft) {
        var frame = self.frame
        switch anchor {
        case .topLeft:
            frame.origin.y += frame.size.height - size.height
        case .topRight:
            frame.origin.x += frame.size.width - size.width
            frame.origin.y += frame.size.height - size.height
        case .bottomRight:
            frame.origin.x += frame.size.width - size.width
        case .center:
            frame.origin.x += (frame.size.width - size.width) / 2
            frame.origin.y += (frame.size.height - size.height) / 2
        }
        frame.size = size
        setFrame(frame, display: true)
        hostingView?.frame = NSRect(origin: .zero, size: size)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    enum Style {
        case island
        case dock

        var windowLevel: NSWindow.Level {
            switch self {
            case .island: return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.statusWindow)) + 1)
            case .dock: return NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.dockWindow)) + 1)
            }
        }
    }

    enum Anchor {
        case topLeft, topRight, bottomRight, center
    }
}
