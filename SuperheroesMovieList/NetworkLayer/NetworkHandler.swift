//
//  NetworkHandler.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import Foundation

protocol MovieAPIServiceProtocol {
    func searhMovies(title: String) async throws -> MovieResponseDTO
    func fetchMovies(page: Int, parameters: [String: String]) async throws -> MovieResponseDTO
}

class MovieAPIService: MovieAPIServiceProtocol {
    private let baseURL = "https://jsonmock.hackerrank.com/api/moviesdata"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    
    func searhMovies(title: String) async throws -> MovieResponseDTO {
        guard let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)?Title=\(encodedTitle)") else {
            throw MovieAPIError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func fetchMovies(page: Int, parameters: [String: String] = [:]) async throws -> MovieResponseDTO {
        var urlComponents = URLComponents(string: baseURL)!
        
        urlComponents.queryItems = [URLQueryItem(name: "page", value: String(page))]
        
        for (key, value) in parameters {
            urlComponents.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        guard let url = urlComponents.url else {
            throw MovieAPIError.invalidURL
        }
        
        return try await performRequest(url: url)
    }
    
    private func performRequest(url: URL) async throws -> MovieResponseDTO {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw MovieAPIError.unknown
            }
            
            guard httpResponse.statusCode == 200 else {
                throw MovieAPIError.serverError(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw MovieAPIError.noData
            }
            
            do {
                let moviesResponse = try JSONDecoder().decode(MovieResponseDTO.self, from: data)
                return moviesResponse
            } catch {
                throw MovieAPIError.decodingError(error)
            }
            
        } catch let error as MovieAPIError {
            throw error
        } catch {
            throw MovieAPIError.networkError(error)
        }
    }
}

