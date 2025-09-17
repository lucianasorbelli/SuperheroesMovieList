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
    var defaultSortCriteria: SortCriteria { get }
    var viewState: HomeViewModel.HomeViewState { get }
    
    func searchMovies()
    func closeTextField()
    func loadFullMovies()
    func loadMoreMovies()
    func executeCurrentService()
    func sortByYear()
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
    @Published var defaultSortCriteria: SortCriteria = .ascending
    
    private var currentPage: Int = 1
    private var canLoadMorePages = true
    private var currentTask: Task<Void, Never>?
    private let networkService: MovieAPIServiceProtocol
    
    init(networkService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.networkService = networkService
        loadFullMovies()
    }
    
    func loadFullMovies() {
        currentTask?.cancel()
        currentTask = Task {
            await MainActor.run { [weak self] in
                self?.updateViewState(.loading)
                self?.currentPage = 1
                self?.searchCriteria = .allMovies
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
                self.updateViewState(.error)
            }
        }
    }
    
    func loadMoreMovies() {
        currentTask?.cancel()
        currentTask = Task {
            if canLoadMorePages && !isLoadingMore {
                await MainActor.run { [weak self] in
                    self?.isLoadingMore = true
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
                    case .searchByTitle(_):
                        response = try await networkService.fetchMovies(page: nextPage, parameters: ["Title": "\(searchText)"])
                        await MainActor.run { [weak self] in
                            self?.currentPage = nextPage
                            self?.canLoadMorePages = nextPage < response.totalPages
                            self?.isLoadingMore = false
                            self?.moviesFiltered.append(contentsOf: response.data)
                        }
                    }
                } catch {
                    self.isLoadingMore = false
                    self.updateViewState(.error)
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
        currentTask?.cancel()
        currentTask = Task {
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
    
    func sortByYear() {
        if !isLoadingMore {
            switch defaultSortCriteria {
            case .ascending:
                moviesFiltered.sort { $0.year < $1.year }
            case .descending:
                moviesFiltered.sort { $0.year > $1.year }
            }
            defaultSortCriteria.toggle()
        }
    }
}
