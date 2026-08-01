import AppKit
import SwiftUI

struct AppleIsland: View {
    var body: some View {
        IslandContainer(cornerRadius: ZogTheme.appleIslandRadius, compact: true) {
            Image(systemName: "apple.logo")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(ZogTheme.foreground)
                .frame(width: 12, height: 12)
        }
        .help("Apple")
        .onTapGesture {
            var error: NSDictionary?
            NSAppleScript(source: """
            tell application "System Events" to click menu bar item 1 of menu bar 1
            """)?.executeAndReturnError(&error)
        }
    }
}
