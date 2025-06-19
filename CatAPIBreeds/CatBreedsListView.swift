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
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7.5) {
                    ForEach(Array(store.isSearching ? store.filteredBreedList.enumerated() : store.breedsList.enumerated()), id: \.offset) { index, breed in
                        ZStack(alignment: .topTrailing) {
                            VStack() {
                                KFImage(breed.image?.url)
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
                                if index == store.breedsList.count - 1 && !store.isLoadingPage && store.hasMorePages && !store.isSearching {
                                    store.send(.incrementPageAndFetchBreedList)
                                }
                            }
                        } // ZStack
                        
                    } // ForEach
                }// LazyVGrid
                .searchable(text: $store.searchText.sending(\.searchTextChanged))
                .padding(.vertical, 15)
                .padding(.horizontal, 15)
                .offset(x: -5)
            } // ScrollView
            .navigationTitle("Cat Breeds")
            
        } // NavigationStack
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
