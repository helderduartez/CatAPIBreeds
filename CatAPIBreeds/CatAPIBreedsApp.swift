//
//  CatAPIBreedsApp.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import SwiftUI

@main
struct CatAPIBreedsApp: App {
    static let store = Store(initialState: AppReducer.State()) {
        AppReducer()
            ._printChanges()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: Self.store)
        }
    }
}
