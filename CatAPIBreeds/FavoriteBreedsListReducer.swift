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
        var breedsList: [Breed] = []
    }
    
    enum Action: Equatable {
        case catBreedDetail(PresentationAction<CatBreedDetailReducer.Action>)
        case catBreedFavoriteButtonTapped(Breed)
        case catBreedTapped(Breed)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .catBreedFavoriteButtonTapped(breed):
                guard let index = state.breedsList.firstIndex(where: { $0.id == breed.id }) else {
                    return .none
                }
                state.breedsList[index].isFavorite.toggle()
                
                return .none
                
            case let .catBreedTapped(breed):
                state.catBreedDetail = .init(breed: breed)
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
}
