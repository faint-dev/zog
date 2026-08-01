import AppKit
import SwiftUI

/// Vertical dock replacement: pinned apps + running apps + workspace dots.
/// Moon / check FABs live in separate circular panels managed by `DockController`.
struct VerticalDockView: View {
    @ObservedObject var workspaces: WorkspaceService
    @ObservedObject var dockApps: DockAppsService

    /// Caps so the dock never outgrows the screen.
    private let maxPinned = 6
    private let maxRunning = 8
    private let shownSpaces = 3

    var body: some View {
        VStack(spacing: 6) {
            // Pinned apps (always shown if installed on the system)
            appsSection(
                title: nil,
                apps: dockApps.pinned.prefix(maxPinned).map { $0 }
            )

            if !runningApps.isEmpty {
                dockSeparator
                appsSection(title: nil, apps: runningApps)
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
    private func appsSection(title: String?, apps: [DockAppsService.DockApp]) -> some View {
        VStack(spacing: 6) {
            ForEach(apps, id: \.id) { app in
                DockAppButton(app: app) { dockApps.launchOrActivate(app) }
            }
        }
    }

    private var runningApps: [DockAppsService.DockApp] {
        let pinnedIDs = Set(dockApps.pinned.map(\.id))
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

// MARK: - Single dock-app button

private struct DockAppButton: View {
    let app: DockAppsService.DockApp
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
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
    }
}

// MARK: - Circular action buttons (separate from dock — moon / check)

struct DockMoonButton: View {
    var body: some View {
        Button(action: toggleDarkAppearance) {
            CircularFAB {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ZogTheme.foreground, ZogTheme.foreground.opacity(0)],
                            startPoint: .leading,
                            endPoint: UnitPoint(x: 0.55, y: 0.5)
                        )
                    )
                    .frame(width: 14, height: 14)
            }
        }
        .buttonStyle(.plain)
        .help("Appearance")
    }

    private func toggleDarkAppearance() {
        let script = """
        tell application "System Events"
            tell appearance preferences
                set dark mode to not dark mode
            end tell
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
    }
}

struct DockCheckButton: View {
    var body: some View {
        Button(action: openMissionControl) {
            CircularFAB {
                CheckMarkGlyph()
            }
        }
        .buttonStyle(.plain)
        .help("Mission Control")
    }

    private func openMissionControl() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "Mission Control"]
        try? task.run()
    }
}
