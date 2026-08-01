import SwiftUI
import AppKit

struct IslandContainer<Content: View>: View {
    var height: CGFloat = ZogTheme.islandHeight
    var cornerRadius: CGFloat = ZogTheme.islandRadius
    var compact: Bool = false
    @ViewBuilder var content: () -> Content

    @State private var isHovered = false

    var body: some View {
        content()
            .islandChrome(
                height: height,
                isHovered: isHovered,
                cornerRadius: cornerRadius,
                compact: compact
            )
            .onHover { hovering in
                withAnimation(ZogTheme.hoverSpring) { isHovered = hovering }
            }
    }
}

struct DotIndicator: View {
    var color: Color
    var size: CGFloat = 7
    var isActive: Bool = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
            .opacity(isActive ? 1 : 0.4)
            .scaleEffect(isActive ? 1.1 : 1)
    }
}

struct SFIcon: View {
    let systemName: String
    var size: CGFloat = 12
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
    var size: CGFloat = 16

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            } else {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(ZogTheme.foregroundDim)
                    .frame(width: size, height: size)
            }
        }
    }
}

// MARK: - Geometric dock primitives (refs 1 & 4)

struct GeoRect: View {
    var width: CGFloat = 14
    var height: CGFloat = 8
    var radius: CGFloat = 2

    var body: some View {
        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(ZogTheme.foreground)
            .frame(width: width, height: height)
    }
}

struct GeoGrid: View {
    var cols: Int = 3
    var rows: Int = 3
    var cell: CGFloat = 2.5
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
    var on: Bool = false

    var body: some View {
        ZStack(alignment: on ? .trailing : .leading) {
            Capsule()
                .stroke(ZogTheme.foreground.opacity(0.85), lineWidth: 1.2)
                .frame(width: 16, height: 9)
            Circle()
                .fill(ZogTheme.foreground)
                .frame(width: 5, height: 5)
                .padding(2)
        }
    }
}

struct GeoBlock: View {
    var size: CGFloat = 14

    var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(ZogTheme.foreground)
            .frame(width: size, height: size)
    }
}

struct CubeMark: View {
    var body: some View {
        // Stylized cube from ref 1 — geometric, not SF Symbol
        ZStack {
            // back face
            Path { p in
                p.move(to: CGPoint(x: 4, y: 2))
                p.addLine(to: CGPoint(x: 12, y: 2))
                p.addLine(to: CGPoint(x: 12, y: 10))
                p.addLine(to: CGPoint(x: 4, y: 10))
                p.closeSubpath()
            }
            .stroke(ZogTheme.foreground, lineWidth: 1.2)

            // front face offset
            Path { p in
                p.move(to: CGPoint(x: 2, y: 5))
                p.addLine(to: CGPoint(x: 10, y: 5))
                p.addLine(to: CGPoint(x: 10, y: 13))
                p.addLine(to: CGPoint(x: 2, y: 13))
                p.closeSubpath()
            }
            .stroke(ZogTheme.foreground, lineWidth: 1.2)

            // connectors
            Path { p in
                p.move(to: CGPoint(x: 4, y: 2)); p.addLine(to: CGPoint(x: 2, y: 5))
                p.move(to: CGPoint(x: 12, y: 2)); p.addLine(to: CGPoint(x: 10, y: 5))
                p.move(to: CGPoint(x: 12, y: 10)); p.addLine(to: CGPoint(x: 10, y: 13))
                p.move(to: CGPoint(x: 4, y: 10)); p.addLine(to: CGPoint(x: 2, y: 13))
            }
            .stroke(ZogTheme.foreground, lineWidth: 1)
        }
        .frame(width: 14, height: 15)
    }
}
