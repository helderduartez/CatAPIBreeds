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

extension Breed {
    static let mock = Self(id: "mock1", name: "mock1 name", image: nil, origin: "mock1 origin", temperament: "mock1 temperament", lifeSpan: "12 - 15", breedDescription: "mock1 desc")
    static let mock2 = Self(id: "mock2", name: "mock2 name", image: nil, origin: "mock2 origin", temperament: "mock2 temperament", lifeSpan: "14 - 15", breedDescription: "mock2 desc")
    static let mockArray = [mock, mock2]
}

@Model
class BreedDB: Equatable {
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
    
    static let mock = BreedDB(item: Breed.mock)
    static let mock2 = BreedDB(item: Breed.mock2)
    static let mockFavorite = BreedDB(id: Breed.mock.id, name: Breed.mock.name, image: Breed.mock.image?.url, origin: Breed.mock.origin, temperament: Breed.mock.temperament, lifeSpan: Breed.mock.lifeSpan, breedDescription: Breed.mock.breedDescription, isFavorite: true, isBeingSearched: false)
    
    static let mockArray = [mock, mock2]
    static let mockFavoriteArray = [mockFavorite]
}
