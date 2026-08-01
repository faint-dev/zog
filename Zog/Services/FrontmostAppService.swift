import AppKit
import Combine

final class FrontmostAppService: ObservableObject {
    struct AppInfo: Equatable {
        let name: String
        let bundleID: String?
        let icon: NSImage?
    }

    @Published private(set) var current: AppInfo = AppInfo(name: "Finder", bundleID: "com.apple.finder", icon: nil)

    private var observer: NSObjectProtocol?

    func start() {
        refresh()
        observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
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
        current = AppInfo(
            name: app.localizedName ?? "Unknown",
            bundleID: app.bundleIdentifier,
            icon: app.icon
        )
    }
}
