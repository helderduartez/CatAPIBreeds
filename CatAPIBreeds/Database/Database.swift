//
//  Database.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 22/06/2025.
//

import Foundation
import SwiftData
import Dependencies
import ComposableArchitecture

extension DependencyValues {
    var databaseService: Database {
        get { self[Database.self] }
        set { self[Database.self] = newValue}
    }
}

let appContext: ModelContext = {
    do {
        let url = URL.applicationSupportDirectory.appending(path: "Model.sqlite")
        let config = ModelConfiguration(url: url)
        
        let container = try ModelContainer(for: BreedDB.self, configurations: config)
        return ModelContext(container)
    } catch {
        fatalError("Failed to create appContext container.")
    }
}()

struct Database {
    var context: () throws -> ModelContext
}


extension Database: DependencyKey {
    public static let liveValue = Self(
        context: { appContext }
    )
}
