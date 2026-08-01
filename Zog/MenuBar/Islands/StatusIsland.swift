import AppKit
import SwiftUI

struct StatusIsland: View {
    @ObservedObject var battery: BatteryService
    @ObservedObject var network: NetworkService

    var body: some View {
        HStack(spacing: ZogTheme.islandGap) {
            // Mail pod — single envelope glyph in a square capsule.
            IslandContainer(cornerRadius: 10, compact: true) {
                Text("\u{2709}") // ✉
                    .font(.system(size: 11, weight: .regular))
                    .foregroundStyle(ZogTheme.foreground)
                    .frame(width: 12, height: 12)
            }
            .help("Mail")

            // Utilities pod — bold B, cursor arrow, grid, chevron.
            IslandContainer {
                HStack(spacing: 9) {
                    Text("B")
                        .font(ZogTheme.utilityLetterFont)
                        .foregroundStyle(ZogTheme.foreground)
                    Text("\u{2315}") // ⌝ (cursor/arrow variant)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(ZogTheme.foregroundDim)
                    Text("\u{25A6}") // ▦ (square with orthogonal crosshatch fill)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(ZogTheme.foreground)
                    Text("\u{25BE}") // ▾
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(ZogTheme.foregroundDim)
                }
            }
            .help("Utilities")

            // Status pod — custom battery, wifi, speaker glyphs.
            IslandContainer {
                HStack(spacing: 9) {
                    BatteryGlyph(
                        fillFraction: max(0, min(1, Double(battery.percentage) / 100.0)),
                        charging: battery.isCharging
                    )
                    WifiGlyph(bars: network.signalBars)
                    SpeakerGlyph()
                }
            }
            .help("System")
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
