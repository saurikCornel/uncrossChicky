//  CocoGameScreen.swift
//  UncrossChicky
//

import Foundation
import SwiftUI


struct ChickCooGame: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var chickPosition: CGPoint = CGPoint(x: 0, y: 0)
    @State private var currentChickImage: String = "chickenPlayer1"
    @State private var animationTimer: Timer? = nil
    @State private var coins: [CGPoint] = []
    @State private var bonusItems: [CGPoint] = []
    @State private var bushes: [CGPoint] = []
    @AppStorage("coins") var score: Int = 0
    @State private var timeRemaining = 60
    @State private var isGameActive = true
    
    @State var showPauseScreen = false
    @State var gameOver = false
    

    let gridSize: CGFloat = 6
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width * 0.8
            let availableHeight = geometry.size.height * 0.8
            let gridSizeInPoints = min(availableWidth, availableHeight)
            let cellSize = gridSizeInPoints / gridSize
            ZStack {
                VStack {
                    ZStack {
                        HStack {
                            Spacer()
                        }
                    }
                    .padding(.top)
                    .padding(.horizontal)
                    .frame(height: 30)
                    
                    Spacer()
                    VStack {
                        Spacer()
                        
                        ZStack(alignment: .topLeading) {
                            GridView(gridSize: gridSize, cellSize: cellSize, coins: coins, bonusItems: bonusItems, bushes: bushes)
                            Image(currentChickImage)
                                .resizable()
                                .frame(width: cellSize * 0.75, height: cellSize * 0.75)
                                .foregroundColor(.orange)
                                .position(x: chickPosition.x * cellSize + cellSize / 2, y: chickPosition.y * cellSize + cellSize / 2)
                                .animation(.easeInOut, value: chickPosition)
                        }
                        .frame(width: cellSize * gridSize, height: cellSize * gridSize)
                        Spacer()
                    }
                    .gesture(DragGesture(minimumDistance: 5).onEnded { gesture in
                        if isGameActive {
                            moveChick(direction: gesture.translation)
                        }
                    })
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        } else {
                            isGameActive = false
                            stopChickAnimation()
                        }
                    }
                    .onAppear {
                        startChickAnimation()
                        spawnObjects()
                        chickPosition = randomEmptyPosition()
                    }
                    Text("\(timeRemaining) SECONDS")
                        .foregroundColor(.white)
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                VStack {
                    HStack {
                        Image(.pauseButton)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .onTapGesture {
                                showPauseScreen = true
                            }
                        Spacer()
                        ScoreView()
                    }
                    .padding()
                    Spacer()
                    
                }
                
                if showPauseScreen {
                    MenuDialogView(type: .PAUSE, resumeAction: {
                        showPauseScreen = false
                    }, restartAction: {
                        restartGame()
                        showPauseScreen = false
                    }, menuAction: {
                        Navigator.shared.selectedScreen = .MENU
                    })
                }
                
                if gameOver {
                    MenuDialogView(type: .GAMEOVER, resumeAction: {}, restartAction: {
                    }, menuAction: {
                        Navigator.shared.selectedScreen = .MENU
                    })
                }
            }
        }
        .dimmedOverlay(isActive: !isGameActive, overlayView: GameOverWindow(score: score, actionOnAppearIfNeeded:  {
            
        }))
        .onChange(of: isGameActive, perform: { value in
            if !value {
                timer.upstream.connect().cancel()
            }
        })
        .navigationBarBackButtonHidden(true)
        .background(
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }

    private func moveChick(direction: CGSize) {
        let newChickPosition: CGPoint

        if abs(direction.width) > abs(direction.height) {
            newChickPosition = CGPoint(x: chickPosition.x + (direction.width > 0 ? 1 : -1), y: chickPosition.y)
        } else {
            newChickPosition = CGPoint(x: chickPosition.x, y: chickPosition.y + (direction.height > 0 ? 1 : -1))
        }

        guard isValidPosition(newChickPosition) else { return }
        chickPosition = newChickPosition
        handleCollision(at: chickPosition)
    }

    private func isValidPosition(_ position: CGPoint) -> Bool {
        return position.x >= 0 && position.x < gridSize && position.y >= 0 && position.y < gridSize
    }

    private func handleCollision(at position: CGPoint) {
        if let coinIndex = coins.firstIndex(where: { $0 == position }) {
            coins.remove(at: coinIndex)
            score += 10
        }

        if let bonusIndex = bonusItems.firstIndex(where: { $0 == position }) {
            bonusItems.remove(at: bonusIndex)
            score += 25
        }

        if let bushIndex = bushes.firstIndex(where: { $0 == position }) {
            bushes.remove(at: bushIndex)
            score -= 10
        }

        if coins.isEmpty && bonusItems.isEmpty {
            isGameActive = false
            stopChickAnimation()
        }
    }

    private func spawnObjects() {
        coins = randomPositions(count: 5)
        bonusItems = randomPositions(count: 2)
        bushes = randomPositions(count: 3)
    }

    private func randomEmptyPosition() -> CGPoint {
        var emptyPosition: CGPoint
        repeat {
            emptyPosition = CGPoint(x: CGFloat(Int.random(in: 0..<Int(gridSize))), y: CGFloat(Int.random(in: 0..<Int(gridSize))))
        } while coins.contains(emptyPosition) || bonusItems.contains(emptyPosition) || bushes.contains(emptyPosition)
        return emptyPosition
    }

    private func randomPositions(count: Int) -> [CGPoint] {
        return (0..<count).map { _ in
            CGPoint(x: CGFloat(Int.random(in: 0..<Int(gridSize))), y: CGFloat(Int.random(in: 0..<Int(gridSize))))
        }
    }

    private func resetGame() {
        spawnObjects()
        chickPosition = randomEmptyPosition()
        score = 0
        timeRemaining = 60
        isGameActive = true
        startChickAnimation()
    }

    private func startChickAnimation() {
        stopChickAnimation()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.currentChickImage = (self.currentChickImage == "chickenPlayer1") ? "chickenPlayer2" : "chickenPlayer1"
        }
    }

    private func stopChickAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func restartGame() {
        chickPosition = randomEmptyPosition()
        currentChickImage = "chickenPlayer1"
        coins.removeAll()
        bonusItems.removeAll()
        bushes.removeAll()
        timeRemaining = 60
        isGameActive = true
        gameOver = false
        showPauseScreen = false
        
        spawnObjects()
        startChickAnimation()
    }
}

struct GridView: View {
    let gridSize: CGFloat
    let cellSize: CGFloat
    let coins: [CGPoint]
    let bonusItems: [CGPoint]
    let bushes: [CGPoint]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<Int(gridSize), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<Int(gridSize), id: \.self) { column in
                        let position = CGPoint(x: CGFloat(column), y: CGFloat(row))

                        ZStack {
                            Image("cell")
                                .resizable()
                                .frame(width: cellSize, height: cellSize)

                            if coins.contains(position) {
                                Image("coin")
                                    .resizable()
                                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                                    .foregroundColor(.yellow)
                            } else if bonusItems.contains(position) {
                                Image("apple")
                                    .resizable()
                                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                                    .foregroundColor(.red)
                            } else if bushes.contains(position) {
                                Image("bush")
                                    .resizable()
                                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                                    .foregroundColor(.green)
                            }
                        }
                        .frame(width: cellSize, height: cellSize)
                    }
                }
            }
        }
    }
}

#Preview {
    ChickCooGame()
}
