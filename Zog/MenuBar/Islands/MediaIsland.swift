import AppKit
import SwiftUI

struct MediaIsland: View {
    @ObservedObject var media: NowPlayingService

    var body: some View {
        Group {
            if let track = media.track {
                IslandContainer(height: ZogTheme.mediaIslandHeight, cornerRadius: ZogTheme.mediaRadius) {
                    HStack(spacing: 10) {
                        Group {
                            if let art = track.artwork {
                                Image(nsImage: art).resizable().scaledToFill()
                            } else {
                                ZStack {
                                    Color.black.opacity(0.45)
                                    SFIcon(systemName: "music.note", size: 10, color: ZogTheme.foregroundMuted)
                                }
                            }
                        }
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))

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
                        .frame(minWidth: 64, maxWidth: 130, alignment: .leading)

                        HStack(spacing: 11) {
                            Button { media.previous() } label: {
                                SFIcon(systemName: "backward.fill", size: 9)
                            }.buttonStyle(.plain)
                            Button { media.playPause() } label: {
                                SFIcon(
                                    systemName: track.isPlaying ? "pause.fill" : "play.fill",
                                    size: 10
                                )
                            }.buttonStyle(.plain)
                            Button { media.next() } label: {
                                SFIcon(systemName: "forward.fill", size: 9)
                            }.buttonStyle(.plain)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .animation(ZogTheme.appearEase, value: media.track?.title)
    }
}
