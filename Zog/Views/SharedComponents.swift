import SwiftUI
import AppKit

struct IslandContainer<Content: View>: View {
    var height: CGFloat = ZogTheme.islandHeight
    var cornerRadius: CGFloat = ZogTheme.islandRadius
    var compact: Bool = false
    var fill: Color = ZogTheme.islandFill
    @ViewBuilder var content: () -> Content

    @State private var isHovered = false

    var body: some View {
        content()
            .islandChrome(
                height: height,
                isHovered: isHovered,
                cornerRadius: cornerRadius,
                compact: compact,
                fill: fill
            )
            .onHover { hovering in
                withAnimation(ZogTheme.hoverSpring) { isHovered = hovering }
            }
    }
}

struct DotIndicator: View {
    var color: Color
    var size: CGFloat = 6
    var isActive: Bool = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(isActive ? 1 : 0.35)
    }
}

struct SFIcon: View {
    let systemName: String
    var size: CGFloat = 11
    var color: Color = ZogTheme.foreground

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(color)
            .symbolRenderingMode(.monochrome)
    }
}

struct AppIconView: View {
    let image: NSImage?
    var size: CGFloat = 14

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 3.5, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 3.5, style: .continuous)
                    .fill(ZogTheme.foregroundDim)
                    .frame(width: size, height: size)
            }
        }
    }
}

// MARK: Geometric glyphs

struct GeoRect: View {
    var width: CGFloat = 11
    var height: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(ZogTheme.foreground)
            .frame(width: width, height: height)
    }
}

struct GeoGrid: View {
    var cols: Int = 3
    var rows: Int = 3
    var cell: CGFloat = 2
    var gap: CGFloat = 2

    var body: some View {
        VStack(spacing: gap) {
            ForEach(0..<rows, id: \.self) { _ in
                HStack(spacing: gap) {
                    ForEach(0..<cols, id: \.self) { _ in
                        Circle().fill(ZogTheme.foreground).frame(width: cell, height: cell)
                    }
                }
            }
        }
    }
}

struct GeoPillToggle: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .stroke(ZogTheme.foreground.opacity(0.9), lineWidth: 1.15)
                .frame(width: 14, height: 8)
            Circle()
                .fill(ZogTheme.foreground)
                .frame(width: 4, height: 4)
                .padding(2)
        }
    }
}

struct GeoBlock: View {
    var size: CGFloat = 11
    var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2.5, style: .continuous)
            .fill(ZogTheme.foreground.opacity(opacity))
            .frame(width: size, height: size)
    }
}

/// Four-dot cluster (d-pad style from reference 1).
struct GeoCluster: View {
    var body: some View {
        VStack(spacing: 2.5) {
            HStack(spacing: 2.5) {
                Circle().fill(ZogTheme.foreground).frame(width: 3, height: 3)
                Circle().fill(ZogTheme.foreground).frame(width: 3, height: 3)
            }
            HStack(spacing: 2.5) {
                Circle().fill(ZogTheme.foreground).frame(width: 3, height: 3)
                Circle().fill(ZogTheme.foreground).frame(width: 3, height: 3)
            }
        }
    }
}

struct CubeMark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height
            var hex = Path()
            hex.move(to: CGPoint(x: w * 0.5, y: 1))
            hex.addLine(to: CGPoint(x: w - 1, y: h * 0.28))
            hex.addLine(to: CGPoint(x: w - 1, y: h * 0.72))
            hex.addLine(to: CGPoint(x: w * 0.5, y: h - 1))
            hex.addLine(to: CGPoint(x: 1, y: h * 0.72))
            hex.addLine(to: CGPoint(x: 1, y: h * 0.28))
            hex.closeSubpath()

            context.stroke(hex, with: .color(ZogTheme.foreground), lineWidth: 1.15)

            var mid = Path()
            mid.move(to: CGPoint(x: w * 0.5, y: 1))
            mid.addLine(to: CGPoint(x: w * 0.5, y: h * 0.5))
            mid.move(to: CGPoint(x: 1, y: h * 0.28))
            mid.addLine(to: CGPoint(x: w * 0.5, y: h * 0.5))
            mid.addLine(to: CGPoint(x: w - 1, y: h * 0.28))
            context.stroke(mid, with: .color(ZogTheme.foreground), lineWidth: 1.0)
        }
        .frame(width: 13, height: 14)
    }
}

/// Circular glass FAB used for moon / check below the dock.
struct CircularFAB<Content: View>: View {
    @ViewBuilder var content: () -> Content
    @State private var isHovered = false

    var body: some View {
        content()
            .frame(width: ZogTheme.fabSize, height: ZogTheme.fabSize)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .background(Circle().fill(ZogTheme.dockFill))
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(isHovered ? 0.2 : 0.10), lineWidth: 0.5)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
            )
            .onHover { hovering in
                withAnimation(ZogTheme.hoverSpring) { isHovered = hovering }
            }
    }
}
