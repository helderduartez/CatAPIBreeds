//
//  CatBreedsListTests.swift
//  CatAPIBreedsTests
//
//  Created by Helder Duarte on 23/06/2025.
//

import ComposableArchitecture
import Testing
import XCTest

@testable import CatAPIBreeds

@MainActor
struct CatBreedsListTests {
    enum SomeError: Error { case api, db }
    @Test
    func fetchBreedsFromAPI() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in Breed.mockArray }
            $0.swiftData.fetchAll = { BreedDB.mockArray}
            $0.swiftData.add = { _ in }
        }

        await store.send(.fetchBreedList) {
            $0.isLoadingPage = true
        }
        await store.receive(.populateBreedListFromAPI(Breed.mockArray)) {
            $0.isLoadingPage = false
            $0.breedsList = BreedDB.mockArray
        }
    }
    
    @Test
    func fetchBreedsFromDBWhenAPIFails() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in throw APIManagerError.network }
            $0.swiftData.fetchAll = { BreedDB.mockArray}
            $0.swiftData.add = { _ in }
        }

        await store.send(.fetchBreedList) {
            $0.isLoadingPage = true
        }
        
        await store.receive(.populateBreedListFromDB(BreedDB.mockArray)) {
            $0.isLoadingPage = false
            $0.breedsList = BreedDB.mockArray
        }
    }
    
}
