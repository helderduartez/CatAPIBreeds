//
//  Breeds.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//
import SwiftUI
import SwiftData
import ComposableArchitecture

struct Breed: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let image: ImageURL?
    let origin: String?
    let temperament: String?
    let lifeSpan: String?
    let breedDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, image, origin, temperament
        case breedDescription = "description"
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

@Model
class BreedDB {
    @Attribute(.unique) var id: String
    var name: String
    var image: URL?
    var origin: String?
    var temperament: String?
    var lifeSpan: String?
    var breedDescription: String?
    var isFavorite: Bool = false
    var isBeingSearched: Bool = false
    
    init(id: String, name: String, image: URL?, origin: String?, temperament: String?, lifeSpan: String?, breedDescription: String?, isFavorite: Bool, isBeingSearched: Bool) {
        self.id = id
        self.name = name
        self.image = image
        self.origin = origin
        self.temperament = temperament
        self.lifeSpan = lifeSpan
        self.breedDescription = breedDescription
        self.isFavorite = isFavorite
        self.isBeingSearched = isBeingSearched
    }
    
    
    convenience init(item: Breed) {
        self.init(id: item.id, name: item.name, image: item.image?.url, origin: item.origin, temperament: item.temperament, lifeSpan: item.lifeSpan, breedDescription: item.breedDescription, isFavorite: false, isBeingSearched: false)
    }
}
