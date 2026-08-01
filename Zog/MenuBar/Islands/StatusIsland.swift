import AppKit
import SwiftUI

/// Right-side island cluster matching the reference screenshots:
/// envelope · utilities (B / cursor / grid / chevron) · battery+wifi · clock
struct StatusIsland: View {
    @ObservedObject var battery: BatteryService
    @ObservedObject var network: NetworkService

    var body: some View {
        HStack(spacing: ZogTheme.islandGap) {
            // Notification
            IslandContainer(compact: true) {
                SFIcon(systemName: "envelope", size: 11)
            }
            .help("Mail")

            // Utilities — B · selection · grid · chevron (ref 2)
            IslandContainer {
                HStack(spacing: 9) {
                    Text("B")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(ZogTheme.foreground)
                    SFIcon(systemName: "cursorarrow", size: 10, color: ZogTheme.foregroundMuted)
                    SFIcon(systemName: "square.grid.2x2", size: 11)
                    SFIcon(systemName: "chevron.down", size: 8, color: ZogTheme.foregroundMuted)
                }
            }
            .help("Utilities")

            // Connectivity / power (ref 1: battery · wifi · speaker)
            IslandContainer {
                HStack(spacing: 9) {
                    batteryIcon
                    wifiIcon
                    SFIcon(systemName: "speaker.wave.2.fill", size: 11, color: ZogTheme.foregroundMuted)
                }
            }
            .help("System")
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
            size: 11,
            color: network.isWiFiConnected ? ZogTheme.foreground : ZogTheme.foregroundDim
        )
    }
}

/// Separate clock capsule — monospaced `dd/MM HH:mm` (refs: `25/07 00:10`).
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
