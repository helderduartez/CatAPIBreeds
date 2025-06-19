//
//  CatBreedsListView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 18/06/2025.
//

import ComposableArchitecture
import SwiftUI

struct CatBreedsListView: View {
    
    @Bindable var store: StoreOf<CatBreedsListReducer>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                    
                    ForEach(Array(store.isSearching ? store.filteredBreedList.enumerated() : store.breedsList.enumerated()), id: \.offset) { index, breed in
                        VStack {
                            Image(systemName: "cat.fill")
                            Text("\(breed.name)")
                        }
                        .onAppear {
                            if index == store.breedsList.count - 1 && !store.isLoadingPage && store.hasMorePages && !store.isSearching {
                                store.send(.incrementPageAndFetchBreedList)
                            }
                        }
                    } // ForEach
                }// LazyVGrid
                .searchable(text: $store.searchText.sending(\.searchTextChanged))
            } // ScrollView
            .navigationTitle("Cat Breeds")
            .padding()
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
