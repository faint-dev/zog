import SwiftUI
import Foundation
import Combine
import AppKit

/// Workspace / Space indicators. Integrates with yabai when available,
/// otherwise falls back to a simple local model.
final class WorkspaceService: ObservableObject {
    struct Space: Identifiable, Equatable {
        let id: Int
        var isFocused: Bool
        var hasWindows: Bool
    }

    @Published private(set) var spaces: [Space] = (1...5).map { Space(id: $0, isFocused: $0 == 1, hasWindows: $0 <= 2) }
    @Published private(set) var usingYabai: Bool = false

    private var timer: Timer?
    private let colors: [ColorToken] = [.yellow, .blue, .cyan, .yellow, .blue]
    private var spaceObserver: NSObjectProtocol?

    enum ColorToken {
        case yellow, blue, cyan
    }

    func color(for space: Space) -> ColorToken {
        colors[(space.id - 1) % colors.count]
    }

    func start() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refresh()
        }
        if let timer { RunLoop.main.add(timer, forMode: .common) }

        spaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refresh()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let spaceObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(spaceObserver)
        }
        spaceObserver = nil
    }

    func focus(space id: Int) {
        if usingYabai {
            _ = run("/opt/homebrew/bin/yabai", arguments: ["-m", "space", "--focus", "\(id)"])
            _ = run("/usr/local/bin/yabai", arguments: ["-m", "space", "--focus", "\(id)"])
        } else {
            spaces = spaces.map { Space(id: $0.id, isFocused: $0.id == id, hasWindows: $0.hasWindows) }
        }
    }

    private func refresh() {
        if let yabaiSpaces = queryYabaiSpaces() {
            usingYabai = true
            spaces = yabaiSpaces
        } else {
            usingYabai = false
        }
    }

    private func queryYabaiSpaces() -> [Space]? {
        let paths = ["/opt/homebrew/bin/yabai", "/usr/local/bin/yabai"]
        for path in paths {
            guard FileManager.default.isExecutableFile(atPath: path) else { continue }
            let output = runCapture(path, arguments: ["-m", "query", "--spaces"])
            guard let data = output?.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            else { continue }

            return json.compactMap { item in
                guard let id = item["index"] as? Int else { return nil }
                let focused = item["has-focus"] as? Bool ?? false
                let windows = (item["windows"] as? [Any])?.isEmpty == false
                return Space(id: id, isFocused: focused, hasWindows: windows)
            }
        }
        return nil
    }

    @discardableResult
    private func run(_ path: String, arguments: [String]) -> Bool {
        guard FileManager.default.isExecutableFile(atPath: path) else { return false }
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = arguments
        do {
            try task.run()
            task.waitUntilExit()
            return task.terminationStatus == 0
        } catch {
            return false
        }
    }

    private func runCapture(_ path: String, arguments: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: path)
        task.arguments = arguments
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        do {
            try task.run()
            task.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
