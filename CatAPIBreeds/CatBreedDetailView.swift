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
                }
                .padding(.trailing)
            }
            
            Text(store.breed.name)
                .font(.title)
                .fontWeight(.semibold)
                .padding()
            
            KFImage(store.breed.image)
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
            
            VStack {
                VStack {
                    Text("Origin:")
                        .font(.title3)
                    Text(store.breed.origin ?? "")
                        .font(.subheadline)
                }
                .padding(.bottom, 5)
                
                VStack {
                    Text("Temperament:")
                        .font(.title3)
                    Text(store.breed.temperament ?? "")
                        .font(.subheadline)
                }
                .padding(.bottom, 5)
                
                VStack {
                    Text("Description:")
                        .font(.title3)
                    Text(store.breed.breedDescription ?? "")
                        .multilineTextAlignment(.center)
                        .font(.body)
                }
            }
            .padding()
            
            Spacer()
            
            Button {
                store.send(.favoriteButtonTapped(store.breed))
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
        }
    }
}

#Preview {
    CatBreedDetailView(
        store: Store(initialState: CatBreedDetailReducer.State(breed: BreedDB(id: "test", name: "test", image: nil, origin: "test", temperament: "test", lifeSpan: "test", breedDescription: "test", isFavorite: true))) {
            CatBreedDetailReducer()
        }
    )
}
