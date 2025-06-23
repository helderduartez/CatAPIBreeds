//
//  BreedDatabase.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 22/06/2025.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var swiftData: BreedDatabase {
        get { self[BreedDatabase.self] }
        set { self[BreedDatabase.self] = newValue }
    }
}

struct BreedDatabase {
    var fetchAll: @Sendable () throws -> [BreedDB]
    var add: @Sendable (BreedDB) throws -> Void
    var save: @Sendable () throws -> Void
    var delete: @Sendable (BreedDB) throws -> Void
    
    
    
    enum BreedError: Error {
        case add
        case delete
    }
}

extension BreedDatabase: TestDependencyKey {
    static let testValue = Self(
        fetchAll: { BreedDB.mockArray },
        add: { _ in },
        save: { },
        delete: { _ in }
    )
}

extension BreedDatabase: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let breedsContext = try context()
                let descriptor = FetchDescriptor<BreedDB>(
                    sortBy: [SortDescriptor(\.name, order: .forward)]
                )
                
                return try breedsContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { breed in
            do {
                @Dependency(\.databaseService.context) var context
                let breedsContext = try context()
                let breedID = breed.id
                let fetchDescriptor = FetchDescriptor<BreedDB>(
                    predicate: #Predicate { $0.id == breedID }
                )
                let savedBreeds = try breedsContext.fetch(fetchDescriptor)
                
                if let savedBreed = savedBreeds.first {
                    if (savedBreed.image == nil), let newImage = breed.image {
                        savedBreed.image = newImage
                    }
                    try breedsContext.save()
                } else {
                    breedsContext.insert(breed)
                    try breedsContext.save()
                }
            } catch {
                throw BreedError.add
            }
        },
        save: {
            do {
                @Dependency(\.databaseService.context) var context
                let breedsContext = try context()
                try breedsContext.save()
            } catch {
                
            }
        },
        delete: { breed in
            do {
                @Dependency(\.databaseService.context) var context
                let breedContext = try context()
                
                breedContext.delete(breed)
                try breedContext.save()
            } catch {
                throw BreedError.delete
            }
        }
    )
}
