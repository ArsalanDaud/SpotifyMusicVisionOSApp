//
//  SearchBar.swift
//  SpotifyVisionOSApp
//
//  Created by ADJ on 04/11/2024.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    @State var onCommit: () -> Void
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) { // Align "x" button at trailing
                TextField("What do you want to listen to?", text: $text, onCommit: onCommit)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black) // Set text color to dark black
                    .shadow(color: .white.opacity(0.5), radius: 4, x: 0, y: 2) // White shadow for text field
                    .padding(.horizontal)
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .background(Color.clear)
                            .foregroundColor(Color.red.opacity(0.9))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.trailing, 20) // Add padding for placement
                    .opacity(text.isEmpty ? 0 : 1)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
