//
//  CatBreedsListTests.swift
//  CatAPIBreedsTests
//
//  Created by Helder Duarte on 23/06/2025.
//

import ComposableArchitecture
import Testing

@testable import CatAPIBreeds

@MainActor
struct CatBreedsListTests {
    @Test
    func fetchBreedsFromAPITest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in [Breed.mock] }
            $0.swiftData.fetchAll = { [BreedDB.mock] }
            $0.swiftData.add = { _ in }
        }
        
        await store.send(.fetchBreedList) {
            $0.isLoadingPage = true
        }
        await store.receive(.populateBreedListFromAPI([Breed.mock])) {
            $0.isLoadingPage = false
            $0.breedsList = [BreedDB.mock]
        }
    }
    @Test
    func incrementPageAndFetchBreedsFromAPITest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in [Breed.mock] }
            $0.swiftData.fetchAll = { [BreedDB.mock] }
            $0.swiftData.add = { _ in }
            
        }
        
        await store.send(.incrementPageAndFetchBreedList) {
            $0.breedsCurrentPage += 1
        }
        
        await store.receive(.fetchBreedList) {
            $0.isLoadingPage = true
        }
        
        await store.receive(.populateBreedListFromAPI([Breed.mock])) {
            $0.isLoadingPage = false
            $0.breedsList = [BreedDB.mock]
        }
    }
    
    @Test
    func fetchBreedsFromDBWhenAPIFailsTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in throw APIManagerError.network }
            $0.swiftData.fetchAll = { [BreedDB.mock]}
            $0.swiftData.add = { _ in }
        }
        
        await store.send(.fetchBreedList) {
            $0.isLoadingPage = true
        }
        
        await store.receive(.populateBreedListFromDB([BreedDB.mock])) {
            $0.isLoadingPage = false
            $0.breedsList = [BreedDB.mock]
        }
    }
    
    @Test
    func fetchBreedsFailsShowAlertTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in throw APIManagerError.network }
            $0.swiftData.fetchAll = { throw BreedDatabase.BreedError.fetchAll }
        }
        
        await store.send(.fetchBreedList) {
            $0.isLoadingPage = true
            $0.errorAlert = nil
        }
        
        await store.receive(.showInternetErrorAlert(APIManagerError.network)) {
            $0.errorAlert = AlertState(
                title: { TextState("No Cat Breeds Found") },
                actions: {
                    ButtonState(action: .refreshFetchBreeds) {
                        TextState("Reload")
                    }
                    ButtonState(action: .networkErrorAlertDismissed) {
                        TextState("Dismiss")
                    }
                },
                message: { TextState(APIManagerError.network.localizedDescription)
                }
            )
            $0.isLoadingPage = false
        }
    }
    
    @Test
    func searchTextChangedToNotEmptyAndUsingAPITest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.searchBreeds = { _ in [Breed.mock] }
            $0.swiftData.fetchAll = { [BreedDB.mock] }
            $0.swiftData.add = { _ in }
        }
        
        await store.send(.searchTextChanged("Va")) {
            $0.searchText = "Va"
            $0.isSearching = true
        }
        
        await store.receive(.fetchFilteredBreedList("Va")) { state in
            state.isLoadingPage = true
        }
        
        await store.receive(.populateFilteredBreedListFromAPI([Breed.mock])) { state in
            state.isLoadingPage = false
        }
    }
    
    @Test
    func searchTextChangedToNotEmptyAndUsingDBTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.searchBreeds = { _ in throw APIManagerError.network }
            $0.swiftData.fetchAll = { [BreedDB.mock]}
            $0.swiftData.add = { _ in }
        }
        
        await store.send(.searchTextChanged("Va")) {
            $0.searchText = "Va"
            $0.isSearching = true
        }
        
        await store.receive(.fetchFilteredBreedList("Va")) { state in
            state.isLoadingPage = true
        }
        
        await store.receive(.populateFilteredBreedListFromDB("Va")) { state in
            state.isLoadingPage = false
        }
    }
    
    @Test
    func searchTextChangedToEmptyTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State(
            searchText: "Not Empty",
            isSearching: true
        )) {
            CatBreedsListReducer()
        }
        
        await store.send(.searchTextChanged("")) {
            $0.searchText = ""
            $0.isSearching = false
        }
        
        await store.receive(.populateFilteredBreedListFromAPI(nil))
    }
    
    @Test
    func catBreedFavoriteButtonTappedTest() async {
        let breed = BreedDB(item: Breed(id: "2", name: "mock1 name", image: nil, origin: "mock1 origin", temperament: "mock1 temperament", lifeSpan: "12 - 15", breedDescription: "mock1 desc"))
        
        let store = TestStore(initialState: CatBreedsListReducer.State(
            breedsList: [breed]
        )) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.swiftData.add = { _ in }
        }
        
        await store.send(.catBreedFavoriteButtonTapped(store.state.breedsList[0]))
        
        #expect(store.state.breedsList[0].isFavorite == true)
    }
    
    @Test
    func catBreedDetailTappedTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        }
        
        await store.send(.catBreedTapped(BreedDB.mock)) { state in
            state.catBreedDetail = .init(breed: BreedDB.mock)
        }
    }
    
    @Test
    func catBreedDetailPresentedPressedDismissButtonTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State(
            catBreedDetail: .init(breed: BreedDB.mock)
        )) {
            CatBreedsListReducer()
        }
        
        await store.send(.catBreedDetail(.presented(.dismissButtonTapped))) { state in
            state.catBreedDetail = nil
        }
    }
    
    @Test
    func catBreedDetailPresentedDismissedTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State(
            catBreedDetail: .init(breed: BreedDB.mock)
        )) {
            CatBreedsListReducer()
        }
        
        await store.send(.catBreedDetail(.dismiss)) { state in
            state.catBreedDetail = nil
        }
    }
    
    @Test
    func errorAlertPresentedRefreshFetchBreedsPressedTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State(
            errorAlert: AlertState(
                title: { TextState("No Cat Breeds Found") },
                actions: {
                    ButtonState(action: .refreshFetchBreeds) {
                        TextState("Reload")
                    }
                    ButtonState(action: .networkErrorAlertDismissed) {
                        TextState("Dismiss")
                    }
                },
                message: { TextState(APIManagerError.network.localizedDescription)
                }
            )
        )) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in [Breed.mock] }
        }
        
        await store.send(.errorAlert(.presented(.refreshFetchBreeds))) { state in
            state.errorAlert = nil
        }
        await store.receive(.fetchBreedList) { state in
            state.isLoadingPage = true
        }
        
        await store.skipReceivedActions()
    }
    
    @Test
    func errorAlertPresentedDismissPressedTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State(
            errorAlert: AlertState(
                title: { TextState("No Cat Breeds Found") },
                actions: {
                    ButtonState(action: .refreshFetchBreeds) {
                        TextState("Reload")
                    }
                    ButtonState(action: .networkErrorAlertDismissed) {
                        TextState("Dismiss")
                    }
                },
                message: { TextState(APIManagerError.network.localizedDescription)
                }
            )
        )) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in [Breed.mock] }
        }
        
        await store.send(.errorAlert(.presented(.networkErrorAlertDismissed))) { state in
            state.errorAlert = nil
        }
        
        await store.skipInFlightEffects()
    }
    
    @Test
    func errorAlertPresentedDismissedTest() async {
        let store = TestStore(initialState: CatBreedsListReducer.State(
            errorAlert: AlertState(
                title: { TextState("No Cat Breeds Found") },
                actions: {
                    ButtonState(action: .refreshFetchBreeds) {
                        TextState("Reload")
                    }
                    ButtonState(action: .networkErrorAlertDismissed) {
                        TextState("Dismiss")
                    }
                },
                message: { TextState(APIManagerError.network.localizedDescription)
                }
            )
        )) {
            CatBreedsListReducer()
        } withDependencies: {
            $0.apiManager.fetchBreeds = { _ in [Breed.mock] }
        }
        
        await store.send(.errorAlert(.presented(.networkErrorAlertDismissed))) { state in
            state.errorAlert = nil
        }
        
        await store.skipInFlightEffects()
    }
}
