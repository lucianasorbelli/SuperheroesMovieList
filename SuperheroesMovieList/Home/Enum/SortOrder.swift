//
//  SortOrder.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

enum SortCriteria: String, CaseIterable {
    case descending = "desc"
    case ascending = "asc"
    
    var displayName: String {
        switch self {
        case .descending:
            return "↓ Order"
        case .ascending:
            return "↑ Order"
        }
    }
    
    mutating func toggle() {
        self = (self == .ascending) ? .descending : .ascending
    }
    
}
