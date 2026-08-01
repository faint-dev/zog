import AppKit
import SwiftUI

/// Visual language distilled from the reference floating-island setups
/// (SketchyBar-style pills + vertical side dock).
enum ZogTheme {
    // MARK: - Surfaces

    /// Deep charcoal translucent island fill (~#1A1A1A @ ~88%).
    static let islandFill = Color(nsColor: NSColor(calibratedWhite: 0.08, alpha: 0.88))
    static let islandFillSolid = Color(nsColor: NSColor(calibratedWhite: 0.10, alpha: 0.96))
    static let islandBorder = Color.white.opacity(0.08)
    static let islandBorderHover = Color.white.opacity(0.22)

    // MARK: - Content

    static let foreground = Color.white.opacity(0.92)
    static let foregroundMuted = Color.white.opacity(0.55)
    static let foregroundDim = Color.white.opacity(0.35)

    // MARK: - Accents (from reference: battery green, workspace dots)

    static let accentGreen = Color(red: 0.35, green: 0.85, blue: 0.45)
    static let workspaceYellow = Color(red: 0.95, green: 0.78, blue: 0.28)
    static let workspaceBlue = Color(red: 0.35, green: 0.62, blue: 0.98)
    static let workspaceCyan = Color(red: 0.45, green: 0.85, blue: 0.95)

    // MARK: - Geometry

    /// High corner radii → capsule / pill look from the references.
    static let islandRadius: CGFloat = 14
    static let dockRadius: CGFloat = 18
    static let iconRadius: CGFloat = 6

    static let islandHeight: CGFloat = 32
    static let mediaIslandHeight: CGFloat = 44
    static let dockWidth: CGFloat = 52

    /// Clear margin from screen bezel (≈10–16pt in the photos).
    static let screenInset: CGFloat = 12
    static let islandGap: CGFloat = 8
    static let islandPaddingH: CGFloat = 12
    static let islandPaddingV: CGFloat = 6

    // MARK: - Typography

    static let clockFont = Font.system(size: 12, weight: .medium, design: .monospaced)
    static let labelFont = Font.system(size: 13, weight: .medium, design: .default)
    static let menuFont = Font.system(size: 13, weight: .regular, design: .default)
    static let titleFont = Font.system(size: 13, weight: .semibold, design: .default)
    static let subtitleFont = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: - Motion

    static let hoverSpring = Animation.spring(response: 0.28, dampingFraction: 0.78)
    static let appearEase = Animation.easeOut(duration: 0.35)
}

// MARK: - Shared island chrome

struct IslandBackground: ViewModifier {
    var height: CGFloat = ZogTheme.islandHeight
    var isHovered: Bool = false
    var cornerRadius: CGFloat = ZogTheme.islandRadius

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, ZogTheme.islandPaddingH)
            .padding(.vertical, ZogTheme.islandPaddingV)
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
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(isHovered ? 0.35 : 0.22), radius: isHovered ? 12 : 8, y: 2)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .offset(y: isHovered ? -1 : 0)
            .animation(ZogTheme.hoverSpring, value: isHovered)
    }
}

extension View {
    func islandChrome(
        height: CGFloat = ZogTheme.islandHeight,
        isHovered: Bool = false,
        cornerRadius: CGFloat = ZogTheme.islandRadius
    ) -> some View {
        modifier(IslandBackground(height: height, isHovered: isHovered, cornerRadius: cornerRadius))
    }
}
