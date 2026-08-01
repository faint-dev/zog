import AppKit
import SwiftUI
import Combine

/// Manages the vertical dock pill + the two separate circular FABs below it
/// (moon / check) as in reference 1.
final class DockController {
    private let services: ServiceContainer
    private var dockPanel: PanelWindow<AnyView>?
    private var moonPanel: PanelWindow<AnyView>?
    private var checkPanel: PanelWindow<AnyView>?
    private var cancellables = Set<AnyCancellable>()
    private var sizeObserver: NSObjectProtocol?

    init(services: ServiceContainer) {
        self.services = services
    }

    func show() {
        let fab = ZogTheme.fabSize + 4
        dockPanel = PanelWindow(
            rootView: AnyView(dockRoot),
            size: NSSize(width: ZogTheme.dockWidth + 8, height: 360),
            style: .dock
        )
        moonPanel = PanelWindow(
            rootView: AnyView(DockMoonButton().padding(2)),
            size: NSSize(width: fab, height: fab),
            style: .dock
        )
        checkPanel = PanelWindow(
            rootView: AnyView(DockCheckButton().padding(2)),
            size: NSSize(width: fab, height: fab),
            style: .dock
        )

        reposition()
        dockPanel?.orderFrontRegardless()
        moonPanel?.orderFrontRegardless()
        checkPanel?.orderFrontRegardless()
        observe()
    }

    func hide() {
        dockPanel?.orderOut(nil)
        moonPanel?.orderOut(nil)
        checkPanel?.orderOut(nil)
    }

    func reposition() {
        let dockH = estimatedDockHeight()
        let dockW = ZogTheme.dockWidth + 8
        let fab = ZogTheme.fabSize + 4
        let fabStack = fab * 2 + ZogTheme.fabGap + 10

        var dockRect = ScreenLayout.rightDock(width: dockW, height: dockH)
        dockRect.origin.y += fabStack / 2

        dockPanel?.setFrame(dockRect, display: true)
        dockPanel?.setRootView(AnyView(dockRoot))

        let fabX = dockRect.midX - fab / 2
        let moonFrame = NSRect(
            x: fabX,
            y: dockRect.minY - ZogTheme.fabGap - fab,
            width: fab,
            height: fab
        )
        let checkFrame = NSRect(
            x: fabX,
            y: moonFrame.minY - ZogTheme.fabGap - fab,
            width: fab,
            height: fab
        )
        moonPanel?.setFrame(moonFrame, display: true)
        checkPanel?.setFrame(checkFrame, display: true)
    }

    private var dockRoot: some View {
        VerticalDockView(
            workspaces: services.workspaces,
            dockApps: services.dockApps
        )
        .padding(4)
    }

    private func estimatedDockHeight() -> CGFloat {
        let spaces = CGFloat(min(max(services.workspaces.spaces.count, 1), 3))
        return 55 + 40 + spaces * 18 + 100
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
