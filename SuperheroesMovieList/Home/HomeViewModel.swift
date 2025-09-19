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
    var selectedMovie: Movie? { get }
    var searchText: String { get set }
    var moviesFiltered: [Movie] { get }
    var isSheetPresented: Bool { set get }
    var defaultSortCriteria: SortCriteria { get }
    var viewState: HomeViewModel.HomeViewState { get }
    
    func sortByYear()
    func searchMovies()
    func closeTextField()
    func loadFullMovies()
    func loadMoreMovies()
    func didTap(_ movie: Movie)
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
    
    @Published var selectedMovie: Movie?
    @Published var searchText: String = ""
    @Published var isLoadingMore: Bool = false
    @Published var moviesFiltered: [Movie] = []
    @Published var isSheetPresented: Bool = false
    @Published var viewState: HomeViewState = .loading
    @Published var searchCriteria: SearchCriteria = .allMovies
    @Published var defaultSortCriteria: SortCriteria = .ascending
    
    var canLoadMorePages = false
    private var currentPage: Int = 1
    private let networkService: MovieAPIServiceProtocol
    
    init(networkService: MovieAPIServiceProtocol = MovieAPIService()) {
        self.networkService = networkService
        loadFullMovies()
    }
    
    func loadFullMovies() {
        searchText = ""
        canLoadMorePages = false
        Task {
            await MainActor.run { [weak self] in
                self?.updateViewState(.loading)
                self?.currentPage = 1
                self?.searchCriteria = .allMovies
            }
            
            if !(self.movies.isEmpty) {
                await MainActor.run { [weak self] in
                    self?.moviesFiltered = self?.movies ?? []
                    self?.updateViewState(.content)
                }
                return
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
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard canLoadMorePages, !isLoadingMore else { return }
            isLoadingMore = true
            
            let nextPage = currentPage + 1
            do {
                let response: MovieResponseDTO
                switch searchCriteria {
                case .allMovies:
                    response = try await networkService.fetchMovies(page: nextPage, parameters: searchCriteria.parameters)
                    currentPage = nextPage
                    canLoadMorePages = nextPage < response.totalPages
                    movies.append(contentsOf: response.data)
                    
                case .searchByTitle(_):
                    response = try await networkService.fetchMovies(page: nextPage, parameters: ["Title": "\(searchText)"])
                    currentPage = nextPage
                    canLoadMorePages = nextPage < response.totalPages
                    moviesFiltered.append(contentsOf: response.data)
                }
                
                isLoadingMore = false
            } catch {
                isLoadingMore = false
                updateViewState(.error)
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
    
    func didTap(_ movie: Movie) {
        selectedMovie =  movie
        isSheetPresented.toggle()
    }
    
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
