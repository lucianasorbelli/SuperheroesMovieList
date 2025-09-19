//
//  SearchCriteria.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

public enum SearchCriteria: Equatable{
    case allMovies, searchByTitle(String)
    
    var parameters: [String: String] {
        switch self {
        case .allMovies:
            return [:]
        case .searchByTitle(let title):
            return ["Title": title]
        }
    }
}
