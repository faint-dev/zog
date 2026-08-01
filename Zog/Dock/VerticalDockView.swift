import AppKit
import SwiftUI

/// Vertical floating dock — slim pill on the right edge with logo,
/// workspace dots, app icons, and utility controls (references 1 & 4).
struct VerticalDockView: View {
    @ObservedObject var workspaces: WorkspaceService
    @ObservedObject var dockApps: DockAppsService

    var body: some View {
        VStack(spacing: 14) {
            header
            Divider().overlay(ZogTheme.foregroundDim).padding(.horizontal, 10)
            workspaceRow
            Divider().overlay(ZogTheme.foregroundDim).padding(.horizontal, 10)
            appsColumn
            Spacer(minLength: 8)
            footer
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 10)
        .frame(width: ZogTheme.dockWidth)
        .background(dockChrome)
    }

    // MARK: Sections

    private var header: some View {
        VStack(spacing: 10) {
            // Stylized cube / brand mark
            Image(systemName: "cube.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(ZogTheme.foreground)

            // 3×3 grid affordance (launcher)
            Image(systemName: "circle.grid.3x3.fill")
                .font(.system(size: 10))
                .foregroundStyle(ZogTheme.foregroundMuted)
                .onTapGesture { openLaunchpad() }
        }
    }

    private var workspaceRow: some View {
        VStack(spacing: 10) {
            ForEach(workspaces.spaces) { space in
                Button {
                    workspaces.focus(space: space.id)
                } label: {
                    DotIndicator(
                        color: color(for: space),
                        size: space.isFocused ? 9 : 7,
                        isActive: space.isFocused || space.hasWindows
                    )
                }
                .buttonStyle(.plain)
                .help("Desktop \(space.id)")
            }
        }
    }

    private var appsColumn: some View {
        VStack(spacing: 12) {
            ForEach(dockApps.apps.prefix(6)) { app in
                Button {
                    dockApps.launchOrActivate(app)
                } label: {
                    ZStack(alignment: .bottom) {
                        AppIconView(image: app.icon, size: 26)
                            .opacity(app.isRunning || app.isFrontmost ? 1 : 0.7)
                            .scaleEffect(app.isFrontmost ? 1.06 : 1)

                        if app.isRunning {
                            Capsule()
                                .fill(ZogTheme.foreground)
                                .frame(width: 3, height: 3)
                                .offset(y: 6)
                        }
                    }
                    .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .help(app.name)
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Button {
                toggleDarkAppearance()
            } label: {
                SFIcon(systemName: "circle.lefthalf.filled", size: 14)
            }
            .buttonStyle(.plain)
            .help("Appearance")

            Button {
                openMissionControl()
            } label: {
                SFIcon(systemName: "checkmark.seal", size: 13, color: ZogTheme.foregroundMuted)
            }
            .buttonStyle(.plain)
            .help("Mission Control")
        }
    }

    private var dockChrome: some View {
        Capsule(style: .continuous)
            .fill(.ultraThinMaterial)
            .background(
                Capsule(style: .continuous)
                    .fill(ZogTheme.islandFill)
            )
            .overlay(
                Capsule(style: .continuous)
                    .stroke(ZogTheme.islandBorder, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 16, y: 4)
    }

    // MARK: Helpers

    private func color(for space: WorkspaceService.Space) -> Color {
        switch workspaces.color(for: space) {
        case .yellow: return ZogTheme.workspaceYellow
        case .blue: return ZogTheme.workspaceBlue
        case .cyan: return ZogTheme.workspaceCyan
        }
    }

    private func openLaunchpad() {
        NSWorkspace.shared.launchApplication("Launchpad")
    }

    private func openMissionControl() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        task.arguments = ["-a", "Mission Control"]
        try? task.run()
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
