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
    var fetchBreedDetail: (_ id: String) async throws -> Breed?
}

extension DependencyValues {
    var apiManager: APIManager {
        get { self[APIManager.self] }
        set { self[APIManager.self] = newValue}
    }
}

extension APIManager: DependencyKey {
    static let liveValue = APIManager(
        fetchBreeds: { page in
            guard var components = URLComponents(string: "https://api.thecatapi.com/v1/breeds") else {
                return []
            }
            components.queryItems = [
                URLQueryItem(name: "limit", value: "25"),
                URLQueryItem(name: "page", value: "\(page)")
            ]
            
            guard let url = components.url else {
                return []
            }
            
            var request = URLRequest(url: url)
            request.setValue("", forHTTPHeaderField: "x-api-key")
            
            do {
                let (data, _) = try await URLSession.shared.data(for: request)
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("\(jsonString)")
                }
                return try jsonDecoder.decode([Breed].self, from: data)
            } catch {
                print(error)
                return []
            }
        },
        searchBreeds: { query in
            guard var components = URLComponents(string: "https://api.thecatapi.com/v1/breeds/search") else {
                return []
            }
            components.queryItems = [
                URLQueryItem(name: "q", value: "\(query)")]
            
            guard let url = components.url else {
                return []
            }
            
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try jsonDecoder.decode([Breed].self, from: data)
        },
        fetchBreedDetail: { id in
            guard var components = URLComponents(string: "https://api.thecatapi.com/v1/breeds/\(id)") else {
                return nil
            }
            
            guard let url = components.url else {
                return nil
            }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            return try jsonDecoder.decode(Breed.self, from: data)
        }
    )
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  return decoder
}()

