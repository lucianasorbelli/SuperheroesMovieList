//
//  MockMovieAPIService.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 19/09/2025.
//

import SuperheroesMovieList

class MockMovieAPIService: MovieAPIServiceProtocol {
    
    var fetchMoviesResult: Result<MovieResponseDTO, Error> = .failure(NetworkError.invalidResponse)
    var searchMoviesResult: Result<MovieResponseDTO, Error> = .failure(NetworkError.invalidResponse)
    
    var fetchMoviesCalled = false
    var searchMoviesCalled = false
    
    func fetchMovies(page: Int, parameters: [String : String]) async throws -> MovieResponseDTO {
        fetchMoviesCalled = true
        switch fetchMoviesResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
    
    func searhMovies(title: String) async throws -> MovieResponseDTO {
        searchMoviesCalled = true
        switch searchMoviesResult {
        case .success(let response):
            return response
        case .failure(let error):
            throw error
        }
    }
}
