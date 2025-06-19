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
                    ForEach(store.breedsList) { breed in
                        VStack {
                            Image(systemName: "cat.fill")
                            Text("\(breed.name)")
                        }
                    }
                }
                .searchable(text: $store.searchText.sending(\.searchTextChanged))
            }
            .navigationTitle("Cat Breeds")
            .padding()
        }
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
