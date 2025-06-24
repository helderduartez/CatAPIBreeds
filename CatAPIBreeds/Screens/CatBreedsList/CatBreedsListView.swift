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
                    VStack(spacing: 24) {
                        Image(systemName: "cat.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 130, height: 130)
                            .foregroundStyle(.gray)
                            .opacity(0.6)
                        Text("No breeds found")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 160)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7.5) {
                        
                        ForEach(Array(store.breedsList.enumerated()), id: \.offset) { index, breed in
                            if (store.isSearching ? breed.isBeingSearched : !breed.isBeingSearched) {
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
                                                .frame(width: 45, height: 45)
                                                .foregroundStyle(.white)
                                                .opacity(0.6)
                                            Image(systemName: breed.isFavorite ? "star.fill" : "star")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                    .offset(x:2, y:-2)
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
