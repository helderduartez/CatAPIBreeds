//
//  AppView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: StoreOf<AppReducer>
    
    var body: some View {
        TabView {
            CatBreedsListView(store: store.scope(state: \.allBreedsList, action: \.allBreedsList))
                .tabItem {
                    Image(systemName: "house")
                    Text("Cat Breeds")
                }
            FavoriteBreedsListView(store: store.scope(state: \.favoritesBreedList, action: \.favoritesBreedList))
                .tabItem {
                    Image(systemName: "star")
                    Text("Favorites")
                }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppReducer.State()) {
            AppReducer()
        }
    )
}
