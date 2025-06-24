//
//  FavoriteBreedsListView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 21/06/2025.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct FavoriteBreedsListView: View {
    
    @Bindable var store: StoreOf<FavoriteBreedsListReducer>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if store.favoriteBreedsList.isEmpty {
                    EmptyStateView(isFavoritePage: true)
                } else {
                    Text("Average Life Span: \(String(format:"%.2f", store.averageLifeSpan))")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7.5) {
                        ForEach(Array(store.favoriteBreedsList.enumerated()), id: \.offset) { index, breed in
                            ZStack(alignment: .topTrailing) {
                                ImageAndTextView(breed: breed)
                                FavoriteButtonView(isFavorite: breed.isFavorite ,favoriteButtonTapped: {
                                    store.send(.catBreedFavoriteButtonTapped(breed))
                                })
                            } // ZStack
                            .contentShape(Rectangle())
                            .onTapGesture {
                                store.send(.catBreedTapped(breed))
                            }
                            .sheet(item: $store.scope(state: \.catBreedDetail, action: \.catBreedDetail)) { store in
                                CatBreedDetailView(store: store)
                            }
                        } // ForEach
                        
                    } // LazyVGrid
                    .padding(.vertical, 15)
                    .padding(.horizontal, 15)
                }
                
            } // ScrollView
            .navigationTitle("Favorites")
            
        } // NavigationStack
        .onAppear() {
            store.send(.calculateAverageLifeSpan)
        }
        .task {
            do {
                try await Task.sleep(for: .milliseconds(300))
                await store.send(.fetchDBBreeds).finish()
            } catch {
                
            }
        }
    }
}

#Preview {
    FavoriteBreedsListView(store: Store(initialState: FavoriteBreedsListReducer.State(), reducer: {
        FavoriteBreedsListReducer()
    }))
}
