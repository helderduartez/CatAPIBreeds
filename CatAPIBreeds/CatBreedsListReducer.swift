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
        var breedsCurrentPage: Int = 0
        var searchText: String = ""
        var filteredBreedList: [Breed] = []
        var isSearching: Bool = false
        var isLoadingPage: Bool = false
        var hasMorePages: Bool = true
    }
    
    enum Action: Equatable {
        case fetchBreedList
        case populateBreedList([Breed])
        case incrementPageAndFetchBreedList
        case searchTextChanged(String)
        case fetchFilteredBreedList(String)
        case populateFilteredBreedList([Breed])
        case catBreedTapped(Breed)
        case catBreedFavoriteButtonTapped(Breed)
    }
    
    @Dependency(\.apiManager) var apiManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBreedList:
                state.isLoadingPage = true
                return .run { [page = state.breedsCurrentPage] send in
                    await send(.populateBreedList(try await apiManager.fetchBreeds(page: page)))
                }
                
            case let .populateBreedList(breeds):
                state.isLoadingPage = false
                if breeds.isEmpty {
                    state.hasMorePages = false
                    return .none
                } else {
                    state.breedsList.append(contentsOf: breeds)
                    return .none
                }
            
            case .incrementPageAndFetchBreedList:
                state.breedsCurrentPage += 1
                return .send(.fetchBreedList)
                
            case let .searchTextChanged(text):
                state.searchText = text
                state.isSearching = !text.isEmpty
                return text.isEmpty ? .none : .send(.fetchFilteredBreedList(text))
                
            case let .fetchFilteredBreedList(text):
                state.isLoadingPage = true
                return .run { send in
                    await send(.populateFilteredBreedList(try await apiManager.searchBreeds(query: text)))
                }
                
            case let .populateFilteredBreedList(breeds):
                state.isLoadingPage = false
                state.filteredBreedList = breeds
                return .none
                
            case .catBreedTapped:
                return .none
                
            case let .catBreedFavoriteButtonTapped(breed):
                if let index = state.breedsList.firstIndex(of: breed) {
                    state.breedsList[index].isFavorite.toggle()
                }
                return .none
            }
        }
    }
}
