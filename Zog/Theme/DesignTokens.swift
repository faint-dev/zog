import AppKit
import SwiftUI

/// Tokens taken directly from the reference screenshots:
/// dark translucent capsules, ~12pt bezel inset, geometric dock glyphs.
enum ZogTheme {
    // Surfaces — near-black translucent (refs ≈ #1A1A1A)
    static let islandFill = Color(nsColor: NSColor(calibratedWhite: 0.09, alpha: 0.82))
    static let dockFill = Color(nsColor: NSColor(calibratedWhite: 0.05, alpha: 0.94))
    static let islandBorder = Color.white.opacity(0.06)
    static let islandBorderHover = Color.white.opacity(0.18)

    static let foreground = Color.white.opacity(0.95)
    static let foregroundMuted = Color.white.opacity(0.55)
    static let foregroundDim = Color.white.opacity(0.28)

    // Accents from refs: battery green, workspace yellow/blue/cyan
    static let accentGreen = Color(red: 0.32, green: 0.82, blue: 0.42)
    static let workspaceYellow = Color(red: 0.96, green: 0.80, blue: 0.30)
    static let workspaceBlue = Color(red: 0.38, green: 0.62, blue: 0.98)
    static let workspaceCyan = Color(red: 0.48, green: 0.86, blue: 0.96)

    // Geometry — continuous rounded pods, not sharp cards
    static let islandRadius: CGFloat = 12
    static let appleIslandRadius: CGFloat = 10
    static let mediaRadius: CGFloat = 14
    static let dockRadius: CGFloat = 22

    static let islandHeight: CGFloat = 30
    static let mediaIslandHeight: CGFloat = 42
    /// Slim vertical dock from refs (~40–48pt)
    static let dockWidth: CGFloat = 44

    static let screenInset: CGFloat = 14
    static let islandGap: CGFloat = 6
    static let islandPaddingH: CGFloat = 11
    static let islandPaddingV: CGFloat = 5

    static let clockFont = Font.system(size: 12, weight: .medium, design: .monospaced)
    static let menuFont = Font.system(size: 13, weight: .regular)
    static let titleFont = Font.system(size: 13, weight: .semibold)
    static let subtitleFont = Font.system(size: 11, weight: .regular)
    static let appNameFont = Font.system(size: 13, weight: .medium)

    static let hoverSpring = Animation.spring(response: 0.26, dampingFraction: 0.82)
    static let appearEase = Animation.easeOut(duration: 0.3)
}

struct IslandBackground: ViewModifier {
    var height: CGFloat = ZogTheme.islandHeight
    var isHovered: Bool = false
    var cornerRadius: CGFloat = ZogTheme.islandRadius
    var compact: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, compact ? 9 : ZogTheme.islandPaddingH)
            .padding(.vertical, ZogTheme.islandPaddingV)
            .frame(minHeight: height)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(ZogTheme.islandFill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                isHovered ? ZogTheme.islandBorderHover : ZogTheme.islandBorder,
                                lineWidth: 0.5
                            )
                    )
            )
            .animation(ZogTheme.hoverSpring, value: isHovered)
    }
}

extension View {
    func islandChrome(
        height: CGFloat = ZogTheme.islandHeight,
        isHovered: Bool = false,
        cornerRadius: CGFloat = ZogTheme.islandRadius,
        compact: Bool = false
    ) -> some View {
        modifier(IslandBackground(
            height: height,
            isHovered: isHovered,
            cornerRadius: cornerRadius,
            compact: compact
        ))
    }
}
