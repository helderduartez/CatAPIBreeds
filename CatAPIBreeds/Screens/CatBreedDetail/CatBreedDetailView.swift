//
//  CatBreedDetailView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 19/06/2025.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct CatBreedDetailView: View {
    @Bindable var store: StoreOf<CatBreedDetailReducer>
    
    var body: some View {
        
        VStack {
            HStack {
                Spacer()
                Button {
                    store.send(.dismissButtonTapped)
                } label: {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .padding()
            } //HStack
            
            ScrollView {
                Text(store.breed.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding([.leading, .trailing, .bottom], 10)
                
                KFImageView(image: store.breed.image)
                    .padding([.bottom], 5)
                VStack {
                    TitleAndSubtitleTextView(title: "Origin:", subtitle: store.breed.origin ?? "", font: nil, textAlignment: nil)
                    TitleAndSubtitleTextView(title: "Temperament:", subtitle: store.breed.temperament ?? "", font: nil, textAlignment: .center)
                    TitleAndSubtitleTextView(title: "Description:", subtitle: store.breed.breedDescription ?? "", font: .body, textAlignment: .center)
                } //VStack
                .padding([.leading, .trailing])
            }//ScrollView

            Spacer()
            
            Button {
                store.send(.favoriteButtonTapped)
            } label: {
                Text(store.breed.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(width: 260, height: 50)
                    .foregroundStyle(.white)
                    .background(.green)
                    .cornerRadius(10)
            }
            .padding()
        } //VStack
    }
}

#Preview {
    CatBreedDetailView(
        store: Store(initialState: CatBreedDetailReducer.State(breed: BreedDB(id: "test", name: "test", image: nil, origin: "test", temperament: "test", lifeSpan: "test", breedDescription: "test", isFavorite: true, isBeingSearched: false))) {
            CatBreedDetailReducer()
        }
    )
}
