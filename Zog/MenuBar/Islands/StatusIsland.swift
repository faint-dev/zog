import AppKit
import SwiftUI

/// Compact utility / notification / connectivity cluster on the top-right.
struct StatusIsland: View {
    @ObservedObject var battery: BatteryService
    @ObservedObject var network: NetworkService

    var body: some View {
        HStack(spacing: ZogTheme.islandGap) {
            IslandContainer {
                SFIcon(systemName: "envelope", size: 12)
            }
            .help("Mail")

            IslandContainer {
                HStack(spacing: 10) {
                    SFIcon(systemName: "b.circle", size: 12)
                    SFIcon(systemName: "cursorarrow.click.2", size: 11, color: ZogTheme.foregroundMuted)
                    SFIcon(systemName: "square.grid.2x2", size: 12)
                    SFIcon(systemName: "chevron.down", size: 9, color: ZogTheme.foregroundMuted)
                }
            }
            .help("Utilities")

            IslandContainer {
                HStack(spacing: 10) {
                    batteryIcon
                    wifiIcon
                    SFIcon(systemName: "speaker.wave.2.fill", size: 12, color: ZogTheme.foregroundMuted)
                }
            }
            .help("System Status")
        }
    }

    private var batteryIcon: some View {
        SFIcon(
            systemName: batterySymbol,
            size: 12,
            color: battery.isCharging || battery.percentage > 20
                ? ZogTheme.accentGreen
                : Color.orange
        )
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

    private var wifiIcon: some View {
        SFIcon(
            systemName: network.isWiFiConnected ? "wifi" : "wifi.slash",
            size: 12,
            color: network.isWiFiConnected ? ZogTheme.foreground : ZogTheme.foregroundDim
        )
    }
}

/// Clock island — monospaced `dd/MM HH:mm` like the references.
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
            openDateSettings()
        }
    }

    private func openDateSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.datetime") {
            NSWorkspace.shared.open(url)
        }
    }
}
