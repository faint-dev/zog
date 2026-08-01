import AppKit
import SwiftUI

/// Vertical dock matching references 1 & 4:
/// slim dark capsule, geometric white glyphs, colored workspace dots —
/// no colorful app-icon grid.
struct VerticalDockView: View {
    @ObservedObject var workspaces: WorkspaceService
    @ObservedObject var dockApps: DockAppsService
    @ObservedObject var clock: ClockService

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                // Ref 1: stylized cube mark
                Button(action: openLaunchpad) {
                    CubeMark()
                }
                .buttonStyle(.plain)
                .help("Launchpad")

                // Ref 1 / 4: 3×3 dot grid
                Button(action: openLaunchpad) {
                    GeoGrid(cols: 3, rows: 3, cell: 2.2, gap: 1.8)
                }
                .buttonStyle(.plain)
                .help("Apps")
            }
            .padding(.top, 14)

            spacerDot

            // Ref 1: colored workspace dots with tiny white dividers
            VStack(spacing: 8) {
                ForEach(Array(workspaces.spaces.enumerated()), id: \.element.id) { index, space in
                    Button {
                        workspaces.focus(space: space.id)
                    } label: {
                        DotIndicator(
                            color: color(for: space),
                            size: space.isFocused ? 8 : 6,
                            isActive: space.isFocused || space.hasWindows
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Desktop \(space.id)")

                    if index < workspaces.spaces.count - 1 {
                        Circle()
                            .fill(ZogTheme.foreground.opacity(0.25))
                            .frame(width: 2, height: 2)
                    }
                }
            }

            spacerDot

            // Ref 4: geometric controls (rects, grid, pill, blocks)
            // Bound to first few pinned/running apps as glyph slots
            VStack(spacing: 11) {
                ForEach(Array(glyphSlots.enumerated()), id: \.offset) { _, slot in
                    Button {
                        slot.action()
                    } label: {
                        slot.label
                    }
                    .buttonStyle(.plain)
                    .help(slot.help)
                }
            }

            Spacer(minLength: 10)

            // Ref 1 footer: half-moon + check
            VStack(spacing: 12) {
                Button(action: toggleDarkAppearance) {
                    SFIcon(systemName: "circle.lefthalf.filled", size: 13)
                }
                .buttonStyle(.plain)
                .help("Appearance")

                Button(action: openMissionControl) {
                    // Checkmark-in-circle mark from ref 1
                    ZStack {
                        Circle()
                            .stroke(ZogTheme.foreground.opacity(0.85), lineWidth: 1.2)
                            .frame(width: 14, height: 14)
                        Image(systemName: "checkmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundStyle(ZogTheme.foreground)
                    }
                }
                .buttonStyle(.plain)
                .help("Mission Control")

                // Ref 4: minute numeral near bottom
                Text(minuteText)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(ZogTheme.foregroundMuted)
            }
            .padding(.bottom, 14)
        }
        .frame(width: ZogTheme.dockWidth)
        .background(dockChrome)
    }

    // MARK: - Glyph slots (ref 4 geometry wired to apps)

    private struct GlyphSlot {
        let help: String
        let label: AnyView
        let action: () -> Void
    }

    private var glyphSlots: [GlyphSlot] {
        var slots: [GlyphSlot] = [
            GlyphSlot(help: "Finder", label: AnyView(GeoRect(width: 12, height: 7)), action: {
                activate(bundleID: "com.apple.finder")
            }),
            GlyphSlot(help: "Grid", label: AnyView(GeoGrid(cols: 2, rows: 2, cell: 3, gap: 2)), action: {
                openLaunchpad()
            }),
            GlyphSlot(help: "Focus", label: AnyView(GeoPillToggle(on: false)), action: {
                // no-op placeholder / focus mode
            })
        ]

        // Large blocks for first running apps (ref 4 white squares)
        for app in dockApps.apps.filter(\.isRunning).prefix(2) {
            let id = app.id
            slots.append(GlyphSlot(
                help: app.name,
                label: AnyView(GeoBlock(size: 12).opacity(app.isFrontmost ? 1 : 0.7)),
                action: { activate(bundleID: id) }
            ))
        }

        // Ref 2-style glyphs: globe / network
        slots.append(GlyphSlot(
            help: "Safari",
            label: AnyView(SFIcon(systemName: "globe", size: 12)),
            action: { activate(bundleID: "com.apple.Safari") }
        ))

        return Array(slots.prefix(6))
    }

    private var spacerDot: some View {
        Circle()
            .fill(ZogTheme.foreground.opacity(0.2))
            .frame(width: 2, height: 2)
            .padding(.vertical, 10)
    }

    private var minuteText: String {
        // clock.combined is "dd/MM HH:mm" — take minutes
        let parts = clock.combined.split(separator: ":")
        return parts.last.map(String.init) ?? "--"
    }

    private var dockChrome: some View {
        Capsule(style: .continuous)
            .fill(ZogTheme.dockFill)
            .overlay(
                Capsule(style: .continuous)
                    .stroke(ZogTheme.islandBorder, lineWidth: 0.5)
            )
            .shadow(color: .black.opacity(0.4), radius: 14, y: 3)
    }

    // MARK: Actions

    private func color(for space: WorkspaceService.Space) -> Color {
        switch workspaces.color(for: space) {
        case .yellow: return ZogTheme.workspaceYellow
        case .blue: return ZogTheme.workspaceBlue
        case .cyan: return ZogTheme.workspaceCyan
        }
    }

    private func activate(bundleID: String) {
        if let app = dockApps.apps.first(where: { $0.id == bundleID }) {
            dockApps.launchOrActivate(app)
        } else if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
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
