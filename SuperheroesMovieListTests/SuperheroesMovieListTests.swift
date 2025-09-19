//
//  SuperheroesMovieListTests.swift
//  SuperheroesMovieListTests
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import XCTest
import Combine
@testable import SuperheroesMovieList

final class SuperheroesMovieListTests: XCTestCase {
    
    var viewModel: HomeViewModel!
    var mockNetworkService: MockMovieAPIService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockMovieAPIService()
        viewModel = HomeViewModel(networkService: mockNetworkService)
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        cancellables = nil
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.movies.count, 0)
        XCTAssertEqual(viewModel.moviesFiltered.count, 0)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertFalse(viewModel.isLoadingMore)
        XCTAssertFalse(viewModel.canLoadMorePages)
        XCTAssertNil(viewModel.selectedMovie)
        XCTAssertFalse(viewModel.isSheetPresented)
        XCTAssertEqual(viewModel.viewState, .loading)
        XCTAssertEqual(viewModel.defaultSortCriteria, .ascending)
    }
    
    func testLoadFullMoviesSuccess() async {
        // Given
        let expectedMovies = [Movie.mock(), Movie.mock()]
        
        let response = MovieResponseDTO(page: 1,
                                        perPage: 10,
                                        total: 10,
                                        totalPages: 2,
                                        data: expectedMovies)
        
        mockNetworkService.fetchMoviesResult = .success(response)
        
        // When
        viewModel.loadFullMovies()
        await waitForAsyncOperation()
        
        XCTAssertEqual(viewModel.movies.count, 2)
        XCTAssertEqual(viewModel.moviesFiltered.count, 2)
        XCTAssertTrue(viewModel.canLoadMorePages)
        XCTAssertEqual(viewModel.viewState, .content)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.searchCriteria, .allMovies)
    }
    
    func testLoadFullMoviesEmpty() async {
        // Given
        let mockResponse = MovieResponseDTO(page: 1,
                                            perPage: 10,
                                            total: 10,
                                            totalPages: 1,
                                            data: [])
        
        mockNetworkService.fetchMoviesResult = .success(mockResponse)
        
        // When
        viewModel.loadFullMovies()
        
        await waitForAsyncOperation()
        XCTAssertEqual(viewModel.movies.count, 0)
    }
    
    func testLoadFullMoviesWithExistingMovies() async {
        // Given
        let existingMovies = [Movie.mock()]
        viewModel.movies = existingMovies
        
        // When
        viewModel.loadFullMovies()
        
        await waitForAsyncOperation()
        XCTAssertEqual(viewModel.moviesFiltered.count, 1)
    }
    
    // MARK: - Load More Movies Tests
    
    func testLoadMoreMoviesSuccess() async {
        // Given
        let initialMovies = [Movie.mock()]
        let moreMovies = [Movie.mock(), Movie.mock()]
        
        let mockResponse = MovieResponseDTO(page: 2,
                                            perPage: 2,
                                            total: 10,
                                            totalPages: 3,
                                            data: moreMovies)
        
        viewModel.movies = initialMovies
        viewModel.canLoadMorePages = true
        mockNetworkService.fetchMoviesResult = .success(mockResponse)
        
        // When
        viewModel.loadMoreMovies()
        
        await waitForAsyncOperation()
        
        XCTAssertEqual(viewModel.movies.count, 3)
        XCTAssertTrue(viewModel.canLoadMorePages)
        XCTAssertFalse(viewModel.isLoadingMore)
    }
    
    func testLoadMoreMoviesError() async {
        // Given
        viewModel.canLoadMorePages = true
        mockNetworkService.fetchMoviesResult = .failure(NetworkError.invalidResponse)
        
        // When
        viewModel.loadMoreMovies()
        
        await waitForAsyncOperation()
        
        XCTAssertFalse(viewModel.isLoadingMore)
        XCTAssertEqual(viewModel.viewState, .error)
    }
    
    // MARK: - Search Tests
    
    func testSearchMoviesWithEmptyText() async {
        // Given
        let initialMovies = [Movie.mock()]
        viewModel.movies = initialMovies
        
        // When
        viewModel.searchText = ""
        viewModel.searchMovies()
        
        await waitForAsyncOperation()
        
        XCTAssertEqual(viewModel.searchCriteria, .allMovies)
    }
    
    func testSearchMoviesWithValidText() async {
        // Given
        let searchResults = [Movie.mock()]
        
        let mockResponse = MovieResponseDTO(page: 1,
                                            perPage: 1,
                                            total: 10,
                                            totalPages: 1,
                                            data: searchResults)
        
        viewModel.searchText = "Batman"
        mockNetworkService.searchMoviesResult = .success(mockResponse)
        
        // When
        viewModel.searchMovies()
        
        await waitForAsyncOperation()
        
        XCTAssertEqual(viewModel.moviesFiltered.count, 1)
        XCTAssertEqual(viewModel.searchCriteria, .searchByTitle("Batman"))
    }
    
    func testSearchMoviesError() async {
        // Given
        viewModel.searchText = "Batman"
        mockNetworkService.searchMoviesResult = .failure(NetworkError.invalidResponse)
        
        // When
        viewModel.searchMovies()
        
        await waitForAsyncOperation()
        XCTAssertEqual(viewModel.viewState, .error)
    }
    
    // MARK: - Sort Tests
    
    func testSortByYearAscending() {
        // Given
        let movie1 = Movie.mock(year: 2020)
        let movie2 = Movie.mock(year: 2021)
        let movie3 = Movie.mock(year: 2019)
        
        viewModel.moviesFiltered = [movie1, movie2, movie3]
        viewModel.defaultSortCriteria = .ascending
        
        // When
        viewModel.sortByYear()
        
        XCTAssertEqual(viewModel.moviesFiltered[0].year, 2019)
        XCTAssertEqual(viewModel.moviesFiltered[1].year, 2020)
        XCTAssertEqual(viewModel.moviesFiltered[2].year, 2021)
        XCTAssertEqual(viewModel.defaultSortCriteria, .descending)
    }
    
    func testSortByYearDescending() {
        // Given
        let movie1 = Movie.mock(year: 2020)
        let movie2 = Movie.mock(year: 2021)
        let movie3 = Movie.mock(year: 2019)
        
        viewModel.moviesFiltered = [movie1, movie2, movie3]
        viewModel.defaultSortCriteria = .descending
        
        // When
        viewModel.sortByYear()
        
        // Then
        XCTAssertEqual(viewModel.moviesFiltered[0].year, 2021)
        XCTAssertEqual(viewModel.moviesFiltered[1].year, 2020)
        XCTAssertEqual(viewModel.moviesFiltered[2].year, 2019)
        XCTAssertEqual(viewModel.defaultSortCriteria, .ascending)
    }
    
    func testSortByYearWhenLoading() {
        // Given
        viewModel.isLoadingMore = true
        let initialMovies = [Movie.mock()]
        viewModel.moviesFiltered = initialMovies
        
        // When
        viewModel.sortByYear()
        
        XCTAssertEqual(viewModel.moviesFiltered, initialMovies)
    }
    
    // MARK: - Movie Selection Tests
    
    func testDidTapMovie() {
        // Given
        let movie = Movie.mock()
        
        // When
        viewModel.didTap(movie)
        XCTAssertEqual(viewModel.selectedMovie, movie)
        XCTAssertTrue(viewModel.isSheetPresented)
    }
    
    func testDidTapMovieTwice() {
        // Given
        let movie = Movie.mock()
        
        // When
        viewModel.didTap(movie)
        viewModel.didTap(movie)
        
        XCTAssertEqual(viewModel.selectedMovie, movie)
        XCTAssertFalse(viewModel.isSheetPresented)
    }
    
    // MARK: - Close TextField Tests
    func testCloseTextField() {
        // Given
        viewModel.searchText = "Batman"
        
        // When
        viewModel.closeTextField()
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    func testMoviesDidSetUpdatesMoviesFiltered() {
        // Given
        let movies = [Movie.mock(), Movie.mock()]
        
        // When
        viewModel.movies = movies
        
        XCTAssertEqual(viewModel.moviesFiltered.count, 2)
        XCTAssertEqual(viewModel.moviesFiltered, movies)
    }
    
    // MARK: - Helper Method
    private func waitForAsyncOperation() async {
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
}

extension Movie {
    static func mock(year: Int = 2020) -> Movie {
        return Movie(
            title:"Mock Movie",
            year: year,
            imdbID: UUID().uuidString
        )
    }
}

enum NetworkError: Error {
    case invalidResponse
    case noData
}
