import AppKit
import SwiftUI

/// Main vertical dock pill — geometric glyphs only (refs 1 & 4).
/// Moon / check live in separate circular panels managed by `DockController`.
struct VerticalDockView: View {
    @ObservedObject var workspaces: WorkspaceService
    @ObservedObject var dockApps: DockAppsService

    private let shownSpaces = 3

    var body: some View {
        VStack(spacing: 0) {
            // Header: cube + 3x3 grid + separator
            VStack(spacing: 11) {
                Button(action: openLaunchpad) { CubeMark() }
                    .buttonStyle(.plain)
                    .help("Launchpad")

                Button(action: openLaunchpad) {
                    GeoGrid(cols: 3, rows: 3, cell: 2, gap: 2)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 13)

            MicroDot().padding(.vertical, 9)

            // Two four-dot clusters (ref 1)
            VStack(spacing: 8) {
                GeoCluster()
                GeoCluster()
            }

            MicroDot().padding(.vertical, 5)

            // Workspace dots, each separated by a tiny micro-dot (ref 1)
            VStack(spacing: 5) {
                ForEach(Array(workspaces.spaces.prefix(shownSpaces).enumerated()), id: \.element.id) { index, space in
                    Button { workspaces.focus(space: space.id) } label: {
                        DotIndicator(
                            color: color(for: space),
                            size: space.isFocused ? 6.5 : 5.5,
                            isActive: space.isFocused || space.hasWindows
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Desktop \(space.id)")

                    if index < min(workspaces.spaces.count, shownSpaces) - 1 {
                        MicroDot()
                    }
                }
            }

            MicroDot().padding(.vertical, 9)

            // Geometric glyphs (ref 4) — wired to apps
            VStack(spacing: 10) {
                Button { activate("com.apple.finder") } label: { GeoRect() }
                    .buttonStyle(.plain).help("Finder")

                Button { openLaunchpad() } label: {
                    GeoGrid(cols: 2, rows: 2, cell: 2.5, gap: 2)
                }
                .buttonStyle(.plain).help("Apps")

                GeoPillToggle()

                ForEach(Array(dockApps.apps.filter(\.isRunning).prefix(2).enumerated()), id: \.element.id) { _, app in
                    Button { dockApps.launchOrActivate(app) } label: {
                        GeoBlock(opacity: app.isFrontmost ? 1 : 0.55)
                    }
                    .buttonStyle(.plain)
                    .help(app.name)
                }
            }
            .padding(.bottom, 13)
        }
        .frame(width: ZogTheme.dockWidth)
        .background(dockChrome)
    }

    // MARK: Chrome

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

    // MARK: Actions

    private func color(for space: WorkspaceService.Space) -> Color {
        switch workspaces.color(for: space) {
        case .yellow: return ZogTheme.workspaceYellow
        case .blue:   return ZogTheme.workspaceBlue
        case .cyan:   return ZogTheme.foregroundDim
        }
    }

    private func activate(_ bundleID: String) {
        if let app = dockApps.apps.first(where: { $0.id == bundleID }) {
            dockApps.launchOrActivate(app)
        } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        }
    }

    private func openLaunchpad() {
        NSWorkspace.shared.launchApplication("Launchpad")
    }
}

// MARK: - Circular action buttons (separate from dock — ref 1)

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
