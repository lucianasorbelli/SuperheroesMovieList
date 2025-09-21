//
//  MovieRowView.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import SwiftUI

struct MovieRowView: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(movie.title)
                .accessibilityIdentifier("name")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("\(movie.year)")
                        .accessibilityIdentifier("year")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.white)
                    Text("ID: \(movie.imdbID)")
                        .accessibilityIdentifier("imdb")
                        .font(.caption)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.clear)
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}
