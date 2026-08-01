import AppKit
import ApplicationServices
import Combine

/// Tracks the frontmost app and its real menu-bar item titles
/// (the usual File / Edit / … menus for whatever is currently open).
@MainActor
final class FrontmostAppService: ObservableObject {
    struct AppInfo: Equatable {
        let name: String
        let bundleID: String?
        let icon: NSImage?
        /// Menu bar item titles for this app (Apple + app menu skipped).
        let menuTitles: [String]
    }

    @Published private(set) var current = AppInfo(
        name: "Finder",
        bundleID: "com.apple.finder",
        icon: nil,
        menuTitles: ["File", "Edit", "View", "Go", "Window", "Help"]
    )

    private var observer: NSObjectProtocol?
    private let fallbackMenus = ["File", "Edit", "View", "Window", "Help"]

    func start() {
        refresh()
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // The notification callback lands on the queue we passed
            // (`.main`); hop explicitly so MainActor isolation holds.
            Task { @MainActor [weak self] in self?.refresh() }
        }
    }

    func stop() {
        if let observer {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
        }
        observer = nil
    }

    private func refresh() {
        guard let app = NSWorkspace.shared.frontmostApplication else { return }
        let name = app.localizedName ?? "Unknown"
        current = AppInfo(
            name: name,
            bundleID: app.bundleIdentifier,
            icon: app.icon,
            menuTitles: readMenuTitles(from: app, appName: name)
        )
    }

    /// Read live menu-bar titles via Accessibility. Falls back to the standard set.
    private func readMenuTitles(from app: NSRunningApplication, appName: String) -> [String] {
        let element = AXUIElementCreateApplication(app.processIdentifier)

        var menuBarRef: AnyObject?
        let barStatus = AXUIElementCopyAttributeValue(
            element,
            kAXMenuBarAttribute as CFString,
            &menuBarRef
        )
        guard barStatus == .success else { return fallbackMenus }

        // The AX API hands back `AnyObject`; the underlying type is
        // `AXUIElement` (an opaque CF type). Cast safely — if Apple ever
        // changes the type we don't want to crash with a force-cast.
        guard let menuBarAny = menuBarRef,
              CFGetTypeID(menuBarAny as CFTypeRef) == AXUIElementGetTypeID()
        else {
            return fallbackMenus
        }
        let menuBar = unsafeBitCast(menuBarAny, to: AXUIElement.self)

        var childrenRef: AnyObject?
        let kidsStatus = AXUIElementCopyAttributeValue(
            menuBar,
            kAXChildrenAttribute as CFString,
            &childrenRef
        )
        guard kidsStatus == .success, let items = childrenRef as? [AXUIElement] else {
            return fallbackMenus
        }

        var titles: [String] = []
        for item in items {
            var titleRef: AnyObject?
            guard AXUIElementCopyAttributeValue(
                item,
                kAXTitleAttribute as CFString,
                &titleRef
            ) == .success,
                  let title = titleRef as? String
            else { continue }

            let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
            // Skip empty (Apple menu), Apple, and the app's own named menu —
            // the island already shows the app name as a label.
            if trimmed.isEmpty { continue }
            if trimmed.compare("Apple", options: .caseInsensitive) == .orderedSame { continue }
            if trimmed.compare(appName, options: .caseInsensitive) == .orderedSame { continue }
            titles.append(trimmed)
        }

        return titles.isEmpty ? fallbackMenus : titles
    }
}
