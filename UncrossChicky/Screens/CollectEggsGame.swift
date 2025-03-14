import Foundation
import SwiftUI

// Базовые размеры iPhone 16 (в пикселях)
private let baseWidth: CGFloat = 393
private let baseHeight: CGFloat = 852

struct EggPosition: Equatable {
    var x: CGFloat
    var y: CGFloat
}

struct CollectEggsGame: View {
    @State private var wolfPosition = 0
    @State private var eggPositions: [EggPosition] = []
    @State private var eggLanes: [Int] = []
    @State private var maxEggs = 5
    @AppStorage("coins") private var coinCounter: Int = 0
    @State private var gameHeight: CGFloat = 0
    @State private var spawnTimer: Timer?
    @State private var gameOver = false
    @State private var isGamePaused: Bool = false
    @State private var showPauseScreen: Bool = false
    @Namespace private var wolfAnimation
    let moveTimer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            let scaleX = geometry.size.width / baseWidth
            let scaleY = geometry.size.height / baseHeight
            let scale = min(scaleX, scaleY)
            
            ZStack {
                VStack(spacing: 0) {
                    ZStack {
                        ForEach(0..<4) { lane in
                            Rectangle()
                                .fill(Color.brown)
                                .frame(width: 0.3 * baseWidth * scale, height: 10 * scale + 20)
                                .rotationEffect(rotationForLane(lane))
                                .position(
                                    x: platformXPosition(lane, width: geometry.size.width),
                                    y: platformYPosition(lane, height: geometry.size.height + 26)
                                )
                        }
                        
                        wolfImage(geometry: geometry)
                            .matchedGeometryEffect(id: "wolf", in: wolfAnimation)
                            .offset(y: (wolfPosition == 2 || wolfPosition == 4) ? 170 * scale : -18 * scale)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2), value: wolfPosition)
                        
                        ForEach(0..<eggPositions.count, id: \.self) { index in
                            Image("egg")
                                .resizable()
                                .frame(width: 20 * scale, height: 20 * scale * 1.4)
                                .position(x: eggPositions[index].x, y: eggPositions[index].y)
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    .frame(height: geometry.size.height * 0.7)
                    .onAppear {
                        gameHeight = geometry.size.height * 0.7
                        startGame()
                    }
                }
                
                VStack {
                    HStack {
                        Image(.pauseButton)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .onTapGesture {
                                pauseGame()
                                showPauseScreen = true
                            }
                            .padding(.top, geometry.safeAreaInsets.top) // Отступ сверху для safeArea
                            .padding(.leading) // Дополнительный отступ слева
                        Spacer()
                        ScoreView()
                            .padding(.top, geometry.safeAreaInsets.top) // Отступ сверху для safeArea
                            .padding(.trailing) // Дополнительный отступ справа
                    }
                    .padding(.horizontal) // Общий горизонтальный отступ
                    
                    Spacer()
                    
                    HStack(spacing: 40 * scale) {
                        VStack(spacing: 20 * scale) {
                            controlButton(image: "arrow.up.left.circle.fill", action: { wolfPosition = 1 }, scale: scale)
                            controlButton(image: "arrow.down.left.circle.fill", action: { wolfPosition = 2 }, scale: scale)
                        }
                        Spacer()
                        VStack(spacing: 20 * scale) {
                            controlButton(image: "arrow.up.right.circle.fill", action: { wolfPosition = 3 }, scale: scale)
                            controlButton(image: "arrow.down.right.circle.fill", action: { wolfPosition = 4 }, scale: scale)
                        }
                    }
                    .padding(20 * scale)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                if showPauseScreen {
                    MenuDialogView(type: .PAUSE, resumeAction: {
                        showPauseScreen = false
                        resumeGame()
                    }, restartAction: {
                        showPauseScreen = false
                    }, menuAction: {
                        Navigator.shared.selectedScreen = .MENU
                    })
                }
                
                if gameOver {
                    MenuDialogView(type: .GAMEOVER, resumeAction: {}, restartAction: {
                        restartGame()
                    }, menuAction: {
                        Navigator.shared.selectedScreen = .MENU
                    })
                }
            }
            .background(
                Image(.backgroundEggs)
                    .resizable()
                    .scaledToFill()
            )
            .ignoresSafeArea()
            .onReceive(moveTimer) { _ in
                if !isGamePaused {
                    moveEggs()
                    checkCollisions()
                    checkFallenEggs()
                }
            }
            .onDisappear {
                stopGame()
            }
        }
    }
    
    private func wolfImage(geometry: GeometryProxy) -> some View {
        let scale = geometry.size.width / baseWidth
        let image: Image
        switch wolfPosition {
        case 1: image = Image("leftUP")
        case 2: image = Image("downLeft")
        case 3: image = Image("rightUp")
        case 4: image = Image("downRight")
        default: image = Image("center")
        }
        return image
            .resizable()
            .scaledToFit()
            .frame(width: baseWidth * 0.5 * scale, height: baseWidth * 0.7 * scale)
    }
    
    private func wolfXPosition(_ width: CGFloat) -> CGFloat {
        let scale = width / baseWidth
        let centerX = width / 2
        switch wolfPosition {
        case 1, 2: return centerX - baseWidth * 0.15 * scale
        case 3, 4: return centerX + baseWidth * 0.15 * scale
        default: return centerX
        }
    }
    
    private func wolfYPosition(_ height: CGFloat) -> CGFloat {
        let gameHeight = height * 0.7
        switch wolfPosition {
        case 1, 3: return gameHeight * 0.4
        case 2, 4: return gameHeight * 0.8
        default: return gameHeight * 0.6
        }
    }
    
    // MARK: - Управление игрой
    func startGame() {
        guard spawnTimer == nil else { return }
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
            addEgg()
        }
    }
    
    func pauseGame() {
        spawnTimer?.invalidate()
        spawnTimer = nil
        isGamePaused = true
    }
    
    func resumeGame() {
        isGamePaused = false
        startGame()
    }
    
    func stopGame() {
        spawnTimer?.invalidate()
        spawnTimer = nil
    }
    
    func restartGame() {
        gameOver = false
        isGamePaused = false
        showPauseScreen = false
        wolfPosition = 0
        eggPositions.removeAll()
        eggLanes.removeAll()
        startGame()
    }
    
    // MARK: - Яйца
    private func addEgg() {
        guard eggPositions.count < maxEggs else { return }
        let lane = Int.random(in: 0...3)
        eggLanes.append(lane)
        eggPositions.append(startPositionForLane(lane))
    }
    
    private func startPositionForLane(_ lane: Int) -> EggPosition {
        let bounds = UIScreen.main.bounds
        let scale = bounds.width / baseWidth
        let gameHeight = bounds.height * 0.7
        switch lane {
        case 0: return EggPosition(x: bounds.width * 0.15, y: gameHeight * 0.25)
        case 1: return EggPosition(x: bounds.width * 0.15, y: gameHeight * 0.65)
        case 2: return EggPosition(x: bounds.width * 0.85, y: gameHeight * 0.25)
        case 3: return EggPosition(x: bounds.width * 0.85, y: gameHeight * 0.65)
        default: return EggPosition(x: bounds.midX, y: -50 * scale)
        }
    }
    
    private func moveEggs() {
        let scale = UIScreen.main.bounds.width / baseWidth
        for index in eggPositions.indices {
            var position = eggPositions[index]
            let lane = eggLanes[index]
            let width = UIScreen.main.bounds.width
            
            switch lane {
            case 0, 1:
                if position.x < width * 0.35 {
                    position.x += 2 * scale
                    position.y += 1.5 * scale
                } else {
                    position.y += 3 * scale
                }
            case 2, 3:
                if position.x > width * 0.65 {
                    position.x -= 2 * scale
                    position.y += 1.5 * scale
                } else {
                    position.y += 3 * scale
                }
            default: break
            }
            
            eggPositions[index] = position
        }
    }
    
    // MARK: - Коллизии
    private func checkCollisions() {
        let scale = UIScreen.main.bounds.width / baseWidth
        let wolfX = wolfXPosition(UIScreen.main.bounds.width)
        let wolfY = wolfYPosition(UIScreen.main.bounds.height)
        
        for index in eggPositions.indices {
            let eggPos = eggPositions[index]
            
            // Увеличиваем радиус столкновения с 30 до 50
            if abs(eggPos.x - wolfX) < 50 * scale && abs(eggPos.y - wolfY) < 50 * scale {
                coinCounter += 1
                resetEgg(at: index)
            }
        }
    }
    
    private func checkFallenEggs() {
        for index in eggPositions.indices {
            let pos = eggPositions[index]
            let lane = eggLanes[index]
            
            let platformEndY: CGFloat
            switch lane {
            case 0, 2:
                platformEndY = platformYPosition(lane, height: UIScreen.main.bounds.height) + 100
            case 1, 3:
                platformEndY = platformYPosition(lane, height: UIScreen.main.bounds.height) + 150
            default:
                platformEndY = UIScreen.main.bounds.height
            }
            
            if pos.y > platformEndY {
                isGamePaused = true
                gameOver = true
                resetEgg(at: index)
            }
        }
    }
    
    private func resetEgg(at index: Int) {
        let lane = Int.random(in: 0...3)
        eggLanes[index] = lane
        eggPositions[index] = startPositionForLane(lane)
    }
    
    // MARK: - Вспомогательные функции
    private func controlButton(image: String, action: @escaping () -> Void, scale: CGFloat) -> some View {
        Button(action: action) {
            Image(systemName: image)
                .resizable()
                .frame(width: 60 * scale, height: 60 * scale)
                .foregroundColor(.white)
                .background(Color.orange)
                .clipShape(Circle())
        }
    }
    
    private func rotationForLane(_ lane: Int) -> Angle {
        switch lane {
        case 0, 1: return Angle(degrees: 36)
        case 2, 3: return Angle(degrees: -36)
        default: return .zero
        }
    }
    
    private func platformXPosition(_ lane: Int, width: CGFloat) -> CGFloat {
        switch lane {
        case 0, 1: return width * 0.25
        case 2, 3: return width * 0.75
        default: return width / 2
        }
    }
    
    private func platformYPosition(_ lane: Int, height: CGFloat) -> CGFloat {
        let gameHeight = height * 0.7
        switch lane {
        case 0, 2: return gameHeight * 0.3 + 30
        case 1, 3: return gameHeight * 0.7 + 30
        default: return gameHeight * 0.5
        }
    }
}

struct CollectEggsGame_Previews: PreviewProvider {
    static var previews: some View {
        CollectEggsGame()
            .previewDevice(PreviewDevice(rawValue: "iPhone 16"))
    }
}
