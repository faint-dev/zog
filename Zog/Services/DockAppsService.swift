import AppKit
import Combine
import Foundation

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

    private var observers: [NSObjectProtocol] = []
    private var timer: Timer?

    /// Preferred pinned apps for the geometric dock slots.
    /// (Not related to the left menu-bar island — that follows the frontmost app.)
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
            nc.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] _ in self?.refresh() },
            nc.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) { [weak self] _ in self?.refresh() },
            nc.addObserver(forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main) { [weak self] _ in self?.refresh() }
        ]
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }
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
        } else if let bundleID = Optional(app.id) {
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: bundleID,
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
        var result: [DockApp] = []
        var seen = Set<String>()

        for bid in pinnedBundleIDs {
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bid) {
                let runningApp = running.first { $0.bundleIdentifier == bid }
                let icon = NSWorkspace.shared.icon(forFile: url.path)
                result.append(DockApp(
                    id: bid,
                    name: FileManager.default.displayName(atPath: url.path),
                    bundleURL: url,
                    icon: icon,
                    isRunning: runningApp != nil,
                    isFrontmost: bid == frontID
                ))
                seen.insert(bid)
            }
        }

        for app in running {
            guard let bid = app.bundleIdentifier, !seen.contains(bid) else { continue }
            result.append(DockApp(
                id: bid,
                name: app.localizedName ?? bid,
                bundleURL: app.bundleURL,
                icon: app.icon,
                isRunning: true,
                isFrontmost: bid == frontID
            ))
            seen.insert(bid)
        }

        apps = Array(result.prefix(10))
    }
}
