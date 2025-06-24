//
//  KFImageView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 24/06/2025.
//

import SwiftUI
import Kingfisher

struct KFImageView: View {
    let image: URL?
    
    var body: some View {
        KFImage(image)
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
    }
}

#Preview {
    KFImageView(image: nil)
}
