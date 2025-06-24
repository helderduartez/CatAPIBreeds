//
//  FavoriteButtonView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 24/06/2025.
//

import SwiftUI

struct FavoriteButtonView: View {
    let isFavorite: Bool
    let favoriteButtonTapped: () -> Void
    
    var body: some View {
        Button(action: favoriteButtonTapped) {
            ZStack {
                Circle()
                    .frame(width: 45, height: 45)
                    .foregroundStyle(.white)
                    .opacity(0.6)
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
        }
        .offset(x:2, y:-2)
    }
}

#Preview {
    FavoriteButtonView(isFavorite: true, favoriteButtonTapped: {})
}
