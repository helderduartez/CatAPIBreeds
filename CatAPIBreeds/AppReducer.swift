//
//  AppReducer.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct AppReducer {
    struct State: Equatable {
        var allBreedsList = CatBreedsListReducer.State()
        var favoritesBreedList = FavoriteBreedsListReducer.State()
    }
    
    enum Action {
        case allBreedsList(CatBreedsListReducer.Action)
        case favoritesBreedList(FavoriteBreedsListReducer.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.allBreedsList, action: \.allBreedsList) {
            CatBreedsListReducer()
        }
        Scope(state: \.favoritesBreedList, action: \.favoritesBreedList) {
            FavoriteBreedsListReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .allBreedsList(_):
                return .none
                
            case .favoritesBreedList(_):
                return .none
            }
        }
    }
}
