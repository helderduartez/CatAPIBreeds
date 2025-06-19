//
//  CatBreedsListReducer.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct CatBreedsListReducer {
    @ObservableState
    struct State: Equatable {
        var breedsList: [Breed] = []
        var searchQuery = ""
        var searchText: String = ""
    }
    
    enum Action: Equatable {
        case fetchBreedList
        case populateBreedList([Breed])
        case searchTextChanged(String)
        case catBreedTapped(Breed)
        case catBreedFavoriteButtonTapped(Breed)
    }
    
    @Dependency(\.apiManager) var apiManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBreedList:
                return .run { send in
                    await send(.populateBreedList(try await apiManager.fetchBreeds(page: 0)))
                }
                
            case .populateBreedList(let breeds):
                state.breedsList = breeds
                return .none
            
            case let .searchTextChanged(text):
                state.searchText = text
                print(state.searchText)
                return .none
                
            case .catBreedTapped:
                return .none
                
            case .catBreedFavoriteButtonTapped:
                return .none
            }
        }
    }
}
