import AppKit
import SwiftUI
import Combine

final class DockController {
    private let services: ServiceContainer
    private var panel: PanelWindow<AnyView>?
    private var cancellables = Set<AnyCancellable>()
    private var sizeObserver: NSObjectProtocol?

    init(services: ServiceContainer) {
        self.services = services
    }

    func show() {
        let size = NSSize(width: ZogTheme.dockWidth + 8, height: 420)
        let root = AnyView(
            VerticalDockView(
                workspaces: services.workspaces,
                dockApps: services.dockApps
            )
            .padding(4)
        )
        panel = PanelWindow(rootView: root, size: size, style: .dock)
        reposition()
        panel?.orderFrontRegardless()
        observe()
    }

    func hide() {
        panel?.orderOut(nil)
    }

    func reposition() {
        guard let panel else { return }
        let height = estimatedHeight()
        let width = ZogTheme.dockWidth + 8
        let rect = ScreenLayout.rightDock(width: width, height: height)
        panel.setFrame(rect, display: true)
        panel.setRootView(AnyView(
            VerticalDockView(
                workspaces: services.workspaces,
                dockApps: services.dockApps
            )
            .padding(4)
        ))
    }

    private func estimatedHeight() -> CGFloat {
        // Header + workspaces + apps + footer with paddings
        let workspaceCount = CGFloat(max(services.workspaces.spaces.count, 1))
        let appCount = CGFloat(min(services.dockApps.apps.count, 6))
        let base: CGFloat = 120
        return base + workspaceCount * 18 + appCount * 40 + 80
    }

    private func observe() {
        services.workspaces.objectWillChange
            .merge(with: services.dockApps.objectWillChange)
            .debounce(for: .milliseconds(80), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.reposition() }
            .store(in: &cancellables)

        sizeObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.reposition()
        }
    }
}
