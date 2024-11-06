//
//  MusicVision.swift
//  SpotifyVisionOSApp
//
//  Created by ADJ on 04/11/2024.
//

import Foundation

struct SpotifySearchResult: Codable {
    let tracks: TrackResponse
}
struct TrackResponse: Codable {
    let items: [Track]
}
struct Track: Codable {
    let name: String
    let duration_ms: Int
    let artists: [Artist]
    let album: Album
    let uri: String
}
struct Artist: Codable {
    let name: String
}
struct Album: Codable {
    let name: String
    let images: [AlbumImage]
}
struct AlbumImage: Codable {
    let url: String
}
struct MusicVision: Identifiable {
    var id = UUID()
    let trackName: String
    let artistName: String
    let albumArt: String
    let trackImage: String
    let trackDuration: String
    let trackURI: String
}
