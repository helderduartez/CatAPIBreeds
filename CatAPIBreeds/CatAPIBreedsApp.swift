//
//  CatAPIBreedsApp.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import SwiftUI
import SwiftData

@main
struct CatAPIBreedsApp: App {
    static let store = Store(initialState: AppReducer.State()) {
        AppReducer()
            //._printChanges()
    }
    @Dependency(\.databaseService) var databaseService
    
    var modelContext: ModelContext {
        guard let modelContext = try? self.databaseService.context() else {
            fatalError("Could not create ModelContext")
        }
        return modelContext
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
                .modelContext(self.modelContext)
        }
        .modelContainer(for: BreedDB.self)
    }
}
