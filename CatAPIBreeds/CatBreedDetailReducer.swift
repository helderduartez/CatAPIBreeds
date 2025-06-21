//
//  CatBreedDetailReducer.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 19/06/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CatBreedDetailReducer {
    @ObservableState
    struct State: Equatable {
        var breed: Breed
    }
    
    enum Action: Equatable {
        case dismissButtonTapped
        case favoriteButtonTapped(Breed)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .dismissButtonTapped:
                return .none
            case .favoriteButtonTapped(_):
                state.breed.isFavorite.toggle()
                return .none
            }
        }
    }
}
