import SwiftUI

struct SettingsView: View {
    @State private var config = ZogConfig.shared

    var body: some View {
        Form {
            Section("Chrome") {
                Toggle("Hide native Dock & menu bar", isOn: $config.hideNativeChrome)
                Toggle("Show media island when playing", isOn: $config.showMediaIsland)
                Toggle("Vertical dock on right", isOn: $config.dockOnRight)
            }

            Section("Layout") {
                LabeledContent("Screen inset") {
                    Text("\(Int(config.screenInset)) pt")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Island height") {
                    Text("\(Int(config.islandHeight)) pt")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Dock width") {
                    Text("\(Int(config.dockWidth)) pt")
                        .foregroundStyle(.secondary)
                }
            }

            Section("About") {
                LabeledContent("Zog") {
                    Text("macOS UI replacement")
                        .foregroundStyle(.secondary)
                }
                LabeledContent("Inspired by") {
                    Text("SketchyBar")
                        .foregroundStyle(.secondary)
                }
                Link(
                    "FelixKratz/SketchyBar",
                    destination: URL(string: "https://github.com/FelixKratz/SketchyBar")!
                )
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 360)
        .padding()
        .onChange(of: config) { _, newValue in
            ZogConfig.shared = newValue
            NotificationCenter.default.post(name: ZogConfig.didChange, object: nil)
        }
    }
}
