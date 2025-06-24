//
//  FavoriteBreedsListReducer.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 21/06/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct FavoriteBreedsListReducer {
    @ObservableState
    struct State: Equatable {
        @Presents var catBreedDetail: CatBreedDetailReducer.State?
        var breedsList: [BreedDB] = []
        var averageLifeSpan: Double = 0
    }
    
    enum Action: Equatable {
        case catBreedDetail(PresentationAction<CatBreedDetailReducer.Action>)
        case catBreedFavoriteButtonTapped(BreedDB)
        case catBreedTapped(BreedDB)
        case fetchDBBreeds
        case populateBreedsList([BreedDB])
        case calculateAverageLifeSpan
    }
    
    @Dependency(\.databaseService) var context
    @Dependency(\.swiftData) var breedDatabase
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .fetchDBBreeds:
                return .run { send in
                    await send(.populateBreedsList(try breedDatabase.fetchAll()))
                }
            case let .populateBreedsList(breeds):
                state.breedsList = breeds
                return .none
                
            case let .catBreedFavoriteButtonTapped(breed):
                guard let index = state.breedsList.firstIndex(where: { $0.id == breed.id }) else {
                    return .none
                }
                state.breedsList[index].isFavorite.toggle()
                
                return .run { send in
                    await send(.calculateAverageLifeSpan)
                    try breedDatabase.save()
                }
                
            case .calculateAverageLifeSpan:
                state.averageLifeSpan = getAverageLifeSpanFromFavorites(breeds: state.breedsList)
                return .none
                
            case let .catBreedTapped(breed):
                state.catBreedDetail = .init(breed: breed)
                return .none
            
            case .catBreedDetail(.presented(.favoriteButtonTapped)):
                return .run { send in
                    await send(.calculateAverageLifeSpan)
                    try breedDatabase.save()
                }
            
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
}

func getAverageLifeSpanFromFavorites(breeds: [BreedDB]) -> Double {
    let favorites = breeds.filter { $0.isFavorite }
    var totalLowerLifeSpanValue = 0
    var totalFavorites = 0
    
    for breed in favorites {
        if let value = breed.lifeSpan?.components(separatedBy: " - ").first, let lowerLifeSpanValue = Int(value) {
            totalLowerLifeSpanValue += lowerLifeSpanValue
            totalFavorites += 1
        }
    }
    guard totalFavorites != 0 else {
        return 0
    }
    
    return Double((totalLowerLifeSpanValue / totalFavorites))
}

