import AppKit
import SwiftUI

/// App context island: icon + name + menu titles in one capsule
/// (matches "Cursor Nightly · File Edit View Window Help" reference).
struct AppMenuIsland: View {
    @ObservedObject var frontmost: FrontmostAppService

    private let menus = ["File", "Edit", "View", "Window", "Help"]

    var body: some View {
        IslandContainer {
            HStack(spacing: 8) {
                AppIconView(image: frontmost.current.icon, size: 15)

                Text(frontmost.current.name)
                    .font(ZogTheme.appNameFont)
                    .foregroundStyle(ZogTheme.foreground)
                    .lineLimit(1)

                HStack(spacing: 12) {
                    ForEach(menus, id: \.self) { title in
                        Text(title)
                            .font(ZogTheme.menuFont)
                            .foregroundStyle(ZogTheme.foreground)
                            .opacity(0.88)
                            .onTapGesture { triggerMenu(named: title) }
                    }
                }
                .padding(.leading, 4)
            }
        }
    }

    private func triggerMenu(named title: String) {
        let script = """
        tell application "System Events"
            tell (first process whose frontmost is true)
                click menu bar item "\(title)" of menu bar 1
            end tell
        end tell
        """
        var error: NSDictionary?
        NSAppleScript(source: script)?.executeAndReturnError(&error)
    }
}
