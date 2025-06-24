//
//  FavoriteBreedsListTests.swift
//  CatAPIBreedsTests
//
//  Created by Helder Duarte on 23/06/2025.
//

import ComposableArchitecture
import Testing

@testable import CatAPIBreeds

@MainActor
struct FavoriteBreedsListTests {
    @Test
    func fetchBreedsFromDB() async  {
        let store = TestStore(initialState: FavoriteBreedsListReducer.State()) {
            FavoriteBreedsListReducer()
        } withDependencies: {
            $0.swiftData.fetchAll = { BreedDB.mockFavoriteArray }
        }
        
        await store.send(.fetchDBBreeds)
        
        await store.receive(.populateFavoriteBreedsList(BreedDB.mockFavoriteArray)) { state in
            state.favoriteBreedsList = BreedDB.mockFavoriteArray
        }
    }
    
    @Test
    func averageLifeSpanCalculatedTest() async {
        let breeds = BreedDB.mockArray
        let expectedAverage = 13.0
        
        let store = TestStore(initialState: FavoriteBreedsListReducer.State(
            favoriteBreedsList: breeds
        )) {
            FavoriteBreedsListReducer()
        }
        
        for breed in breeds {
            breed.isFavorite = true
        }
        
        await store.send(.calculateAverageLifeSpan) {
            $0.averageLifeSpan = expectedAverage
        }
    }
    
    @Test
    func catBreedDetailTappedTest() async {
        let store = TestStore(initialState: FavoriteBreedsListReducer.State()) {
            FavoriteBreedsListReducer()
        }
        
        await store.send(.catBreedTapped(BreedDB.mock)) { state in
            state.catBreedDetail = .init(breed: BreedDB.mock)
        }
    }
    
    @Test
    func catBreedFavoriteButtonTappedTest() async {
        let breed = BreedDB(item: Breed(id: "3", name: "mock1 name", image: nil, origin: "mock1 origin", temperament: "mock1 temperament", lifeSpan: "12 - 15", breedDescription: "mock1 desc"))
        let expectedAverage = 12.0
        
        let store = TestStore(initialState: FavoriteBreedsListReducer.State(
            favoriteBreedsList: [breed]
        )) {
            FavoriteBreedsListReducer()
        } withDependencies: {
            $0.swiftData.fetchAllFavorites = { [] }
            $0.swiftData.add = { _ in }
        }
        
        await store.send(.catBreedFavoriteButtonTapped(store.state.favoriteBreedsList[0]))
        #expect(store.state.favoriteBreedsList[0].isFavorite == true)
        
        await store.receive(.fetchDBBreeds)
        await store.receive(.calculateAverageLifeSpan) {
            $0.averageLifeSpan = expectedAverage
        }
        await store.receive(.populateFavoriteBreedsList([])) { state in
            state.favoriteBreedsList = []
        }
        
        
    }
    
    
    @Test
    func catBreedDetailPresentedPressedDismissButtonTest() async {
        let initialState = FavoriteBreedsListReducer.State(
            catBreedDetail: .init(breed: BreedDB.mock)
        )
        
        let store = TestStore(initialState: initialState) {
            FavoriteBreedsListReducer()
        }
        
        await store.send(.catBreedDetail(.presented(.dismissButtonTapped))) { state in
            state.catBreedDetail = nil
        }
    }
    
    @Test
    func catBreedDetailPresentedDismissedTest() async {
        let initialState = FavoriteBreedsListReducer.State(
            catBreedDetail: .init(breed: BreedDB.mock)
        )
        
        let store = TestStore(initialState: initialState) {
            FavoriteBreedsListReducer()
        }
        
        await store.send(.catBreedDetail(.dismiss)) { state in
            state.catBreedDetail = nil
        }
    }
}
