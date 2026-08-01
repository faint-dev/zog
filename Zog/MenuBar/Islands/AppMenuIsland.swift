import AppKit
import SwiftUI

/// Frontmost-app island: icon + name of whatever is active, then that app's
/// normal menu-bar items (File / Edit / … — read live via Accessibility).
struct AppMenuIsland: View {
    @ObservedObject var frontmost: FrontmostAppService

    var body: some View {
        IslandContainer {
            HStack(spacing: 7) {
                AppIconView(image: frontmost.current.icon, size: 14)

                Text(frontmost.current.name)
                    .font(ZogTheme.appNameFont)
                    .foregroundStyle(ZogTheme.foreground)
                    .lineLimit(1)

                HStack(spacing: 11) {
                    ForEach(frontmost.current.menuTitles, id: \.self) { title in
                        Text(title)
                            .font(ZogTheme.menuFont)
                            .foregroundStyle(ZogTheme.foreground.opacity(0.88))
                            .onTapGesture { triggerMenu(named: title) }
                    }
                }
                .padding(.leading, 2)
            }
        }
    }

    private func triggerMenu(named title: String) {
        var error: NSDictionary?
        NSAppleScript(source: """
        tell application "System Events"
            tell (first process whose frontmost is true)
                click menu bar item "\(title)" of menu bar 1
            end tell
        end tell
        """)?.executeAndReturnError(&error)
    }
}
