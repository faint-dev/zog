import AppKit
import Foundation

/// Best-effort helpers to hide / restore the native Dock and menu bar so
/// Zog can act as a full chrome replacement (SketchyBar + dock replacement).
enum SystemChrome {
    private static let dockDomain = "com.apple.dock"
    private static var previousAutohide: Bool?
    private static var previousAutohideDelay: Double?
    private static var previousAutohideTimeModifier: Double?
    private static var previousHideMenuBar: Bool?

    static func hideNativeChrome() {
        // Prefer soft-hide via Dock autohide so we don't fight System Settings permanently.
        previousAutohide = defaultsBool(domain: dockDomain, key: "autohide")
        previousAutohideDelay = defaultsDouble(domain: dockDomain, key: "autohide-delay")
        previousAutohideTimeModifier = defaultsDouble(domain: dockDomain, key: "autohide-time-modifier")

        runDefaults(["write", dockDomain, "autohide", "-bool", "true"])
        runDefaults(["write", dockDomain, "autohide-delay", "-float", "0"])
        runDefaults(["write", dockDomain, "autohide-time-modifier", "-float", "0"])
        restartDock()

        // Hide the system menu bar automatically (macOS Sonoma+ Desktop & Dock setting).
        // Falls back silently on older systems.
        previousHideMenuBar = defaultsBool(domain: "NSGlobalDomain", key: "_HIHideMenuBar")
        runDefaults(["write", "NSGlobalDomain", "_HIHideMenuBar", "-bool", "true"])
        DistributedNotificationCenter.default().postNotificationName(
            NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            userInfo: nil,
            deliverImmediately: true
        )
    }

    static func restoreNativeChrome() {
        if let previousAutohide {
            runDefaults(["write", dockDomain, "autohide", "-bool", previousAutohide ? "true" : "false"])
        }
        if let previousAutohideDelay {
            runDefaults(["write", dockDomain, "autohide-delay", "-float", "\(previousAutohideDelay)"])
        } else {
            runDefaults(["delete", dockDomain, "autohide-delay"])
        }
        if let previousAutohideTimeModifier {
            runDefaults(["write", dockDomain, "autohide-time-modifier", "-float", "\(previousAutohideTimeModifier)"])
        } else {
            runDefaults(["delete", dockDomain, "autohide-time-modifier"])
        }
        if let previousHideMenuBar {
            runDefaults(["write", "NSGlobalDomain", "_HIHideMenuBar", "-bool", previousHideMenuBar ? "true" : "false"])
        }
        restartDock()
    }

    private static func restartDock() {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/killall")
        task.arguments = ["Dock"]
        try? task.run()
    }

    private static func runDefaults(_ args: [String]) {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        task.arguments = args
        try? task.run()
        task.waitUntilExit()
    }

    private static func defaultsBool(domain: String, key: String) -> Bool? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
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
        task.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
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
