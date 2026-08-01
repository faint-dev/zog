import SwiftUI
import AppKit

// MARK: - Island container

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

// MARK: - Generic atoms

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

// MARK: - Custom status glyphs (match docs/design-preview.html)

/// Battery glyph: a small outlined rect with a fill bar and a tiny nub.
struct BatteryGlyph: View {
    var fillFraction: Double = 1
    var charging: Bool = false

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .stroke(ZogTheme.foregroundGlyph.opacity(0.55), lineWidth: 1.2)
                .frame(width: 16, height: 8)
            Rectangle()
                .fill(ZogTheme.accentGreen)
                .frame(width: max(1.5, 11 * fillFraction), height: 6)
                .clipShape(RoundedRectangle(cornerRadius: 1, style: .continuous))
                .padding(.leading, 1.5)
            Rectangle()
                .fill(ZogTheme.foregroundGlyph.opacity(0.45))
                .frame(width: 1.5, height: 3)
                .offset(x: 8.25)
        }
        .overlay(alignment: .center) {
            if charging {
                SFIcon(systemName: "bolt.fill", size: 5.5, color: .white)
            }
        }
        .frame(width: 16, height: 8)
    }
}

/// Wifi glyph: 3-bar dome (chevrons stacked) clipped to the upper arc.
struct WifiGlyph: View {
    var bars: Int = 3

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .stroke(ZogTheme.foregroundGlyph.opacity(0.85), lineWidth: 1.4)
                    .frame(width: CGFloat(4 + i * 3), height: 1.5)
                    .offset(y: CGFloat(2 - i) * 1.6)
                    .opacity(i < bars ? 1 : 0.25)
            }
            Circle()
                .fill(ZogTheme.foregroundGlyph.opacity(0.85))
                .frame(width: 1.5, height: 1.5)
                .offset(y: 3)
        }
        .frame(width: 12, height: 9)
    }
}

/// Speaker glyph: two stacked triangles on a left vertical bar.
struct SpeakerGlyph: View {
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(ZogTheme.foregroundGlyph.opacity(0.7))
                .frame(width: 1.5, height: 6)
            Triangle()
                .fill(ZogTheme.foregroundGlyph.opacity(0.7))
                .frame(width: 8, height: 8)
                .offset(x: 0.5)
        }
        .frame(width: 10, height: 8)
        .clipShape(Rectangle().offset(y: -1))
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

/// Hand-drawn checkmark inside a circular outline (used for the Mission Control FAB).
struct CheckMarkGlyph: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(ZogTheme.foreground.opacity(0.9), lineWidth: 1.3)
                .frame(width: 15, height: 15)
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addLine(to: CGPoint(x: 4.5, y: 7))
                p.addLine(to: CGPoint(x: 13, y: -5))
            }
            .stroke(ZogTheme.foreground, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
            .frame(width: 15, height: 15)
            .rotationEffect(.degrees(35))
        }
    }
}

// MARK: - Geometric glyphs (dock)

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

/// Four-dot cluster (d-pad style from ref 1).
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

/// Tiny separator dot used in the vertical dock.
struct MicroDot: View {
    var body: some View {
        Circle()
            .fill(ZogTheme.foreground.opacity(0.2))
            .frame(width: 2, height: 2)
    }
}

// MARK: - Circular FAB (moon / check below the dock)

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
