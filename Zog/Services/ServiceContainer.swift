import Foundation
import Combine

/// Shared service locator for the overlay chrome.
final class ServiceContainer: ObservableObject {
    static let shared = ServiceContainer()

    let clock: ClockService
    let battery: BatteryService
    let network: NetworkService
    let frontmostApp: FrontmostAppService
    let media: NowPlayingService
    let workspaces: WorkspaceService
    let dockApps: DockAppsService

    private init() {
        clock = ClockService()
        battery = BatteryService()
        network = NetworkService()
        frontmostApp = FrontmostAppService()
        media = NowPlayingService()
        workspaces = WorkspaceService()
        dockApps = DockAppsService()
    }

    func start() {
        clock.start()
        battery.start()
        network.start()
        frontmostApp.start()
        media.start()
        workspaces.start()
        dockApps.start()
    }

    func stop() {
        clock.stop()
        battery.stop()
        network.stop()
        frontmostApp.stop()
        media.stop()
        workspaces.stop()
        dockApps.stop()
    }
}
