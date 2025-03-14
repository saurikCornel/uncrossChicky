import Foundation
import SwiftUI




struct ChcsPuzzleGame: View {
    var closeGame: () -> Void
    @State private var grid: [[Int]] = Array(repeating: Array(repeating: 0, count: 4), count: 4)
    @State private var score: Int = 0
    @State private var isGameOver: Bool = false
    @State var showPause = false
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                VerticalDashedLine()
                Spacer()
                VerticalDashedLine()
                Spacer()
            }
            VStack {
               
                    HStack {
                        Image(.pauseButton)
                            .resizable()
                            .frame(width: 70, height: 70)
                            .onTapGesture {
                                showPause = true

                            }
                        Spacer()
                        ScoreView()
                    }
                    
                    Spacer()
                    
                
                
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let scale = size / 360 // Исходный размер игрового поля — 360x360 (4 плитки по 80 + отступы)
                    
                    VStack(spacing: 10) {
                        ForEach(0..<4, id: \.self) { i in
                            HStack(spacing: 10) {
                                ForEach(0..<4, id: \.self) { j in
                                    TileView(value: grid[i][j])
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .gesture(
                        DragGesture()
                            .onEnded { gesture in
                                handleSwipe(gesture: gesture)
                            }
                    )
                    .scaleEffect(scale) // Масштабирование игрового поля
                    .onAppear {
                        spawnRandomTile()
                        spawnRandomTile()
                    }
                    .frame(width: size, height: size) // Ограничиваем размеры игрового поля
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                }
                
                if isGameOver {
                    Text("Game Over!")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding()
            
            if showPause {
                MenuDialogView(type: .PAUSE, resumeAction: {
                    showPause = false
                }, restartAction: {
                    grid = Array(repeating: Array(repeating: 0, count: 4), count: 4)
                    showPause = false
                }, menuAction: {
                    Navigator.shared.selectedScreen = .MENU
                })
            }
            
            
        }
        .background(Color.Theme.mainColor)
        .navigationBarBackButtonHidden()
    }
    
    private func spawnRandomTile() {
        var emptyTiles: [(Int, Int)] = []
        for i in 0..<4 {
            for j in 0..<4 {
                if grid[i][j] == 0 {
                    emptyTiles.append((i, j))
                }
            }
        }
        
        if let randomTile = emptyTiles.randomElement() {
            grid[randomTile.0][randomTile.1] = [2, 4].randomElement() ?? 2
        }
    }
    
    private func handleSwipe(gesture: DragGesture.Value) {
        let translation = gesture.translation
        let direction: String
        
        if abs(translation.width) > abs(translation.height) {
            direction = translation.width > 0 ? "right" : "left"
        } else {
            direction = translation.height > 0 ? "down" : "up"
        }
        
        moveTiles(direction: direction)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            spawnRandomTile()
            if !hasAvailableMoves() {
                isGameOver = true
            }
        }
    }
    
    private func moveTiles(direction: String) {
        var moved = false
        
        // Перемещение и объединение плиток
        switch direction {
        case "up":
            for col in 0..<4 {
                var column = (0..<4).map { grid[$0][col] }
                let (newColumn, didMove) = processLine(column)
                for row in 0..<4 { grid[row][col] = newColumn[row] }
                moved = moved || didMove
            }
        case "down":
            for col in 0..<4 {
                var column = (0..<4).map { grid[$0][col] }
                column.reverse()
                let (newColumn, didMove) = processLine(column)
                column = newColumn
                column.reverse()
                for row in 0..<4 { grid[row][col] = column[row] }
                moved = moved || didMove
            }
        case "left":
            for row in 0..<4 {
                let (newRow, didMove) = processLine(grid[row])
                grid[row] = newRow
                moved = moved || didMove
            }
        case "right":
            for row in 0..<4 {
                var reversedRow = grid[row].reversed()
                let (newRow, didMove) = processLine(Array(reversedRow))
                grid[row] = newRow.reversed()
                moved = moved || didMove
            }
        default:
            break
        }
        
        if moved {
            score += calculateScore()
        }
    }
    
    private func processLine(_ line: [Int]) -> ([Int], Bool) {
        var newLine = line.filter { $0 != 0 } // Убираем нули
        var moved = false
        
        // Объединяем плитки
        if newLine.count > 1 {
            for i in 0..<newLine.count - 1 {
                if newLine[i] == newLine[i + 1] {
                    newLine[i] *= 2
                    newLine[i + 1] = 0
                    moved = true
                }
            }
        }
        
        // Убираем нули после объединения
        newLine = newLine.filter { $0 != 0 }
        
        // Заполняем оставшиеся места нулями
        while newLine.count < 4 {
            newLine.append(0)
        }
        
        return (newLine, moved || line != newLine)
    }
    
    private func hasAvailableMoves() -> Bool {
        for i in 0..<4 {
            for j in 0..<4 {
                if grid[i][j] == 0 { return true }
                
                if i > 0 && grid[i][j] == grid[i - 1][j] { return true }
                if i < 3 && grid[i][j] == grid[i + 1][j] { return true }
                if j > 0 && grid[i][j] == grid[i][j - 1] { return true }
                if j < 3 && grid[i][j] == grid[i][j + 1] { return true }
            }
        }
        return false
    }
    
    private func calculateScore() -> Int {
        return grid.flatMap { $0 }.reduce(0) { $0 + $1 }
    }
}

struct TileView: View {
    let value: Int
    var body: some View {
        ZStack {
            // Фон ячейки
            RoundedRectangle(cornerRadius: 8)
                .fill(tileColor(for: value))
                .frame(width: 80, height: 80)
            // Текст или изображение
            if let imageName = imageMapping[value] {
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    
                    .frame(width: 80, height: 80)
            } else if value > 0 {
                Text("\(value)")
                    .font(.title)
                    .bold()
            }
        }
    }
    
    private func tileColor(for value: Int) -> Color {
        switch value {
        case 0: return Color(hex: "#DDFFD1")
        case 2: return Color.green
        case 4: return Color.yellow
        case 8: return Color.orange
        case 16: return Color.orange.opacity(0.8)
        case 32: return Color.red.opacity(0.6)
        case 64: return Color.red.opacity(0.8)
        default: return Color.red
        }
    }
}

// Обновленное отображение значений на названия изображений
let imageMapping: [Int: String] = [
    2: "i1", 4: "i2", 8: "i3", 16: "i4",
    32: "i5", 64: "i6", 128: "img1", 256: "img2", 512: "img3", 1024: "img4", 2048: "img5"
]

#Preview {
    ChcsPuzzleGame(closeGame: {})
}

