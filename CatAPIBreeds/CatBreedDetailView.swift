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
            
            Text(store.state.breed.name)
                .font(.title)
                .fontWeight(.semibold)
                .padding()
            
            KFImage(store.state.breed.image?.url)
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
                    Text(store.state.breed.origin ?? "")
                        .font(.subheadline)
                }
                .padding(.bottom, 5)
                
                VStack {
                    Text("Temperament:")
                        .font(.title3)
                    Text(store.state.breed.temperament ?? "")
                        .font(.subheadline)
                }
                .padding(.bottom, 5)
                
                VStack {
                    Text("Description:")
                        .font(.title3)
                    Text(store.state.breed.description ?? "")
                        .multilineTextAlignment(.center)
                        .font(.body)
                }
            }
            .padding()
            
            Spacer()
            
            Button {
                store.send(.favoriteButtonTapped)
            } label: {
                Text(store.state.breed.isFavorite ? "Remove from Favorites" : "Add to Favorites")
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
        store: Store(initialState: CatBreedDetailReducer.State(breed: Breed(id: "raga",
                                                                            name: "Ragamuffin",
                                                                            image: nil,
                                                                            origin: "United States",
                                                                            temperament: "Affectionate, Friendly, Gentle, Calm",
                                                                            lifeSpan: "12 - 16 years",
                                                                            description: "The Ragamuffin is calm, even tempered and gets along well with all family members. Changes in routine generally do not upset her. She is an ideal companion for those in apartments, and with children due to her patient nature.",
                                                                            isFavorite: false))) {
            CatBreedDetailReducer()
        }
    )
}
