//
//  TitleAndSubtitleTextView.swift
//  CatAPIBreeds
//
//  Created by Helder Duarte on 24/06/2025.
//

import SwiftUI

struct TitleAndSubtitleTextView: View {
    let title: String
    let subtitle: String?
    let font: Font?
    let textAlignment: TextAlignment?
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Text(subtitle ?? "")
                .font(font ?? .subheadline)
                .multilineTextAlignment(textAlignment ?? .leading)
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    TitleAndSubtitleTextView(title: "Cat", subtitle: "Description", font: nil, textAlignment: nil)
}
