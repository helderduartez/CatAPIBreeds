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
                Text("Average Life Span: \(String(format:"%.2f", store.averageLifeSpan))")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7.5) {
                    ForEach(Array(store.breedsList.enumerated()), id: \.offset) { index, breed in
                        if breed.isFavorite {
                            ZStack(alignment: .topTrailing) {
                                VStack() {
                                    KFImage(breed.image)
                                        .placeholder {
                                            Image("CatLoadingPlaceholder")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 180)
                                                .cornerRadius(10)
                                                .opacity(0.5)
                                        }
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(height: 180)
                                        .cornerRadius(10)
                                    
                                    Text("\(breed.name)")
                                        .font(.subheadline)
                                        .multilineTextAlignment(.center)
                                        .fixedSize(horizontal: false, vertical: true)
                                    //
                                    Spacer()
                                } // VStack
                                Button {
                                    store.send(.catBreedFavoriteButtonTapped(breed))
                                } label: {
                                    ZStack {
                                        Circle()
                                            .frame(width: 30, height: 30)
                                            .foregroundStyle(.white)
                                            .opacity(0.6)
                                        Image(systemName: breed.isFavorite ? "star.fill" : "star")
                                            .frame(width: 30, height: 30)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.orange)
                                    }
                                }
                                .offset(x:10, y:-15)
                                .onAppear {
                                    store.send(.calculateAverageLifeSpan)
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
                .padding(.vertical, 15)
                .padding(.horizontal, 15)
                .offset(x: -5)
            } // ScrollView
            .navigationTitle("Favorites")
        } // NavigationStack
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
