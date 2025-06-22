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
    var delete: @Sendable (BreedDB) throws -> Void
    
    
    
    enum BreedError: Error {
        case add
        case delete
    }
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
                let existingBreeds = try breedsContext.fetch(fetchDescriptor)

                if existingBreeds.isEmpty {
                    breedsContext.insert(breed)
                    try breedsContext.save()
                }
            } catch {
                throw BreedError.add
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
