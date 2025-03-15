//
//  ScoreView.swift
//  UncrossChicky
//
//  Created by alex on 3/15/25.
//

import Foundation
import SwiftUI


struct ScoreView: View {
    @AppStorage("coins") var coinCounter: Int = 0
    
    var body: some View {
        HStack(spacing: 10) {
            Image(.eggCoin)
                .resizable()
                .scaledToFit()
                .frame(height: 50)
            Text("\(coinCounter)")
                .cFont(size: 16, color: .white)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .padding(.horizontal, 20)
        .frame(height: 70)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .fill(Color.Theme.seconaryColor.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .stroke(Color.Theme.mainColor, lineWidth: 2)
                )
                .shadow(radius: 70)
            
        )
        
    }
}
