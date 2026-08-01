import AppKit
import SwiftUI

/// Far-left Apple logo pod (reference image 3).
struct AppleIsland: View {
    var body: some View {
        IslandContainer {
            Image(systemName: "apple.logo")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZogTheme.foreground)
        }
        .help("Apple")
        .onTapGesture {
            openAppleMenu()
        }
    }

    private func openAppleMenu() {
        // Trigger the system Apple menu via the status bar item when possible.
        let script = """
        tell application "System Events"
            click menu bar item 1 of menu bar 1
        end tell
        """
        runAppleScript(script)
    }

    private func runAppleScript(_ source: String) {
        var error: NSDictionary?
        if let script = NSAppleScript(source: source) {
            script.executeAndReturnError(&error)
        }
    }
}
