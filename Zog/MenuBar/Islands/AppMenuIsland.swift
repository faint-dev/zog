import AppKit
import SwiftUI

/// Application context island: icon + name + menu titles
/// (matches the "Cursor Nightly · File Edit View…" reference).
struct AppMenuIsland: View {
    @ObservedObject var frontmost: FrontmostAppService

    private let menus = ["File", "Edit", "View", "Window", "Help"]

    var body: some View {
        IslandContainer {
            HStack(spacing: 10) {
                AppIconView(image: frontmost.current.icon, size: 16)

                Text(frontmost.current.name)
                    .font(ZogTheme.titleFont)
                    .foregroundStyle(ZogTheme.foreground)
                    .lineLimit(1)

                Rectangle()
                    .fill(ZogTheme.foregroundDim)
                    .frame(width: 1, height: 14)
                    .padding(.horizontal, 2)

                HStack(spacing: 14) {
                    ForEach(menus, id: \.self) { title in
                        Text(title)
                            .font(ZogTheme.menuFont)
                            .foregroundStyle(ZogTheme.foregroundMuted)
                            .onTapGesture {
                                triggerMenu(named: title)
                            }
                    }
                }
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
