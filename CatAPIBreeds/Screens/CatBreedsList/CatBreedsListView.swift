//
//  CatBreedsListView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct CatBreedsListView: View {
    
    @Bindable var store: StoreOf<CatBreedsListReducer>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if store.breedsList.isEmpty {
                    EmptyStateView(isFavoritePage: false)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7.5) {
                        ForEach(Array(store.breedsList.enumerated()), id: \.offset) { index, breed in
                            if (store.isSearching ? breed.isBeingSearched : !breed.isBeingSearched) {
                                ZStack(alignment: .topTrailing) {
                                    ImageAndTextView(breed: breed)
                                    FavoriteButtonView(isFavorite: breed.isFavorite ,favoriteButtonTapped: {
                                        store.send(.catBreedFavoriteButtonTapped(breed))
                                    })
                                    .onAppear {
                                        if index == store.breedsList.count - 1 && !store.isLoadingPage && store.hasMorePages && !store.isSearching {
                                            store.send(.incrementPageAndFetchBreedList)
                                        }
                                    }
                                } // ZStack
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    store.send(.catBreedTapped(breed))
                                }
                                .sheet(item: $store.scope(state: \.catBreedDetail, action: \.catBreedDetail)) { store in
                                    CatBreedDetailView(store: store)
                                }
                                
                            }
                        } // ForEach
                        
                    }// LazyVGrid
                    .searchable(text: $store.searchText.sending(\.searchTextChanged))
                    .padding([.horizontal, .vertical], 15)
                }
                
            } // ScrollView
            .navigationTitle("Cat Breeds")
            
        } // NavigationStack
        .alert($store.scope(state: \.errorAlert, action: \.errorAlert))
        .task {
            do {
                try await Task.sleep(for: .milliseconds(300))
                await store.send(.fetchBreedList).finish()
            } catch {
                
            }
        }
    }
}

#Preview {
    CatBreedsListView(
        store: Store(initialState: CatBreedsListReducer.State()) {
            CatBreedsListReducer()
        }
    )
}
