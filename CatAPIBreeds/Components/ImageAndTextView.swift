//
//  ImageAndTextView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 24/06/2025.
//
import SwiftUI

struct ImageAndTextView: View {
    let breed: BreedDB
    
    var body: some View {
            VStack() {
                KFImageView(image: breed.image)
                
                Text("\(breed.name)")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
            } // VStack
    }
}

#Preview {
    ImageAndTextView(breed: BreedDB.mock)
}
