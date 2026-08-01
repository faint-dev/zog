import AppKit
import SwiftUI

/// Tokens tuned to the reference photos: soft glass capsules,
/// slim geometric dock, separate circular action buttons below.
enum ZogTheme {
    static let islandFill = Color(nsColor: NSColor(calibratedWhite: 0.11, alpha: 0.72))
    static let dockFill = Color(nsColor: NSColor(calibratedWhite: 0.08, alpha: 0.82))
    static let islandBorder = Color.white.opacity(0.10)
    static let islandBorderHover = Color.white.opacity(0.20)

    static let foreground = Color.white.opacity(0.94)
    static let foregroundMuted = Color.white.opacity(0.50)
    static let foregroundDim = Color.white.opacity(0.28)

    static let accentGreen = Color(red: 0.24, green: 0.81, blue: 0.36)
    static let workspaceYellow = Color(red: 0.94, green: 0.75, blue: 0.26)
    static let workspaceBlue = Color(red: 0.36, green: 0.61, blue: 0.97)
    static let workspaceCyan = Color(red: 0.45, green: 0.84, blue: 0.94)

    static let islandRadius: CGFloat = 14
    static let appleIslandRadius: CGFloat = 10
    static let mediaRadius: CGFloat = 16
    static let dockRadius: CGFloat = 20
    static let fabSize: CGFloat = 36

    static let islandHeight: CGFloat = 28
    static let mediaIslandHeight: CGFloat = 40
    static let dockWidth: CGFloat = 40

    static let screenInset: CGFloat = 14
    static let islandGap: CGFloat = 6
    static let islandPaddingH: CGFloat = 12
    static let islandPaddingV: CGFloat = 4
    static let fabGap: CGFloat = 8

    static let clockFont = Font.system(size: 11.5, weight: .medium, design: .monospaced)
    static let menuFont = Font.system(size: 12.5, weight: .regular)
    static let titleFont = Font.system(size: 12, weight: .semibold)
    static let subtitleFont = Font.system(size: 10, weight: .regular)
    static let appNameFont = Font.system(size: 12.5, weight: .medium)

    static let hoverSpring = Animation.spring(response: 0.28, dampingFraction: 0.84)
    static let appearEase = Animation.easeOut(duration: 0.28)
}

struct IslandBackground: ViewModifier {
    var height: CGFloat = ZogTheme.islandHeight
    var isHovered: Bool = false
    var cornerRadius: CGFloat = ZogTheme.islandRadius
    var compact: Bool = false
    var fill: Color = ZogTheme.islandFill

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, compact ? 8 : ZogTheme.islandPaddingH)
            .padding(.vertical, ZogTheme.islandPaddingV)
            .frame(minHeight: height)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(fill)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(isHovered ? 0.22 : 0.12),
                                        Color.white.opacity(0.04)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 0.5
                            )
                    )
                    .shadow(color: .black.opacity(0.18), radius: 10, y: 4)
            )
            .animation(ZogTheme.hoverSpring, value: isHovered)
    }
}

extension View {
    func islandChrome(
        height: CGFloat = ZogTheme.islandHeight,
        isHovered: Bool = false,
        cornerRadius: CGFloat = ZogTheme.islandRadius,
        compact: Bool = false,
        fill: Color = ZogTheme.islandFill
    ) -> some View {
        modifier(IslandBackground(
            height: height,
            isHovered: isHovered,
            cornerRadius: cornerRadius,
            compact: compact,
            fill: fill
        ))
    }
}
