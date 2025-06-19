//
//  Breeds.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//
import SwiftUI
import ComposableArchitecture

struct Breed: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let image: ImageURL?
    let origin: String?
    let temperament: String?
    let lifeSpan: String?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, image, origin, temperament, description
        case lifeSpan = "life_span"
    }
    
    struct ImageURL: Codable, Equatable {
        let url: URL
    }
}

enum BreedError: String, Equatable, Error {
    case invalidResponde = "Invalid Response"
    case invalidURL = "Invalid URL"
}
