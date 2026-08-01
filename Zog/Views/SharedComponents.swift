import SwiftUI
import AppKit

/// Shared hover-aware pill wrapper used by every menu-bar island.
struct IslandContainer<Content: View>: View {
    var height: CGFloat = ZogTheme.islandHeight
    var cornerRadius: CGFloat = ZogTheme.islandRadius
    @ViewBuilder var content: () -> Content

    @State private var isHovered = false

    var body: some View {
        content()
            .islandChrome(height: height, isHovered: isHovered, cornerRadius: cornerRadius)
            .onHover { hovering in
                withAnimation(ZogTheme.hoverSpring) {
                    isHovered = hovering
                }
            }
    }
}

/// Tiny circular indicator used in the vertical dock / workspace row.
struct DotIndicator: View {
    var color: Color
    var size: CGFloat = 8
    var isActive: Bool = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(isActive ? 1 : 0.45)
            .scaleEffect(isActive ? 1.15 : 1)
            .animation(ZogTheme.hoverSpring, value: isActive)
    }
}

struct SFIcon: View {
    let systemName: String
    var size: CGFloat = 13
    var color: Color = ZogTheme.foreground

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(color)
            .symbolRenderingMode(.hierarchical)
    }
}

struct AppIconView: View {
    let image: NSImage?
    var size: CGFloat = 18

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: ZogTheme.iconRadius, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: ZogTheme.iconRadius, style: .continuous)
                    .fill(ZogTheme.foregroundDim)
                    .frame(width: size, height: size)
            }
        }
    }
}
