import AppKit

enum ScreenLayout {
    static var mainScreen: NSScreen {
        NSScreen.main ?? NSScreen.screens[0]
    }

    /// Visible frame already excludes the native menu bar when present.
    /// We intentionally use the full frame and apply our own insets so islands
    /// float below the notch with a consistent margin (matches references).
    static func contentFrame(for screen: NSScreen = mainScreen) -> NSRect {
        screen.frame
    }

    static func topLeading(x: CGFloat, width: CGFloat, height: CGFloat, screen: NSScreen = mainScreen) -> NSRect {
        let frame = contentFrame(for: screen)
        let inset = ZogTheme.screenInset
        let y = frame.maxY - inset - height
        return NSRect(x: frame.minX + inset + x, y: y, width: width, height: height)
    }

    static func topTrailing(width: CGFloat, height: CGFloat, trailingOffset: CGFloat = 0, screen: NSScreen = mainScreen) -> NSRect {
        let frame = contentFrame(for: screen)
        let inset = ZogTheme.screenInset
        let y = frame.maxY - inset - height
        let x = frame.maxX - inset - width - trailingOffset
        return NSRect(x: x, y: y, width: width, height: height)
    }

    static func topCenter(width: CGFloat, height: CGFloat, screen: NSScreen = mainScreen) -> NSRect {
        let frame = contentFrame(for: screen)
        let inset = ZogTheme.screenInset
        let y = frame.maxY - inset - height
        let x = frame.midX - width / 2
        return NSRect(x: x, y: y, width: width, height: height)
    }

    /// Vertical dock along the right edge, vertically centered.
    static func rightDock(width: CGFloat, height: CGFloat, screen: NSScreen = mainScreen) -> NSRect {
        let frame = contentFrame(for: screen)
        let inset = ZogTheme.screenInset
        let x = frame.maxX - inset - width
        let y = frame.midY - height / 2
        return NSRect(x: x, y: y, width: width, height: height)
    }

    /// Approximate notch avoidance for notched MacBooks.
    static var notchSafeLeadingInset: CGFloat {
        let screen = mainScreen
        // If the visible frame is inset from the full frame on the top-left,
        // treat that as notch / camera housing clearance.
        let full = screen.frame
        let visible = screen.visibleFrame
        let topGap = full.maxY - visible.maxY
        if topGap > 24 {
            return max(ZogTheme.screenInset, (full.width - visible.width) / 2 + 8)
        }
        return ZogTheme.screenInset
    }

    /// Horizontal space reserved for the vertical dock so the right-side island
    /// cluster doesn't slide under it.
    static var dockClearance: CGFloat {
        ZogTheme.dockWidth + ZogTheme.screenInset
    }
}
