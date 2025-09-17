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
        VStack(alignment: .leading, spacing: 8) {
            Text(movie.title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(movie.year)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("ID: \(movie.imdbID)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.vertical, 4)
    }
}
