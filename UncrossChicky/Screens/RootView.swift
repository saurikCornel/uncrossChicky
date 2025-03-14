//
//  RootView.swift
//  MissionUncrossableChicken
//
//  Created by Alexander Belov on 2/6/25.
//

import Foundation
import SwiftUI



enum SelectedScreen {
    case MENU
    case RUN_CHICKY
    case COLLECT_EGGS
    case PUZZLE_GAME
    case PRIZE
    
}

class Navigator: ObservableObject {
    static var shared = Navigator()
    @Published var selectedScreen: SelectedScreen = .MENU
}

class RootViewModel: ObservableObject {
    @Published var isLoading: Bool = true
    @AppStorage("isNeeded") var isNeeded: Bool = false
    @Published var isActive = false
    @Published var urlToLoad: URL?
    private let navigator: Navigator // Передаем Navigator через инициализатор
    
    init(navigator: Navigator = Navigator.shared) {
        self.navigator = navigator
        Task {
            let validURL = await NetworkManager.isURLValid()
            
            if validURL, let validLink = URL(string: Constants.urlForValidation) {
                await MainActor.run {
                    self.urlToLoad = validLink
                    withAnimation {
                        isNeeded = true
                        isActive = true
                        isLoading = false
                    }
                }
            } else {
                await MainActor.run {
                    self.urlToLoad = URL(string: Constants.urlForValidation)
                    isNeeded = false
                    isActive = true
                    isLoading = false
                    navigator.selectedScreen = .PRIZE // Используем переданный navigator
                }
            }
        }
    }
}

struct RootView: View {
    @StateObject var vm = RootViewModel()
    @EnvironmentObject var navigator: Navigator
    
    var body: some View {
        GeometryReader { geo in
            let isLandscape = geo.size.width > geo.size.height
            
            ZStack {
//                if isLandscape {
//                    RotateScreenView()
//                } else {
                    
                    
                    if vm.isLoading {
                        LoadingScreen()
                    } else {
                        
                       
                            
                            ZStack {
                                switch navigator.selectedScreen {
                                case .MENU:
                                    MenuScreen()
                                case .RUN_CHICKY:
                                    GameView()
                                case .COLLECT_EGGS:
                                    CollectEggsGame()
                                case .PUZZLE_GAME:
                                    ChcsPuzzleGame(closeGame: {})
                               
                                case .PRIZE:
                                    if !vm.isNeeded {
                                        if let url = vm.urlToLoad {
                                            
                                            BrowserView(pageURL: url)
                                                .onAppear {
                                                    vm.isNeeded = false
                                                    UIViewController.attemptRotationToDeviceOrientation()
                                                }
                                                .transition(.opacity) // Плавный переход
                                                .edgesIgnoringSafeArea(.all)
                                        }
                                    } else {
                                        EmptyView()
                                    }
                                }
                            }
                            .onAppear {
                                vm.isNeeded = true
                            }
                            .transition(.opacity) // Плавный переход
                            
                        
                        
                        
                        
                        
                    }
                
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
            .onReceive(Navigator.shared.$selectedScreen, perform: { _ in
                UIViewController.attemptRotationToDeviceOrientation()
            })
           
        }
        
    }
}
