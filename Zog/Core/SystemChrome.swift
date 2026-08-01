import AppKit
import Foundation

/// Best-effort helpers to hide / restore the native Dock and menu bar so
/// Zog can act as a full chrome replacement (SketchyBar + dock replacement).
enum SystemChrome {
    private static let dockDomain = "com.apple.dock"
    private static let dockBinary = "/usr/bin/killall"
    private static let defaultsBinary = "/usr/bin/defaults"

    /// Snapshot of the user's pre-existing settings; populated by
    /// `hideNativeChrome` and consumed by `restoreNativeChrome`.
    private static var snapshot: DockSnapshot?

    private struct DockSnapshot {
        let autohide: Bool?
        let autohideDelay: Double?
        let autohideTimeModifier: Double?
    }

    /// Hides the native dock (autohide) and the menu bar. Schedules the
    /// dock restart on a background queue so we don't block launch.
    static func hideNativeChrome() {
        snapshot = DockSnapshot(
            autohide: defaultsBool(domain: dockDomain, key: "autohide"),
            autohideDelay: defaultsDouble(domain: dockDomain, key: "autohide-delay"),
            autohideTimeModifier: defaultsDouble(domain: dockDomain, key: "autohide-time-modifier")
        )

        runDefaults(["write", dockDomain, "autohide", "-bool", "true"])
        runDefaults(["write", dockDomain, "autohide-delay", "-float", "0"])
        runDefaults(["write", dockDomain, "autohide-time-modifier", "-float", "0"])

        // Hide the system menu bar automatically (macOS Sonoma+ Desktop & Dock
        // setting). Falls back silently on older systems.
        runDefaults(["write", "NSGlobalDomain", "_HIHideMenuBar", "-bool", "true"])
        DistributedNotificationCenter.default().postNotificationName(
            NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )

        // Restarting Dock via `killall` is the only reliable way to pick up
        // the new autohide setting; do it off the launch path so the menu
        // bar islands appear as fast as possible.
        DispatchQueue.global(qos: .userInitiated).async {
            restartDock()
        }
    }

    static func restoreNativeChrome() {
        if let snapshot {
            if let autohide = snapshot.autohide {
                runDefaults(["write", dockDomain, "autohide", "-bool", autohide ? "true" : "false"])
            }
            if let delay = snapshot.autohideDelay {
                runDefaults(["write", dockDomain, "autohide-delay", "-float", "\(delay)"])
            }
            if let modifier = snapshot.autohideTimeModifier {
                runDefaults(["write", dockDomain, "autohide-time-modifier", "-float", "\(modifier)"])
            }
            self.snapshot = nil
        }
        runDefaults(["write", "NSGlobalDomain", "_HIHideMenuBar", "-bool", "false"])
        restartDock()
    }

    private static func restartDock() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: dockBinary)
        task.arguments = ["Dock"]
        try? task.run()
    }

    private static func runDefaults(_ args: [String]) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: defaultsBinary)
        task.arguments = args
        try? task.run()
        task.waitUntilExit()
    }

    private static func defaultsBool(domain: String, key: String) -> Bool? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: defaultsBinary)
        task.arguments = ["read", domain, key]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        return str == "1" || str.lowercased() == "true" || str.lowercased() == "yes"
    }

    private static func defaultsDouble(domain: String, key: String) -> Double? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: defaultsBinary)
        task.arguments = ["read", domain, key]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let str = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return nil
        }
        return Double(str)
    }
}
