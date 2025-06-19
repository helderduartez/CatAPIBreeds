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
        var favoritesBreedList = CatBreedsListReducer.State()
    }
    
    enum Action {
        case allBreedsList(CatBreedsListReducer.Action)
        case favoritesBreedList(CatBreedsListReducer.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.allBreedsList, action: \.allBreedsList) {
            CatBreedsListReducer()
        }
        Scope(state: \.favoritesBreedList, action: \.favoritesBreedList) {
            CatBreedsListReducer()
        }
        
        Reduce { state, action in
            return .none
        }
    }
}
