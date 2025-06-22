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
        @Presents var catBreedDetail: CatBreedDetailReducer.State?
        var breedsList: [BreedDB] = []
        var breedsCurrentPage: Int = 0
        var searchText: String = ""
        var filteredBreedList: [BreedDB] = []
        var isSearching: Bool = false
        var isLoadingPage: Bool = false
        var hasMorePages: Bool = true
    }
    
    enum Action: Equatable {
        case catBreedDetail(PresentationAction<CatBreedDetailReducer.Action>)
        case fetchBreedList
        case populateBreedList([Breed])
        case incrementPageAndFetchBreedList
        case searchTextChanged(String)
        case fetchFilteredBreedList(String)
        case populateFilteredBreedList([Breed])
        case catBreedTapped(BreedDB)
        case catBreedFavoriteButtonTapped(BreedDB)
    }
    
    @Dependency(\.apiManager) var apiManager
    @Dependency(\.databaseService) var context
    @Dependency(\.swiftData) var breedDatabase
    
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
                    for breed in breeds {
                        do {
                            try? breedDatabase.add(BreedDB(item: breed))
                        }
                    }
                    
                    guard let breedListDB = try? breedDatabase.fetchAll() else {
                        return .none
                    }
                    
                    state.breedsList = breedListDB
                    
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
                state.filteredBreedList = self.getBreedDBListFromBreed(items: breeds)
                return .none
                
            case let .catBreedTapped(breed):
                state.catBreedDetail = .init(breed: breed)
                return .none
                
            case let .catBreedFavoriteButtonTapped(breed):
                guard let index = state.breedsList.firstIndex(where: { $0.id == breed.id }) else {
                    return .none
                }
                state.breedsList[index].isFavorite.toggle()
                try? breedDatabase.add(state.breedsList[index])
                return .none
                
            case let .catBreedDetail(.presented(.favoriteButtonTapped(breed))):
                return .send(.catBreedFavoriteButtonTapped(breed))
                
            case .catBreedDetail(.presented(.dismissButtonTapped)):
                state.catBreedDetail = nil
                return .none
                
            case .catBreedDetail(.dismiss):
                state.catBreedDetail = nil
                return .none
                
            }
            
        }
        .ifLet(\.$catBreedDetail, action: \.catBreedDetail) {
            CatBreedDetailReducer()
        }
    }
    
    func getBreedDBListFromBreed(items: [Breed]) -> [BreedDB] {
        var breedDBList: [BreedDB] = []
        for item in items {
            print("Breed \(item)")
            breedDBList.append(BreedDB(item: item))
        }
        return breedDBList
    }
}
