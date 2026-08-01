import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var dockController: DockController?
    private let services = ServiceContainer.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Hide the native Dock & menu bar while Zog is running (best-effort).
        SystemChrome.hideNativeChrome()

        services.start()

        menuBarController = MenuBarController(services: services)
        dockController = DockController(services: services)

        menuBarController?.show()
        dockController?.show()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeSpaceDidChange),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        SystemChrome.restoreNativeChrome()
        menuBarController?.hide()
        dockController?.hide()
        services.stop()
    }

    @objc private func activeSpaceDidChange() {
        menuBarController?.reposition()
        dockController?.reposition()
    }
}
