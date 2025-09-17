//
//  NetworkError.swift
//  SuperheroesMovieList
//
//  Created by Luciana Sorbelli on 17/09/2025.
//

import Foundation

enum MovieAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int)
    case unknown
   
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .noData:
            return "No se recibieron datos"
        case .decodingError(let error):
            return "Error al decodificar datos: \(error.localizedDescription)"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Error del servidor: \(statusCode)"
        case .unknown:
            return "Error desconocido"
        }
    }
}
