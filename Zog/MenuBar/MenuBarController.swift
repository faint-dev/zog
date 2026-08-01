import AppKit
import SwiftUI
import Combine

/// Orchestrates the floating top islands — Apple, App menu, Media (center),
/// Status cluster, and Clock — matching the modular SketchyBar island layout.
@MainActor
final class MenuBarController {
    private let services: ServiceContainer

    private var leftPanel: PanelWindow<AnyView>?
    private var centerPanel: PanelWindow<AnyView>?
    private var rightPanel: PanelWindow<AnyView>?

    private var cancellables = Set<AnyCancellable>()
    private var sizeObserver: NSObjectProtocol?

    init(services: ServiceContainer) {
        self.services = services
    }

    func show() {
        buildPanels()
        reposition()
        observeChanges()
    }

    func hide() {
        leftPanel?.orderOut(nil)
        centerPanel?.orderOut(nil)
        rightPanel?.orderOut(nil)
    }

    func reposition() {
        layoutLeft()
        layoutCenter()
        layoutRight()
    }

    // MARK: - Panels

    private func buildPanels() {
        let leftSize = NSSize(width: 520, height: ZogTheme.islandHeight + 8)
        leftPanel = PanelWindow(
            rootView: AnyView(leftCluster),
            size: leftSize,
            style: .island
        )

        let centerSize = NSSize(width: 320, height: ZogTheme.mediaIslandHeight + 8)
        centerPanel = PanelWindow(
            rootView: AnyView(centerCluster),
            size: centerSize,
            style: .island
        )

        let rightSize = NSSize(width: 360, height: ZogTheme.islandHeight + 8)
        rightPanel = PanelWindow(
            rootView: AnyView(rightCluster),
            size: rightSize,
            style: .island
        )

        leftPanel?.orderFrontRegardless()
        centerPanel?.orderFrontRegardless()
        rightPanel?.orderFrontRegardless()
    }

    private var leftCluster: some View {
        HStack(spacing: ZogTheme.islandGap) {
            AppleIsland()
            AppMenuIsland(frontmost: services.frontmostApp)
        }
        .fixedSize()
        .padding(4)
    }

    private var centerCluster: some View {
        MediaIsland(media: services.media)
            .fixedSize()
            .padding(4)
    }

    private var rightCluster: some View {
        HStack(spacing: ZogTheme.islandGap) {
            StatusIsland(battery: services.battery, network: services.network)
            ClockIsland(clock: services.clock)
        }
        .fixedSize()
        .padding(4)
    }

    // MARK: - Layout

    private func layoutLeft() {
        guard let panel = leftPanel else { return }
        let fitting = fittingSize(for: leftCluster, fallback: NSSize(width: 480, height: 40))
        let rect = ScreenLayout.topLeading(
            x: max(0, ScreenLayout.notchSafeLeadingInset - ZogTheme.screenInset),
            width: fitting.width,
            height: fitting.height
        )
        panel.setFrame(rect, display: true)
    }

    private func layoutCenter() {
        guard let panel = centerPanel else { return }
        let hasMedia = services.media.track != nil
        guard hasMedia else {
            panel.orderOut(nil)
            return
        }
        let fitting = fittingSize(for: centerCluster, fallback: NSSize(width: 280, height: 52))
        let rect = ScreenLayout.topCenter(width: fitting.width, height: fitting.height)
        panel.setFrame(rect, display: true)
        panel.orderFrontRegardless()
    }

    private func layoutRight() {
        guard let panel = rightPanel else { return }
        let fitting = fittingSize(for: rightCluster, fallback: NSSize(width: 320, height: 40))
        let rect = ScreenLayout.topTrailing(
            width: fitting.width,
            height: fitting.height,
            trailingOffset: ScreenLayout.dockClearance
        )
        panel.setFrame(rect, display: true)
    }

    private func fittingSize<V: View>(for view: V, fallback: NSSize) -> NSSize {
        let host = NSHostingView(rootView: view)
        let size = host.fittingSize
        if size.width < 10 || size.height < 10 { return fallback }
        return NSSize(width: ceil(size.width), height: ceil(size.height))
    }

    private func observeChanges() {
        services.frontmostApp.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.layoutLeft() }
            .store(in: &cancellables)

        services.media.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.layoutCenter() }
            .store(in: &cancellables)

        services.clock.objectWillChange
            .merge(with: services.battery.objectWillChange)
            .merge(with: services.network.objectWillChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.layoutRight() }
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
