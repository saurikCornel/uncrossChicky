//
//  MenuScreen.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/2/25.
//

import Foundation
import SwiftUI



struct MenuScreen: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                
                HStack {
                    Image(.car001)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.4)
                        .offset(y: -200)
                        .opacity(0.7)
                    
                    Image(.car002)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.4)
                        .offset(y: 200)
                        .opacity(0.7)
                }
                
                
                
                
                VStack(spacing: 30) {
                    
//                    
//                    StartGameButton(geo: geo) {
//                        Navigator.shared.selectedScreen = .MAIN_GAME
//                    }
                    
                    
                    
                    Image(.chickyLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.8)
                    
                    Spacer()
                    
                    
                    Button(action: {
                        Navigator.shared.selectedScreen = .COLLECT_EGGS
                    }, label: {
                        Image(.collectEggs)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                            .frame(width: geo.size.width * 0.8)
                            .shadow(radius: 90)
                           
                    })
                    
                    Button(action: {
                        Navigator.shared.selectedScreen = .RUN_CHICKY
                    }, label: {
                        Image(.runChicky)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                            .frame(width: geo.size.width * 0.8)
                            .shadow(radius: 90)
                           
                    })
                    
                    Button(action: {
                        Navigator.shared.selectedScreen = .PUZZLE_GAME
                    }, label: {
                        Image(.puzzleChicken)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                            .frame(width: geo.size.width * 0.8)
                            .shadow(radius: 90)
                           
                    })
                    
                    Button(action: {
                        Navigator.shared.selectedScreen = .CHICKCOO_GAME
                    }, label: {
                        Image(.chickCooGame)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 500)
                            .frame(width: geo.size.width * 0.8)
                            .shadow(radius: 90)
                           
                    })
                    
//                    MenuScreenButton(geo: geo, text: "🐔 Chicken Memory Game") {
//                        Navigator.shared.selectedScreen = .MEMORY_GAME
//                    }
                    
//                    
//                    MenuScreenButton(geo: geo, text: "🥚 Cockadoodledoo Game") {
//                        Navigator.shared.selectedScreen = .COCKADO_GAME
//                    }
//                    
//                    MenuScreenButton(geo: geo, text: "🎁 Get bonus") {
//                        Navigator.shared.selectedScreen = .BONUS
//                    }
                    Spacer()
                    ZStack {
                        
                        HStack {
                           // Image(.leftCus)
                           
                            VStack {
                                Spacer()
                                HStack {
                                    Image(.leftCus)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                    Spacer()
                                    Image(.rightCus)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 100)
                                }
                            }
                           
                        }
                        .ignoresSafeArea()
                        
                        VStack(spacing: 0) {
                            Image(.chick)
                                .resizable()
                                .scaledToFit()
                            
                            ScoreView()
                        }
                    }
                      
                   
                    
                }
                
                HStack {
                    VerticalDashedLine()
                    Spacer()
                    VerticalDashedLine()
                }
                .ignoresSafeArea()
                .frame(width: geo.size.width * 0.88)
                .position(x: geo.size.width / 2, y: geo.size.height / 2)
                
               
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
            
        }
        .background(
            
            LinearGradient(colors: [Color.Theme.mainColor, Color.Theme.seconaryColor, Color.Theme.seconaryColor, Color.Theme.seconaryColor],
                           startPoint: .top, endPoint: .bottom)
            
            
        )
    }
}









#Preview {
    MenuScreen()
}
