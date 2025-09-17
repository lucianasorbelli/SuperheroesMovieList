//
//  HomeViewModel.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import Combine

protocol HomeViewModeling: ObservableObject {
    var movies: [Movie] { get }
    var isLoadingMore: Bool { get }
    var searchText: String { get set }
    var moviesFiltered: [Movie] { get }
    var viewState: HomeViewModel.HomeViewState { get }
    
    func closeTextField()
    func searchMovies(title: String)
}

final class HomeViewModel: HomeViewModeling {
    
    enum SearchCriteria {
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
    
    enum HomeViewState {
        case loading
        case error
        case content
        case empty
    }
    
    @Published var movies: [Movie] = [] {
        didSet {
            moviesFiltered = movies
        }
    }
    @Published var searchText: String = "" {
        didSet { searchTextDidChange() }
    }
    @Published var isLoadingMore: Bool = false
    @Published var moviesFiltered: [Movie] = []
    @Published var viewState: HomeViewState = .loading
    @Published var searchCriteria: SearchCriteria = .allMovies
    
    private var currentPage: Int = 1
    private let networkService: MovieAPIServiceProtocol
    
    init(networkService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.networkService = networkService
        Task {
            await loadMovies()
        }
    }
    
    func loadMovies() async {
        await MainActor.run {
            searchCriteria = .allMovies
            viewState = .loading
        }
        do {
            let response = try await networkService.fetchMovies(page: currentPage,
                                                                parameters: searchCriteria.parameters)
            
            await MainActor.run {
                movies = response.data
                response.data.isEmpty ? ( viewState = .empty ) : ( viewState = .content )
            }
        } catch {
            
        }
        
    }
    
    private func searchTextDidChange() {
        
    }
    
    func searchMovies(title: String) {
        
    }
    
    func closeTextField() {
        
    }
}

