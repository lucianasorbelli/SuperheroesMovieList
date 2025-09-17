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
    
    func searchMovies()
    func closeTextField()
    func loadFullMovies()
    func loadMoreMovies()
    func executeCurrentService()
}

final class HomeViewModel: HomeViewModeling {
    
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
    private var canLoadMorePages = true
    private let networkService: MovieAPIServiceProtocol
    
    init(networkService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.networkService = networkService
        loadFullMovies()
    }
    
    func loadFullMovies() {
        Task {
            await MainActor.run {
                searchCriteria = .allMovies
                viewState = .loading
            }
            do {
                let response = try await networkService.fetchMovies(page: currentPage,
                                                                    parameters: searchCriteria.parameters)
                await MainActor.run { [weak self] in
                    self?.movies = response.data
                    self?.canLoadMorePages = self?.currentPage ?? 1 < response.totalPages
                    response.data.isEmpty ? self?.updateViewState(.empty) : self?.updateViewState(.content)
                }
            } catch {
                updateViewState(.error)
            }
        }
    }
    
    func loadMoreMovies() {
        Task {
            if canLoadMorePages && !isLoadingMore {
                await MainActor.run {
                    isLoadingMore = true
                }
                do {
                    let nextPage = currentPage + 1
                    let response: MovieResponseDTO
                    
                    switch searchCriteria {
                    case .allMovies:
                        response = try await networkService.fetchMovies(page: nextPage, parameters: searchCriteria.parameters)
                        await MainActor.run { [weak self] in
                            self?.currentPage = nextPage
                            self?.canLoadMorePages = nextPage < response.totalPages
                            self?.isLoadingMore = false
                            self?.movies.append(contentsOf: response.data)
                        }
                    case .searchByTitle(let string):
                        response = try await networkService.fetchMovies(page: nextPage, parameters: ["Title": "\(searchText)"])
                        await MainActor.run { [weak self] in
                            self?.currentPage = nextPage
                            self?.canLoadMorePages = nextPage < response.totalPages
                            self?.isLoadingMore = false
                            self?.moviesFiltered.append(contentsOf: response.data)
                        }
                    }
                } catch {
                    
                }
            }
        }
    }
    
    private func updateViewState(_ newState: HomeViewState) {
        Task {
            await MainActor.run { [weak self] in
                self?.viewState = newState
            }
        }
    }
    
    func performNewSearch() {
        Task {
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
                    self?.canLoadMorePages = self?.currentPage ?? 1 < response.totalPages
                    response.data.isEmpty ? self?.updateViewState(.empty) : self?.updateViewState(.content)
                }
            } catch let error {
                updateViewState(.error)
            }
        }
    }
    
    func searchMovies() {
        if searchText.isEmpty {
            loadFullMovies()
        } else if searchText.count >= 3 {
            performNewSearch()
        }
    }
    
    func executeCurrentService() {
        switch searchCriteria {
        case .allMovies:
            loadFullMovies()
        case .searchByTitle(_):
            performNewSearch()
        }
    }
    
    func closeTextField() { searchText = "" }
}

