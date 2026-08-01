import Foundation

/// Lightweight configuration surface mirroring SketchyBar’s runtime
/// `--bar` / `--default` knobs. Mutating these and posting
/// `ZogConfig.didChange` lets overlays re-layout without a restart.
struct ZogConfig: Equatable {
    var screenInset: CGFloat = 12
    var islandGap: CGFloat = 8
    var islandHeight: CGFloat = 32
    var mediaIslandHeight: CGFloat = 44
    var dockWidth: CGFloat = 52
    var dockOnRight: Bool = true
    var showMediaIsland: Bool = true
    var hideNativeChrome: Bool = true
    var clockFormat: String = "dd/MM HH:mm"

    static var shared = ZogConfig()
    static let didChange = Notification.Name("ZogConfig.didChange")

    mutating func apply(_ mutate: (inout ZogConfig) -> Void) {
        mutate(&self)
        NotificationCenter.default.post(name: Self.didChange, object: nil)
    }
}
