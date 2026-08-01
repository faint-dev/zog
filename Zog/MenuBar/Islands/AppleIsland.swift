import AppKit
import SwiftUI

/// Far-left Apple logo pod — small, nearly square (reference close-up).
struct AppleIsland: View {
    var body: some View {
        IslandContainer(cornerRadius: ZogTheme.appleIslandRadius, compact: true) {
            Image(systemName: "apple.logo")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(ZogTheme.foreground)
                .frame(width: 14, height: 14)
        }
        .help("Apple")
        .onTapGesture { openAppleMenu() }
    }

    private func openAppleMenu() {
        let script = """
        tell application "System Events"
            click menu bar item 1 of menu bar 1
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
    }
}
