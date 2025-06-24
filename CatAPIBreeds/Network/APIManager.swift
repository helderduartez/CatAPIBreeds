//
//  APIManager.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import Foundation

@DependencyClient
struct APIManager {
    var fetchBreeds: (_ page: Int) async throws -> [Breed]
    var searchBreeds: (_ query: String) async throws -> [Breed]
    
}

extension DependencyValues {
    var apiManager: APIManager {
        get { self[APIManager.self] }
        set { self[APIManager.self] = newValue}
    }
}

extension APIManager: TestDependencyKey {
    static let previewValue = Self(
        fetchBreeds: { _ in Breed.mockArray },
        searchBreeds: { _ in Breed.mockArray }
    )
    
    static let testValue = Self(
        fetchBreeds: unimplemented("\(Self.self).fetchBreeds"),
        searchBreeds: unimplemented("\(Self.self).searchBreeds")
    )
}

enum APIManagerError: Equatable, LocalizedError, Sendable {
    case invalidURL
    case invalidRequest
    case invalidData
    case network
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidRequest:
            return "Invalid Request"
        case .invalidData:
            return "Invalid Data"
        case .network:
            return "We couldn’t find any cat breeds. The first time you use this app, you need to be connected to the internet to download data."
        }
    }
}

extension APIManager: DependencyKey {
    static let liveValue = APIManager(
        fetchBreeds: { page in
            guard var components = URLComponents(string: "https://api.thecatapi.com/v1/breeds") else {
                throw APIManagerError.invalidURL
            }
            components.queryItems = [
                URLQueryItem(name: "limit", value: "25"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            
            guard let url = components.url else {
                throw APIManagerError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue(APIManager.getAPIKey(), forHTTPHeaderField: "x-api-key")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                do {
                    return try jsonDecoder.decode([Breed].self, from: data)
                } catch {
                    throw APIManagerError.invalidData
                }
            } catch {
                throw APIManagerError.network
            }
        },
        searchBreeds: { query in
            guard var components = URLComponents(string: "https://api.thecatapi.com/v1/breeds/search") else {
                throw APIManagerError.invalidURL
            }
            components.queryItems = [
                URLQueryItem(name: "q", value: "\(query)")]
            
            guard let url = components.url else {
                throw APIManagerError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.setValue(APIManager.getAPIKey(), forHTTPHeaderField: "x-api-key")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                do {
                    return try jsonDecoder.decode([Breed].self, from: data)
                } catch {
                    throw APIManagerError.invalidData
                }
            } catch {
                throw APIManagerError.network
            }
        }
    )
    
    static func getAPIKey() -> String {
        if let url = Bundle.main.url(forResource: "APISecret", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let apiKey = plist["CatAPIKey"] as? String {
            return apiKey
        }
        return ""
    }
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    return decoder
}()

