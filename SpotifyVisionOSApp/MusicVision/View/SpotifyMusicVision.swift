//
//  SpotifyMusicVision.swift
//  SpotifyVisionOSApp
//
//  Created by ADJ on 04/11/2024.
//

import SwiftUI

struct SpotifyMusicVisionView: View {
    
    @State private var searchText = ""
    @StateObject private var musicVisionViewModel = MusicVisionViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Music Vision")
                    .bold()
                    .padding()
                    .font(.largeTitle)
                    .foregroundColor(Color.white)
                SearchBar(text: $searchText, onCommit: {
                    musicVisionViewModel.searchMusic(query: searchText)
                })
                .padding(.all)
                ScrollView {
                    if musicVisionViewModel.music.isEmpty {
                        VStack {
                            Text("Play what you love")
                                .bold()
                                .font(.title)
                                .foregroundColor(Color.white)
                            Text("Search for artists, songs, playlists and more")
                                .foregroundColor(Color.white)
                        }
                    }
                    ForEach(musicVisionViewModel.music) { music in
                        NavigationLink(destination: SpotifyListenTrack(music: music)) {
                            HStack(alignment: .top, spacing: 10) {
                                if let url = URL(string: music.trackImage) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(10)
                                            .padding(.horizontal)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    }
                                }
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(music.trackName)
                                        .bold()
                                        .font(.title)
                                    Text(music.artistName)
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    Text(music.trackDuration)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Text(music.albumArt)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.black)
            .onChange(of: searchText) {
                if !searchText.isEmpty {
                    musicVisionViewModel.searchMusic(query: searchText)
                } else {
                    musicVisionViewModel.music = [] // Clear results when search is cleared
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
#Preview {
    SpotifyMusicVisionView()
}
