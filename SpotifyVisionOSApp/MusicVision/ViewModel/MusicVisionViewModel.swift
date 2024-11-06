//
//  MusicVisionViewModel.swift
//  SpotifyVisionOSApp
//
//  Created by ADJ on 04/11/2024.
//

import Foundation

class MusicVisionViewModel: ObservableObject {
    
    @Published var music: [MusicVision] = []
    private var accessToken: String?
    
    init() {
        fetchSpotifyAccessToken { [weak self] token in
            self?.accessToken = token
            if let token = token {
                print("Access Token fetched: \(token)")
            } else {
                print("Failed to fetch access token.")
            }
        }
    }
    
    func fetchSpotifyAccessToken(completion: @escaping (String?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let clientId = "51d093952986430da0a23da05535a295"
        let clientSecret = "7b901fd490974b9fbf008c888cd4221c"
        let credentials = "\(clientId):\(clientSecret)"
        let base64Credentials = Data(credentials.utf8).base64EncodedString()

        request.addValue("Basic \(base64Credentials)", forHTTPHeaderField: "Authorization")
        
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching access token: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let accessToken = json["access_token"] as? String {
                completion(accessToken)
            } else {
                print("Failed to parse access token from response.")
                completion(nil)
            }
        }
        task.resume()
    }
    func searchMusic(query: String) {
        guard let token = accessToken,
              let url = URL(string: "https://api.spotify.com/v1/search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&type=track&limit=10")
        else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch music data:", error?.localizedDescription ?? "Unknown error")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(SpotifySearchResult.self, from: data)
                DispatchQueue.main.async {
                    self?.music = result.tracks.items.map { track in
                        MusicVision(
                            trackName: track.name,
                            artistName: track.artists.first?.name ?? "Unknown Artist",
                            albumArt: track.album.name,
                            trackImage: track.album.images.first?.url ?? "",
                            trackDuration: self?.formatDuration(track.duration_ms) ?? "",
                            trackURI: track.uri
                        )
                    }
                }

            } catch {
                print("Error decoding Spotify data:", error)
            }
        }
        task.resume()
    }
    func fetchTrackURL(with id: String) async -> URL? {
        guard let token = accessToken, let url = URL(string: "https://api.spotify.com/v1/tracks/\(id)") else {
            print("Error forming API URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                guard httpResponse.statusCode == 200 else {
                    print("Invalid response from server with status code: \(httpResponse.statusCode)")
                    return nil
                }
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("JSON Response: \(json)")
                
                if let audioURLString = json["preview_url"] as? String,
                   let audioURL = URL(string: audioURLString) {
                    return audioURL
                } else {
                    print("Error parsing JSON or audio URL not found.")
                }
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
        return nil
    }
    func filteredMusic(for searchText: String) -> [MusicVision] {
        if searchText.isEmpty {
            return music
        } else {
            return music.filter { music in
                music.trackName.localizedCaseInsensitiveContains(searchText) ||
                music.artistName.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    private func formatDuration(_ durationMs: Int) -> String {
        let seconds = durationMs / 1000
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
