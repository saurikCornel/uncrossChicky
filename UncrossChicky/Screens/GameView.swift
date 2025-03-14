import Foundation
import SwiftUI

struct GameView: View {
    // Константы для размеров и параметров игры
    struct Constants {
        static let screenWidth = UIScreen.main.bounds.width
        static let screenHeight = UIScreen.main.bounds.height
        static let playerWidth: CGFloat = 80
        static let playerHeight: CGFloat = 50
        
        static let laneWidth: CGFloat = screenWidth / 3
        
        static let obstacleWidth: CGFloat = 80
        static let obstacleHeight: CGFloat = 80
        
        static let coinSize: CGFloat = 30
        static let bonusWidth: CGFloat = 60
        static let bonusHeight: CGFloat = 60
        static let collisionThresholdX: CGFloat = 30
        static let collisionThresholdY: CGFloat = 100
    }
    
    @AppStorage("coins") var coinCounter: Int = 0
    
    @State var gameOver = false
    
    // Состояние игрока
    @State private var playerPosition: Int = 1 // 0 - левая полоса, 1 - центральная, 2 - правая
    @State private var playerOffset: CGFloat = Constants.screenWidth / 3 // Начальное положение игрока
    
    // Состояние объектов (препятствия, монеты, бонусы)
    @State private var obstacles: [Obstacle] = []
    @State private var coins: [Coin] = []
    @State private var bonuses: [Bonus] = []
    @State var bonusGameGameOver = false
    @State var clickCount = 0
    
