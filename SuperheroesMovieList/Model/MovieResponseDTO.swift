//
//  MovieResponseDTO.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import Foundation

public struct MovieResponseDTO: Codable {
    let page, perPage, total, totalPages: Int
    let data: [Movie]
    
    enum CodingKeys: String, CodingKey {
        case page
        case perPage = "per_page"
        case total
        case totalPages = "total_pages"
        case data
    }
}

public struct Movie: Codable, Identifiable, Equatable {
    let title: String
    let year: Int
    let imdbID: String
    
    public var id: String { imdbID }

    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case year = "Year"
        case imdbID
    }
}
