import AppKit
import SwiftUI

/// Center media island — artwork, title/artist, transport controls
/// (matches the "Alone / MPH" reference layout).
struct MediaIsland: View {
    @ObservedObject var media: NowPlayingService

    var body: some View {
        Group {
            if let track = media.track {
                IslandContainer(height: ZogTheme.mediaIslandHeight, cornerRadius: 16) {
                    HStack(spacing: 12) {
                        artwork(track)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(track.title)
                                .font(ZogTheme.titleFont)
                                .foregroundStyle(ZogTheme.foreground)
                                .lineLimit(1)
                            Text(track.artist.isEmpty ? " " : track.artist)
                                .font(ZogTheme.subtitleFont)
                                .foregroundStyle(ZogTheme.foregroundMuted)
                                .lineLimit(1)
                        }
                        .frame(minWidth: 80, maxWidth: 160, alignment: .leading)

                        HStack(spacing: 14) {
                            Button { media.previous() } label: {
                                SFIcon(systemName: "backward.fill", size: 11)
                            }.buttonStyle(.plain)

                            Button { media.playPause() } label: {
                                SFIcon(
                                    systemName: track.isPlaying ? "pause.fill" : "play.fill",
                                    size: 12
                                )
                            }.buttonStyle(.plain)

                            Button { media.next() } label: {
                                SFIcon(systemName: "forward.fill", size: 11)
                            }.buttonStyle(.plain)
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.96)))
            }
        }
        .animation(ZogTheme.appearEase, value: media.track?.title)
    }

    @ViewBuilder
    private func artwork(_ track: NowPlayingService.Track) -> some View {
        Group {
            if let art = track.artwork {
                Image(nsImage: art)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Color.black.opacity(0.45)
                    SFIcon(systemName: "music.note", size: 12, color: ZogTheme.foregroundMuted)
                }
            }
        }
        .frame(width: 28, height: 28)
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}
