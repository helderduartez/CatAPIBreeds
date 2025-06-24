//
//  EmptyStateView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 24/06/2025.
//

import SwiftUI

struct EmptyStateView: View {
    let isFavoritePage: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "cat.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 130, height: 130)
                .foregroundStyle(.gray)
                .opacity(0.6)
            Text(isFavoritePage ? "No favorite breeds found" : "No breeds found")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 160)
    }
}

#Preview {
    EmptyStateView(isFavoritePage: false)
}
