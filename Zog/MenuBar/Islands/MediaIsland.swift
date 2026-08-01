import AppKit
import SwiftUI

/// Center media island — square art, title/artist stack, transport
/// (matches Alone / MPH reference).
struct MediaIsland: View {
    @ObservedObject var media: NowPlayingService

    var body: some View {
        Group {
            if let track = media.track {
                IslandContainer(height: ZogTheme.mediaIslandHeight, cornerRadius: ZogTheme.mediaRadius) {
                    HStack(spacing: 10) {
                        artwork(track)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(track.title)
                                .font(ZogTheme.titleFont)
                                .foregroundStyle(ZogTheme.foreground)
                                .lineLimit(1)
                            Text(track.artist.isEmpty ? " " : track.artist)
                                .font(ZogTheme.subtitleFont)
                                .foregroundStyle(ZogTheme.foregroundMuted)
                                .lineLimit(1)
                        }
                        .frame(minWidth: 72, maxWidth: 140, alignment: .leading)

                        HStack(spacing: 12) {
                            Button { media.previous() } label: {
                                SFIcon(systemName: "backward.fill", size: 10)
                            }.buttonStyle(.plain)

                            Button { media.playPause() } label: {
                                SFIcon(
                                    systemName: track.isPlaying ? "pause.fill" : "play.fill",
                                    size: 11
                                )
                            }.buttonStyle(.plain)

                            Button { media.next() } label: {
                                SFIcon(systemName: "forward.fill", size: 10)
                            }.buttonStyle(.plain)
                        }
                    }
                }
                .transition(.opacity)
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
                    Color.black.opacity(0.5)
                    SFIcon(systemName: "music.note", size: 11, color: ZogTheme.foregroundMuted)
                }
            }
        }
        .frame(width: 26, height: 26)
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}
