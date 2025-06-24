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
        @Presents var errorAlert: AlertState<Action.Alert>?
        var breedsList: [BreedDB] = []
        var breedsCurrentPage: Int = 0
        var searchText: String = ""
        var isSearching: Bool = false
        var isLoadingPage: Bool = false
        var hasMorePages: Bool = true
        var isSearchFocused: Bool = true
        
    }
    
    enum Action: Equatable {
        case catBreedDetail(PresentationAction<CatBreedDetailReducer.Action>)
        case errorAlert(PresentationAction<Alert>)
        case fetchBreedList
        case populateBreedListFromAPI([Breed])
        case populateBreedListFromDB([BreedDB])
        case incrementPageAndFetchBreedList
        case searchTextChanged(String)
        case fetchFilteredBreedList(String)
        case populateFilteredBreedListFromAPI([Breed]?)
        case populateFilteredBreedListFromDB(String)
        case catBreedTapped(BreedDB)
        case catBreedFavoriteButtonTapped(BreedDB)
        case showInternetErrorAlert(APIManagerError)
        enum Alert: Equatable {
            case refreshFetchBreeds
            case networkErrorAlertDismissed
        }
    }
    
    @Dependency(\.apiManager) var apiManager
    @Dependency(\.databaseService) var context
    @Dependency(\.swiftData) var breedDatabase
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchBreedList:
                state.isLoadingPage = true
                state.errorAlert = nil
                return .run { [page = state.breedsCurrentPage] send in
                    do {
                        await send(.populateBreedListFromAPI(try await apiManager.fetchBreeds(page: page)))
                    } catch {
                        if let breedListDB = try? breedDatabase.fetchAll(), !breedListDB.isEmpty {
                            await send(.populateBreedListFromDB(breedListDB))
                        } else {
                            await send(.showInternetErrorAlert(APIManagerError.network))
                        }
                    }
                    
                }
                
            case let .populateBreedListFromAPI(breeds):
                state.isLoadingPage = false
                if breeds.isEmpty {
                    state.hasMorePages = false
                    return .none
                } else {
                    for breed in breeds {
                        do {
                            try breedDatabase.add(BreedDB(item: breed))
                        } catch {
                            state.breedsList.append(BreedDB(item: breed))
                        }
                    }
                    
                    guard let breedListDB = try? breedDatabase.fetchAll() else {
                        return .none
                    }
                    
                    state.breedsList = breedListDB
                    
                    return .none
                }
                
            case let .populateBreedListFromDB(breeds):
                state.isLoadingPage = false
                state.breedsList = breeds
                
                return .none
                
            case .incrementPageAndFetchBreedList:
                state.breedsCurrentPage += 1
                return .send(.fetchBreedList)
                
            case let .searchTextChanged(text):
                state.searchText = text
                state.isSearching = !text.isEmpty
                return text.isEmpty ? .send(.populateFilteredBreedListFromAPI(nil)) : .send(.fetchFilteredBreedList(text))
                
            case let .fetchFilteredBreedList(text):
                state.isLoadingPage = true
                return .run {send in
                    do {
                        await send(.populateFilteredBreedListFromAPI(try await apiManager.searchBreeds(query: text)))
                    } catch {
                        await send(.populateFilteredBreedListFromDB(text))
                    }
                }
                
            case let .populateFilteredBreedListFromAPI(breeds):
                state.isLoadingPage = false
                let searchedBreed = breeds ?? []
                
                for breed in state.breedsList {
                    breed.isBeingSearched = searchedBreed.contains(where: { $0.id == breed.id })
                }
                return .none
                
            case let .populateFilteredBreedListFromDB(text):
                state.isLoadingPage = false
                let searchedBreeds = state.breedsList.filter {$0.name.localizedCaseInsensitiveContains(text)}
                
                for breed in state.breedsList {
                    breed.isBeingSearched = searchedBreeds.contains(where: { $0.id == breed.id })
                }
                return .none
                
            case let .catBreedFavoriteButtonTapped(breed):
                guard let index = state.breedsList.firstIndex(where: { $0.id == breed.id }) else {
                    return .none
                }
                state.breedsList[index].isFavorite.toggle()
                
                return .run { _ in
                    try breedDatabase.save()
                }
                
            case let .catBreedTapped(breed):
                state.catBreedDetail = .init(breed: breed)
                return .none
                
            case .catBreedDetail(.presented(.favoriteButtonTapped)):
                return .run { _ in
                    try breedDatabase.save()
                }
                
            case .catBreedDetail(.presented(.dismissButtonTapped)):
                state.catBreedDetail = nil
                return .none
                
            case .catBreedDetail(.dismiss):
                state.catBreedDetail = nil
                return .none
                
            case let .showInternetErrorAlert(errorAlert):
                state.isLoadingPage = false
                state.errorAlert = AlertState(
                    title: { TextState("No Cat Breeds Found") },
                    actions: {
                        ButtonState(action: .refreshFetchBreeds) {
                            TextState("Reload")
                        }
                        ButtonState(action: .networkErrorAlertDismissed) {
                            TextState("Dismiss")
                        }
                    },
                    message: { TextState(errorAlert.localizedDescription) }
                )
                return .none
                
            case .errorAlert(.presented(.refreshFetchBreeds)):
                return .run { send in
                    await send(.fetchBreedList)
                }
                
            case .errorAlert(.presented(.networkErrorAlertDismissed)):
                return .run { send in
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    await send(.fetchBreedList)
                }
                
            case .errorAlert(.dismiss):
                return .run{ send in
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    await send(.fetchBreedList)
                }
            }
            
        }
        .ifLet(\.$errorAlert, action: \.errorAlert)
        .ifLet(\.$catBreedDetail, action: \.catBreedDetail) {
            CatBreedDetailReducer()
        }
        
    }
}
