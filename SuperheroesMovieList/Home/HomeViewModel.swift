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
    func searchMovies() async
    func loadFullMovies() async
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
    
    @Published var searchText: String = ""
    @Published var isLoadingMore: Bool = false
    @Published var moviesFiltered: [Movie] = []
    @Published var viewState: HomeViewState = .loading
    @Published var searchCriteria: SearchCriteria = .allMovies
    
    private var currentPage: Int = 1
    private let networkService: MovieAPIServiceProtocol
    
    init(networkService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.networkService = networkService
        Task {
            await loadFullMovies()
        }
    }
    
    func loadFullMovies() async {
        await MainActor.run {
            searchCriteria = .allMovies
            viewState = .loading
        }
        do {
            let response = try await networkService.fetchMovies(page: currentPage,
                                                                parameters: searchCriteria.parameters)
            await MainActor.run { [weak self] in
                self?.movies = response.data
                response.data.isEmpty ? self?.updateViewState(.empty) : self?.updateViewState(.content)
            }
        } catch {
            updateViewState(.error)
        }
    }
    
    private func updateViewState(_ newState: HomeViewState) {
        Task {
            await MainActor.run { [weak self] in
                self?.viewState = newState
            }
        }
    }
    
    func performNewSearch() async {
        await MainActor.run { [weak self] in
            self?.viewState = .loading
            self?.currentPage = 1
            self?.moviesFiltered = []
            self?.searchCriteria = .searchByTitle(self?.searchText ?? "")
        }
        
        do {
            let response = try await networkService.searhMovies(title: searchText)
            await MainActor.run { [weak self] in
                self?.moviesFiltered = response.data
                response.data.isEmpty ? self?.updateViewState(.empty) : self?.updateViewState(.content)
            }
        } catch let error {
            updateViewState(.error)
        }
    }
    
    func searchMovies() async {
        if searchText.isEmpty {
            await loadFullMovies()
        } else if searchText.count >= 3 {
            await performNewSearch()
        }
    }
    
    func closeTextField() {
        
    }
}

