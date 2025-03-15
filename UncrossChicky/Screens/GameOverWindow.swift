//
//  GameOverWindow.swift
//  UncrossChicky
//
//  Created by alex on 3/15/25.
//

import Foundation
import Foundation
import SwiftUI


struct GameOverWindow: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("score") private var storedScore: Int = 0
    
    var score: Int
    var actionOnAppearIfNeeded: () -> Void
    
    var body: some View {
        ZStack {
            VStack {
                Text("Your reward:")
                 
                ScoreView()
                MenuPauseButton(text: "MENU") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.top)
            }
        }
        .onAppear {
            actionOnAppearIfNeeded()
            storedScore += score
        }
        .padding(30)
        .background(
            Image("MenuBackground")
                .resizable()
                .scaledToFill()
        )
    }
}

#Preview {
    GameOverWindow(score: 30, actionOnAppearIfNeeded: {})
}
