//
//  MovieDetailSheetView.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 18/09/2025.
//

import SwiftUI

struct MovieDetailSheetView: View {
    let movie: Movie
    
    var body: some View {
        VStack(spacing: 16) {
            Text(movie.title)
                .font(.title)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            Text("Year: \(movie.year)")
                .font(.subheadline)
        }
        .padding(20)
    }
}
