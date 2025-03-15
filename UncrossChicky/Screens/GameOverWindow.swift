//
//  GameOverWindow.swift
//  UncrossChicky
//
//  Created by alex on 3/15/25.
//

import SwiftUI

struct GameOverWindow: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("score") private var storedScore: Int = 0
    
    var score: Int
    var actionOnAppearIfNeeded: () -> Void
    
    var body: some View {
        ZStack {
            // Semi-transparent background overlay
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            // Dialog content
            VStack(spacing: 20) {
                // Title
                Text("Your current score:")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Score display
                ScoreView()
                
                // Menu button
                MenuPauseButton(text: "MENU") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.top)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
            )
            .shadow(radius: 10)
        }
        .onAppear {
            actionOnAppearIfNeeded()
            storedScore += score
        }
    }
}

#Preview {
    GameOverWindow(score: 30, actionOnAppearIfNeeded: {})
}
