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

    /// Default pinned apps the first time Zog runs. After that the user's
    /// pin/unpin choices are persisted in UserDefaults.
    private static let defaultPinnedBundleIDs = [
        "com.apple.finder",
        "com.apple.Safari",
        "com.apple.Terminal",
        "com.apple.Music"
    ]

    private static let pinnedDefaultsKey = "zog.dock.pinnedBundleIDs"

    @Published private(set) var apps: [DockApp] = []
    @Published private(set) var pinned: [DockApp] = []
    @Published private(set) var pinnedBundleIDs: [String] = []

    private var observers: [NSObjectProtocol] = []
    private var timer: Timer?

    init() {
        let defaults = UserDefaults.standard
        if let saved = defaults.array(forKey: Self.pinnedDefaultsKey) as? [String] {
            self.pinnedBundleIDs = saved
        } else {
            self.pinnedBundleIDs = Self.defaultPinnedBundleIDs
            defaults.set(Self.defaultPinnedBundleIDs, forKey: Self.pinnedDefaultsKey)
        }
    }

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

    // MARK: - App actions

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

    func quit(_ app: DockApp) {
        guard let running = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == app.id }) else { return }
        running.terminate()
    }

    func hide(_ app: DockApp) {
        guard let running = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == app.id }) else { return }
        running.hide()
    }

    func showInFinder(_ app: DockApp) {
        let target: URL?
        if let url = app.bundleURL {
            target = url
        } else if let bid = Optional(app.id),
                  let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid) {
            target = url
        } else {
            target = nil
        }
        guard let target else { return }
        NSWorkspace.shared.activateFileViewerSelecting([target])
    }

    func togglePin(_ bundleID: String) {
        if pinnedBundleIDs.contains(bundleID) {
            pinnedBundleIDs.removeAll { $0 == bundleID }
        } else {
            pinnedBundleIDs.append(bundleID)
        }
        UserDefaults.standard.set(pinnedBundleIDs, forKey: Self.pinnedDefaultsKey)
        refresh()
    }

    // MARK: - Refresh

    private func refresh() {
        let running = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        let frontID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier

        // Index previous results so we preserve already-loaded icons.
        let previousByID = Dictionary(uniqueKeysWithValues:
            (apps + pinned).map { ($0.id, $0) }
        )

        // Pinned apps: always present if installed, marked as running if currently open.
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
