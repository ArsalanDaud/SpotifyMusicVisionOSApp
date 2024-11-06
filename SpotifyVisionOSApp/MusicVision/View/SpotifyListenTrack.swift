//
//  SpotifyListenMusic.swift
//  SpotifyVisionOSApp
//
//  Created by ADJ on 06/11/2024.
//
import SwiftUI
import AVKit

struct SpotifyListenTrack: View {
    
    @State private var isPlaying = false
    @State private var player: AVPlayer?
    @State private var trackProgress: Double = 0.0
    @StateObject private var musicVisionViewModel = MusicVisionViewModel()
    var music: MusicVision
    
    var body: some View {
        VStack(spacing: 20) {
            Text(music.trackName)
                .bold()
                .padding()
                .font(.largeTitle)
                .foregroundColor(Color.white)
            if let url = URL(string: music.trackImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal)
                } placeholder: {
                    ProgressView()
                        .frame(width: 200, height: 200)
                }
            }
            Text(music.albumArt)
                .font(.title3)
                .foregroundColor(.gray)
            Slider(value: $trackProgress, in: 0...1)
                .accentColor(.white)
                .padding(.horizontal)
                .onChange(of: trackProgress) {
                    if let duration = player?.currentItem?.duration {
                        let totalSeconds = CMTimeGetSeconds(duration)
                        let newTime = CMTime(seconds: totalSeconds * trackProgress, preferredTimescale: 600)
                        player?.seek(to: newTime)
                    }
                }
            HStack(spacing: 30) {
                Button(action: skipBackward) {
                    Image(systemName: "gobackward.15")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: playOrPause) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                Button(action: skipForward) {
                    Image(systemName: "goforward.15")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .onAppear {
            Task {
                await setupPlayer()
                startProgressObserver()
            }
        }
    }

    private func setupPlayer() async {
        let spotifyString = music.trackURI
        let components = spotifyString.split(separator: ":")
        
        guard components.count == 3 else {
            print("Error: Invalid Spotify URI format.")
            return
        }
        
        let id = String(components[2])
        print("Track ID: \(id)")
        
        // Fetch episode URL using the ID
        if let url = await musicVisionViewModel.fetchTrackURL(with: id) {
            player = nil
            player = AVPlayer(url: url)
            player?.play()
            isPlaying = true
        } else {
            print("Error fetching episode URL.")
        }
    }
    private func playOrPause() {
        Task {
            if player == nil {
                await setupPlayer()
            }
            guard let player = player else {
                print("Error: Player not initialized.")
                return
            }
            if let urlAsset = player.currentItem?.asset as? AVURLAsset {
                let url = urlAsset.url
                print("Player URL: \(url)")
            } else {
                print("URL not found.")
            }
            if isPlaying {
                player.pause()
            } else {
                player.play()
            }
            isPlaying.toggle()
        }
    }
    private func skipForward() {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeGetSeconds(currentTime) + 15
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }
    private func skipBackward() {
        guard let currentTime = player?.currentTime() else { return }
        let newTime = CMTimeGetSeconds(currentTime) - 15
        player?.seek(to: CMTime(seconds: newTime, preferredTimescale: 600))
    }
    private func startProgressObserver() {
        player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 600), queue: .main) { time in
            guard let duration = self.player?.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(time)
            let totalDuration = CMTimeGetSeconds(duration)
            self.trackProgress = currentTime / totalDuration
        }
    }
}

