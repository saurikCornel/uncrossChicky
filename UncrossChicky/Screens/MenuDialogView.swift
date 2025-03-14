//
//  GameOverView.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/2/25.
//

import Foundation
import SwiftUI

enum MenuType {
    case PAUSE
    case GAMEOVER
    case YOUWIN
    case YOULOSE
}

struct MenuDialogView: View {
    var type: MenuType
    
    var resumeAction: () -> Void
    var restartAction: () -> Void
    var menuAction: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    VStack {
                        Text(getTitle())
                            .cFont(size: 25, color: .white)
                            .shadow(radius: 5)
                    }
                    .padding()
                    .frame(height: 80)
                    .background (
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.Theme.mainColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .frame(width: 300, alignment: .center)
                    )
                    .zIndex(1)
                    
                    VStack {
                        Spacer()
                            .frame(height: 30)
                        
                        if type == .YOUWIN || type == .GAMEOVER {
                            ScoreView()
                            Spacer()
                                .frame(height: 30)
                        }
                        
                        if type == .PAUSE {
                            ChickenButton(text: "Resume".uppercased(), width: 200) {
                                resumeAction()
                            }
                            .frame(width: 200)
                        }
                        
                        if type != .YOULOSE && type != .YOUWIN {
                            ChickenButton(text: "Restart".uppercased(), width: 200) {
                                restartAction()
                            }
                            .frame(width: 200)
                        }
                        
                        ChickenButton(text: "MENU".uppercased(), width: 200) {
                            menuAction()
                        }
                    }
                    .padding()
                    .background (
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.Theme.mainColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .frame(width: 350, alignment: .center)
                    )
                    .offset(y: -40)
                    .zIndex(0)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .background(
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .allowsTightening(false)
        )
    }
    
    private func getTitle() -> String {
        switch type {
        case .PAUSE:
            return "PAUSE"
        case .GAMEOVER:
            return "GAME OVER!"
        case .YOUWIN:
            return "YOU WIN!"
        case .YOULOSE:
            return "YOU LOSE!"
        }
    }
}

#Preview {
    MenuDialogView(type: .PAUSE, resumeAction: {}, restartAction: {}, menuAction: {})
}
