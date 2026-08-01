import AppKit
import SwiftUI

struct StatusIsland: View {
    @ObservedObject var battery: BatteryService
    @ObservedObject var network: NetworkService

    var body: some View {
        HStack(spacing: ZogTheme.islandGap) {
            IslandContainer(compact: true) {
                SFIcon(systemName: "envelope", size: 10)
            }
            .help("Mail")

            IslandContainer {
                HStack(spacing: 9) {
                    Text("B")
                        .font(.system(size: 10.5, weight: .bold, design: .rounded))
                        .foregroundStyle(ZogTheme.foreground)
                    SFIcon(systemName: "cursorarrow", size: 9, color: ZogTheme.foregroundMuted)
                    SFIcon(systemName: "square.grid.2x2", size: 10)
                    SFIcon(systemName: "chevron.down", size: 7, color: ZogTheme.foregroundMuted)
                }
            }
            .help("Utilities")

            IslandContainer {
                HStack(spacing: 9) {
                    SFIcon(
                        systemName: batterySymbol,
                        size: 11,
                        color: battery.isCharging || battery.percentage > 20
                            ? ZogTheme.accentGreen
                            : Color.orange
                    )
                    SFIcon(
                        systemName: network.isWiFiConnected ? "wifi" : "wifi.slash",
                        size: 10,
                        color: network.isWiFiConnected ? ZogTheme.foreground : ZogTheme.foregroundDim
                    )
                    SFIcon(systemName: "speaker.wave.2.fill", size: 10, color: ZogTheme.foregroundMuted)
                }
            }
            .help("System")
        }
    }

    private var batterySymbol: String {
        if battery.isCharging { return "battery.100.bolt" }
        switch battery.percentage {
        case 75...100: return "battery.100"
        case 50..<75: return "battery.75"
        case 25..<50: return "battery.50"
        case 10..<25: return "battery.25"
        default: return "battery.0"
        }
    }
}

struct ClockIsland: View {
    @ObservedObject var clock: ClockService

    var body: some View {
        IslandContainer {
            Text(clock.combined)
                .font(ZogTheme.clockFont)
                .foregroundStyle(ZogTheme.foreground)
                .monospacedDigit()
        }
        .help("Date & Time")
        .onTapGesture {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.datetime") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
