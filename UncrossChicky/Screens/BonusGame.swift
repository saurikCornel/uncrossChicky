import SwiftUI

struct BonusGame: View {
    @Binding  var clickCount: Int
    @Binding  var gameOver: Bool
    @State private var bonusMultiplier: Int = 1
    var doneAction: () -> Void
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                if !gameOver {
                    // Основной экран игры
                    VStack {
                        // Текст с анимацией
                        Text(clickCount == 10 ? "HOORAY" : "CLICK \(10 - clickCount) TIMES")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(radius: 10)
                            .scaleEffect(clickCount == 10 ? 1.5 : 1.0) // Увеличиваем текст при достижении 10 кликов
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: clickCount)
                        
                        Spacer()
                            .frame(height: 20)
                        
                        Image("bonusGameChicken")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                            .onTapGesture {
                                if clickCount < 10 {
                                    // Увеличиваем счетчик кликов
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        clickCount += 1
                                    }
                                } else {
                                    if !gameOver {
                                        gameOver = true
                                        // Генерация случайного множителя бонуса
                                        bonusMultiplier = Int.random(in: 1...10)
                                    }
                                }
                            }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .background(Color.black.opacity(0.4))
                } else {
                    // Экран бонусов
                    BonusScreen(bonusMultiplier: bonusMultiplier) {
                        doneAction()
                    }
                }
            }
        }
    }
}

// Экран бонусов
struct BonusScreen: View {
    let bonusMultiplier: Int
    var doneAction: () -> Void
    @AppStorage("coins") var coinCounter: Int = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Spacer()
                
                Image("giftImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250)
                
                Text("YOU WIN!")
                    .cFont(size: 35, color: .white)
                 
                
                Text("BONUS X\(bonusMultiplier)")
                    .cFont(size: 35, color: .white)

//                
                Spacer()
                
                ChickenButton(text: "Continue".uppercased()) {
                    doneAction()
                    coinCounter *= bonusMultiplier
                }
                Spacer()
            }
            .padding()
        }
    }
}


struct ChickenButton: View {
    var text: String
    var width: CGFloat?
    var action: () -> Void
    var body: some View {
        Text(text)
            .cFont(size: 16, color: .white)
            .multilineTextAlignment(.center)
            .padding(40)
        
            .frame(height: 60)
            .frame(width: width)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.Theme.mainBlue)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                
            )
        
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    BonusScreen(bonusMultiplier: 3, doneAction: {})
}
