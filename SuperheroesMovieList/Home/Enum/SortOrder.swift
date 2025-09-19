//
//  SortOrder.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

public enum SortCriteria: String, CaseIterable {
    case descending = "desc"
    case ascending = "asc"
    
    var displayName: String {
        switch self {
        case .descending:
            return "↓ Sort"
        case .ascending:
            return "↑ Sort"
        }
    }
    
    mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
}
