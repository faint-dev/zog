import AppKit
import SwiftUI
import Combine

/// Manages the vertical dock pill. (Moon / check FABs were removed — the
/// user didn't ask for them.)
@MainActor
final class DockController {
    private let services: ServiceContainer
    private var dockPanel: PanelWindow<AnyView>?
    private var cancellables = Set<AnyCancellable>()
    private var sizeObserver: NSObjectProtocol?

    init(services: ServiceContainer) {
        self.services = services
    }

    func show() {
        dockPanel = PanelWindow(
            rootView: AnyView(dockRoot),
            size: NSSize(width: ZogTheme.dockWidth + 8, height: 360),
            style: .dock
        )
        reposition()
        dockPanel?.orderFrontRegardless()
        observe()
    }

    func hide() {
        dockPanel?.orderOut(nil)
    }

    func reposition() {
        let dockH = estimatedDockHeight()
        let dockW = ZogTheme.dockWidth + 8

        let dockRect = ScreenLayout.rightDock(width: dockW, height: dockH)
        dockPanel?.setFrame(dockRect, display: true)
    }

    private var dockRoot: some View {
        VerticalDockView(
            workspaces: services.workspaces,
            dockApps: services.dockApps
        )
        .padding(.horizontal, 4)
    }

    private func estimatedDockHeight() -> CGFloat {
        let pinned = services.dockApps.pinned.count
        let running = services.dockApps.apps.count
        let totalApps = pinned + (running > 0 ? running + 1 : 0) // +1 for separator
        let appsH = CGFloat(max(0, totalApps)) * 36
        let separatorH: CGFloat = 12
        let workspaceH: CGFloat = 30
        let chrome: CGFloat = 26
        return appsH + separatorH + workspaceH + chrome
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
            Task { @MainActor [weak self] in self?.reposition() }
        }
    }
}
