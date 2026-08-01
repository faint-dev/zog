import AppKit
import SwiftUI

/// Vertical dock replacement: pinned apps + running apps + workspace dots.
struct VerticalDockView: View {
    @ObservedObject var workspaces: WorkspaceService
    @ObservedObject var dockApps: DockAppsService

    /// Caps so the dock never outgrows the screen.
    private let maxPinned = 8
    private let maxRunning = 8
    private let shownSpaces = 3

    var body: some View {
        VStack(spacing: 6) {
            // Pinned apps
            appsSection(apps: dockApps.pinned.prefix(maxPinned).map { $0 })

            if !runningApps.isEmpty {
                dockSeparator
                appsSection(apps: runningApps)
            }

            dockSeparator

            // Workspace dots
            HStack(spacing: 5) {
                ForEach(Array(workspaces.spaces.prefix(shownSpaces).enumerated()), id: \.element.id) { _, space in
                    Button { workspaces.focus(space: space.id) } label: {
                        Circle()
                            .fill(color(for: space))
                            .frame(width: space.isFocused ? 7 : 5.5, height: space.isFocused ? 7 : 5.5)
                            .opacity(space.isFocused || space.hasWindows ? 1 : 0.35)
                    }
                    .buttonStyle(.plain)
                    .help("Desktop \(space.id)")
                }
            }
        }
        .padding(.vertical, 10)
        .frame(width: ZogTheme.dockWidth)
        .background(dockChrome)
    }

    // MARK: - App sections

    @ViewBuilder
    private func appsSection(apps: [DockAppsService.DockApp]) -> some View {
        VStack(spacing: 6) {
            ForEach(apps, id: \.id) { app in
                DockAppButton(
                    app: app,
                    isPinned: dockApps.pinnedBundleIDs.contains(app.id),
                    onLaunch: { dockApps.launchOrActivate(app) },
                    onTogglePin: { dockApps.togglePin(app.id) },
                    onQuit: { dockApps.quit(app) },
                    onShowInFinder: { dockApps.showInFinder(app) },
                    onHide: { dockApps.hide(app) }
                )
            }
        }
    }

    private var runningApps: [DockAppsService.DockApp] {
        let pinnedIDs = Set(dockApps.pinnedBundleIDs)
        return dockApps.apps
            .filter { $0.isRunning && !pinnedIDs.contains($0.id) }
            .prefix(maxRunning)
            .map { $0 }
    }

    private var dockSeparator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: ZogTheme.dockWidth - 20, height: 0.5)
            .padding(.vertical, 2)
    }

    // MARK: - Chrome

    private var dockChrome: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .environment(\.colorScheme, .dark)
            .background(Capsule(style: .continuous).fill(ZogTheme.dockFill))
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.22), radius: 14, y: 4)
    }

    // MARK: - Actions

    private func color(for space: WorkspaceService.Space) -> Color {
        switch workspaces.color(for: space) {
        case .yellow: return ZogTheme.workspaceYellow
        case .blue:   return ZogTheme.workspaceBlue
        case .cyan:   return ZogTheme.foregroundDim
        }
    }
}

// MARK: - Single dock-app button (with right-click menu)

private struct DockAppButton: View {
    let app: DockAppsService.DockApp
    let isPinned: Bool
    let onLaunch: () -> Void
    let onTogglePin: () -> Void
    let onQuit: () -> Void
    let onShowInFinder: () -> Void
    let onHide: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onLaunch) {
            ZStack(alignment: .bottom) {
                AppIconView(image: app.icon, size: 24)
                    .opacity(app.isRunning ? 1 : 0.55)
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(Color.white.opacity(isHovered ? 0.12 : 0))
                    )
                    .scaleEffect(isHovered ? 1.08 : 1)

                // Focused-app indicator dot
                if app.isFrontmost {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 3, height: 3)
                        .offset(y: 1)
                } else if app.isRunning {
                    Circle()
                        .fill(Color.white.opacity(0.55))
                        .frame(width: 2.5, height: 2.5)
                        .offset(y: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .help(app.name)
        .onHover { hovering in
            withAnimation(ZogTheme.hoverSpring) { isHovered = hovering }
        }
        .contextMenu {
            Button(isPinned ? "Unpin from Dock" : "Pin to Dock") {
                onTogglePin()
            }
            Divider()
            Button("Open") { onLaunch() }
            if app.isRunning {
                Button("Hide \(app.name)") { onHide() }
                Divider()
                Button("Quit \(app.name)", role: .destructive) { onQuit() }
            }
            Divider()
            Button("Show in Finder") { onShowInFinder() }
        }
    }
}
