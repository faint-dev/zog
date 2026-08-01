import AppKit
import Combine
import Foundation

@MainActor
final class DockAppsService: ObservableObject {
    struct DockApp: Identifiable, Equatable {
        let id: String
        let name: String
        let bundleURL: URL?
        let icon: NSImage?
        var isRunning: Bool
        var isFrontmost: Bool
    }

    @Published private(set) var apps: [DockApp] = []
    /// Pinned apps always shown in the dock, regardless of running state.
    @Published private(set) var pinned: [DockApp] = []

    private var observers: [NSObjectProtocol] = []
    private var timer: Timer?

    /// Preferred pinned apps for the dock.
    private let pinnedBundleIDs = [
        "com.apple.finder",
        "com.apple.Safari",
        "com.apple.Terminal",
        "com.apple.Music",
        "com.apple.systempreferences"
    ]

    func start() {
        refresh()
        let nc = NSWorkspace.shared.notificationCenter
        observers = [
            nc.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            },
            nc.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            },
            nc.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] _ in
                Task { @MainActor [weak self] in self?.refresh() }
            }
        ]
        let timer = Timer(timeInterval: 5, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.refresh() }
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    func stop() {
        observers.forEach { NSWorkspace.shared.notificationCenter.removeObserver($0) }
        observers.removeAll()
        timer?.invalidate()
        timer = nil
    }

    func launchOrActivate(_ app: DockApp) {
        if let url = app.bundleURL {
            NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
        } else {
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: app.id,
                options: [],
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
        }
    }

    private func refresh() {
        let running = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        let frontID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        // Index previous results so we preserve already-loaded icons.
        let previousByID = Dictionary(uniqueKeysWithValues:
            (apps + pinned).map { ($0.id, $0) }
        )

        // Pinned apps: always present, marked as running if currently open.
        var pinnedApps: [DockApp] = []
        for bid in pinnedBundleIDs {
            guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid) else { continue }
            let runningApp = running.first { $0.bundleIdentifier == bid }
            let icon = previousByID[bid]?.icon ?? NSWorkspace.shared.icon(forFile: url.path)
            pinnedApps.append(DockApp(
                id: bid,
                name: FileManager.default.displayName(atPath: url.path),
                bundleURL: url,
                icon: icon,
                isRunning: runningApp != nil,
                isFrontmost: bid == frontID
            ))
        }
        if pinnedApps != pinned { pinned = pinnedApps }

        // Running apps that aren't pinned.
        let pinnedIDs = Set(pinnedApps.map(\.id))
        var runningApps: [DockApp] = []
        for app in running {
            guard let bid = app.bundleIdentifier, !pinnedIDs.contains(bid) else { continue }
            let icon = previousByID[bid]?.icon ?? app.icon
            runningApps.append(DockApp(
                id: bid,
                name: app.localizedName ?? bid,
                bundleURL: app.bundleURL,
                icon: icon,
                isRunning: true,
                isFrontmost: bid == frontID
            ))
        }
        let next = Array(runningApps.prefix(12))
        if next != apps { apps = next }
    }
}