    // Состояние бонусного режима и паузы
    @State private var isBonusGameActive: Bool = false
    @State private var isGamePaused: Bool = false
    @State private var showPauseScreen: Bool = false
    
    
    // Таймер для обновления игрового цикла
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // Фон
            LinearGradient(colors: [Color.Theme.mainColor, Color.Theme.seconaryColor, Color.Theme.seconaryColor, Color.Theme.seconaryColor],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            HStack {
                Spacer()
                VerticalDashedLine()
                Spacer()
                VerticalDashedLine()
                Spacer()
            }
            
            // Поле игры
            VStack(spacing: 0) {
                Spacer()
                
                // Игрок
                PlayerView()
                    .frame(width: Constants.playerWidth, height: Constants.playerHeight)
                    .offset(x: playerOffset - Constants.laneWidth, y: 0) // Позиция игрока
                    .animation(.easeInOut(duration: 0.2), value: playerOffset) // Плавная анимация
            }
            
            // Препятствия
            ForEach(obstacles) { obstacle in
                ObstacleView(obstacle: obstacle)
            }
            
            // Монеты
            ForEach(coins) { coin in
                CoinView(coin: coin)
            }
            
            // Бонусы
            ForEach(bonuses) { bonus in
                BonusView(bonus: bonus)
            }
            
            // Бонусная игра
            BonusGame(clickCount: $clickCount, gameOver: $bonusGameGameOver) {
                isBonusGameActive = false // Деактивируем бонусную игру
                isGamePaused = false // Снимаем паузу
                resumeGame() // Возобновляем игру
                bonusGameGameOver = false
                clickCount = 0
            }
                .opacity(isBonusGameActive ? 1 : 0) // Показываем только при активном бонусе
            
            VStack {
                HStack {
                    Image(.pauseButton)
                        .resizable()
                        .frame(width: 70, height: 70)
                        .onTapGesture {
                            pauseGame()
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
                    resumeGame()
                }, restartAction: {
                    restartGame()
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
        .onAppear {
            letStartAction()
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.width > 50 && playerPosition < 2 {
                        movePlayer(to: playerPosition + 1) // Инвертированный свайп: движение влево -> вправо
                    } else if gesture.translation.width < -50 && playerPosition > 0 {
                        movePlayer(to: playerPosition - 1) // Инвертированный свайп: движение вправо -> влево
                    }
                }
        )
    }
    
    // Запуск игры
    func letStartAction() {
        guard timer == nil else { return } // Защита от повторного запуска таймера
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateGame()
        }
    }
    
    // Остановка игры
    func pauseGame() {
        timer?.invalidate()
        timer = nil
    }
    
    // Возобновление игры
    func resumeGame() {
        letStartAction()
    }
    
    
    func restartGame() {
        gameOver = false
        isGamePaused = false
        isBonusGameActive = false
        bonusGameGameOver = false
        clickCount = 0
        
        playerPosition = 1
        playerOffset = Constants.screenWidth / 3
        
        obstacles.removeAll()
        bonuses.removeAll()
        
        letStartAction()
    }
    
    // Обновление игрового цикла
    func updateGame() {
        guard !isGamePaused else { return } // Не обновляем игру, если она на паузе
        
        // Добавление новых объектов
        if Int.random(in: 0...2000) < 50 {
            addObstacle()
        }
        if Int.random(in: 0...2000) < 25 {
            addCoin()
        }
        if Int.random(in: 0...2000) < 8 {
            addBonus()
        }
        
        // Обновление позиций объектов
        obstacles = obstacles.map { obstacle in
            var updatedObstacle = obstacle
            updatedObstacle.position.y += 10 // Увеличили скорость
            return updatedObstacle
        }
        coins = coins.map { coin in
            var updatedCoin = coin
            updatedCoin.position.y += 10 // Увеличили скорость
            return updatedCoin
        }
        bonuses = bonuses.map { bonus in
            var updatedBonus = bonus
            updatedBonus.position.y += 10 // Увеличили скорость
            return updatedBonus
        }
        
        // Удаление объектов, вышедших за пределы экрана
        obstacles = obstacles.filter { $0.position.y < Constants.screenHeight }
        coins = coins.filter { $0.position.y < Constants.screenHeight }
        bonuses = bonuses.filter { $0.position.y < Constants.screenHeight }
        
        // Проверка столкновений
        checkCollisions()
    }
    
    // Колбэк для препятствий
    func onObstacleCollision() {
        print("Player collided with an obstacle!")
        // Здесь можно добавить дополнительную логику
        if coinCounter >= 1000 {
            coinCounter -= 1000
        } else {
            coinCounter = 0
        }
        isGamePaused = true
        gameOver = true
    }
    
    // Колбэк для монет
    func onCoinCollision() {
        print("Player collected a coin!")
        coinCounter += 1
        // Здесь можно добавить дополнительную логику
    }
    
    // Колбэк для бонусов
    func onBonusCollision() {
        print("Player collected a bonus!")
        isBonusGameActive = true // Активируем бонусную игру
        isGamePaused = true // Ставим игру на паузу
        pauseGame() // Останавливаем таймер
   
    }
    
    // Добавление препятствия
    func addObstacle() {
        let randomLane = Int.random(in: 0...2)
        let obstacleType = ["car001", "car002", "car001", "car002", "hatch"].randomElement()!
        let newObstacle = Obstacle(
            type: obstacleType,
            position: CGPoint(x: CGFloat(randomLane) * Constants.laneWidth + Constants.laneWidth / 2, y: -Constants.obstacleHeight)
        )
        obstacles.append(newObstacle)
    }
    

    func checkCollisions() {
        let playerX = CGFloat(playerPosition) * Constants.laneWidth + Constants.laneWidth / 2
        let playerY: CGFloat = Constants.screenHeight - Constants.playerHeight // Верхняя точка игрока

        obstacles = obstacles.filter { obstacle in
            if abs(obstacle.position.x - playerX) < Constants.collisionThresholdX &&
                obstacle.position.y <= playerY &&
                obstacle.position.y >= playerY - Constants.collisionThresholdY { // Объект не слишком далеко сверху
                onObstacleCollision()
                return false
            }
            return true
        }

        coins = coins.filter { coin in
            if abs(coin.position.x - playerX) < Constants.collisionThresholdX &&
                coin.position.y <= playerY &&
                coin.position.y >= playerY - Constants.collisionThresholdY {
                onCoinCollision()
                return false
            }
           
            return true
        }

        bonuses = bonuses.filter { bonus in
            if abs(bonus.position.x - playerX) < Constants.collisionThresholdX &&
                bonus.position.y <= playerY &&
                bonus.position.y >= playerY - Constants.collisionThresholdY {
                onBonusCollision()
                return false
            }
            return true
        }
    }
    
    
    // Добавление бонуса
    func addBonus() {
        let randomLane = Int.random(in: 0...2)
        let newBonus = Bonus(position: CGPoint(x: CGFloat(randomLane) * Constants.laneWidth + Constants.laneWidth / 2, y: -Constants.bonusHeight))
        bonuses.append(newBonus)
    }
    // Добавление монеты
    func addCoin() {
        let randomLane = Int.random(in: 0...2)
        let newCoin = Coin(position: CGPoint(x: CGFloat(randomLane) * Constants.laneWidth + Constants.laneWidth / 2, y: -Constants.coinSize))
        coins.append(newCoin)
        
    }

    
    // Перемещение игрока
    func movePlayer(to newPosition: Int) {
        playerPosition = newPosition
        playerOffset = CGFloat(playerPosition) * Constants.laneWidth
    }
}

// Модель препятствия
struct Obstacle: Identifiable {
    let id = UUID() // Уникальный идентификатор
    var type: String // Тип препятствия (например, "blackCar", "hatch")
    var position: CGPoint
}

// Вид препятствия
struct ObstacleView: View {
    var obstacle: Obstacle
    var body: some View {
        Image(obstacle.type) // Отображаем картинку в зависимости от типа препятствия
            .resizable()
            .scaledToFit()
            .frame(width: GameView.Constants.obstacleWidth, height: GameView.Constants.obstacleHeight)
            .position(obstacle.position)
            .animation(.smooth, value: obstacle.position)
    }
}

// Модель монеты
struct Coin: Identifiable {
    let id = UUID() // Уникальный идентификатор
    var position: CGPoint
}

// Вид монеты
struct CoinView: View {
    var coin: Coin
    var body: some View {
        Image(.eggCoin)
            .resizable()
            .scaledToFit()
            .frame(width: GameView.Constants.coinSize, height: GameView.Constants.coinSize)
            .position(coin.position)
            .animation(.smooth, value: coin.position)
//        Circle()
//            .fill(Color.yellow)
//            .frame(width: GameView.Constants.coinSize, height: GameView.Constants.coinSize)
//            .position(coin.position)
//            .animation(.smooth, value: coin.position)
    }
}

// Модель бонуса
struct Bonus: Identifiable {
    let id = UUID() // Уникальный идентификатор
    var position: CGPoint
}

// Вид бонуса
struct BonusView: View {
    var bonus: Bonus
    var body: some View {
        Image(.bonusCoin)
            .resizable()
            .scaledToFit()
            .frame(width: GameView.Constants.bonusWidth, height: GameView.Constants.bonusHeight)
            .position(bonus.position)
            .animation(.smooth, value: bonus.position)
    }
}


struct PlayerView: View {
    @State private var isShowingFirstImage = true
    var body: some View {
        Image(isShowingFirstImage ? .chckn1Player : .chckn2Player)
            .resizable()
            .scaledToFit()
            .onAppear {
                let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                    isShowingFirstImage.toggle()
                }
                RunLoop.main.add(timer, forMode: .common)
            }
    }
}


#Preview {
    GameView()
}
