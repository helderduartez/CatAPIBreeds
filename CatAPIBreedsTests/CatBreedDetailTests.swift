//
//  CatBreedDetailTests.swift
//  CatAPIBreedsTests
//
//  Created by Helder Duarte on 23/06/2025.
//

import ComposableArchitecture
import Testing
import XCTest

@testable import CatAPIBreeds

@MainActor
struct CatBreedDetailTests {
    @Test
    func catBreedDetailPressedDismissButtonTest() async {
        let store = TestStore(initialState: CatBreedDetailReducer.State(breed: BreedDB.mock)) {
            CatBreedDetailReducer()
        }
        
        await store.send(.dismissButtonTapped)
    }
    
    @Test
    func catBreedDetailPressedFavoriteButtonTest() async {
        let breed = BreedDB(item: Breed(id: "1", name: "mock1 name", image: nil, origin: "mock1 origin", temperament: "mock1 temperament", lifeSpan: "12 - 15", breedDescription: "mock1 desc"))
        
        let store = TestStore(initialState: CatBreedDetailReducer.State(breed: breed)) {
            CatBreedDetailReducer()
        }
        
        await store.send(.favoriteButtonTapped)
        #expect(store.state.breed.isFavorite == true)
    }
}
