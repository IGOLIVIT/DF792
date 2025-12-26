//
//  PathOfReflexGame.swift
//  DF792
//

import SwiftUI

struct PathOfReflexGame: View {
    let level: GameLevel
    @Binding var score: Int
    let onGameEnd: (Bool) -> Void
    
    @State private var shapes: [ReflexShape] = []
    @State private var currentRound = 0
    @State private var totalRounds = 10
    @State private var missedShapes = 0
    @State private var maxMisses = 3
    @State private var isGameActive = false
    @State private var countdown = 3
    @State private var showCountdown = true
    @State private var hasStarted = false
    
    private var shapeDisplayTime: Double {
        let baseTime: Double
        switch level.difficulty {
        case .easy: baseTime = 1.5
        case .normal: baseTime = 1.0
        case .hard: baseTime = 0.7
        }
        // Decrease time slightly as rounds progress
        return max(0.4, baseTime - Double(currentRound) * 0.05)
    }
    
    private var spawnInterval: Double {
        switch level.difficulty {
        case .easy: return 1.8
        case .normal: return 1.2
        case .hard: return 0.8
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Game area
                if showCountdown {
                    countdownView
                } else {
                    VStack {
                        // Stats bar
                        HStack {
                            // Lives
                            HStack(spacing: 4) {
                                ForEach(0..<maxMisses, id: \.self) { index in
                                    Image(systemName: index < (maxMisses - missedShapes) ? "heart.fill" : "heart")
                                        .foregroundColor(Color("PrimaryAccent"))
                                        .font(.system(size: 18))
                                }
                            }
                            
                            Spacer()
                            
                            // Round indicator
                            Text("Round \(min(currentRound + 1, totalRounds))/\(totalRounds)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Game area
                        ZStack {
                            ForEach(shapes) { shape in
                                ReflexShapeView(shape: shape) {
                                    tapShape(shape)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }
                }
            }
        }
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startCountdown()
            }
        }
    }
    
    private var countdownView: some View {
        VStack {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color("PrimaryAccent").opacity(0.3), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Text("\(countdown)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(Color("PrimaryAccent"))
            }
            
            Text("Get Ready!")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
                withAnimation {
                    showCountdown = false
                }
                startGame()
            }
        }
    }
    
    private func startGame() {
        isGameActive = true
        spawnNextShape()
    }
    
    private func spawnNextShape() {
        guard isGameActive && currentRound < totalRounds else {
            endGame()
            return
        }
        
        let newShape = ReflexShape(
            id: UUID(),
            position: randomPosition(),
            shapeType: ShapeType.allCases.randomElement() ?? .circle,
            color: randomColor()
        )
        
        withAnimation(.spring(response: 0.3)) {
            shapes.append(newShape)
        }
        
        // Auto-remove after display time
        DispatchQueue.main.asyncAfter(deadline: .now() + shapeDisplayTime) {
            if let index = shapes.firstIndex(where: { $0.id == newShape.id }) {
                withAnimation {
                    shapes.remove(at: index)
                }
                missedShapes += 1
                
                if missedShapes >= maxMisses {
                    endGame()
                } else {
                    currentRound += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        spawnNextShape()
                    }
                }
            }
        }
    }
    
    private func tapShape(_ shape: ReflexShape) {
        guard let index = shapes.firstIndex(where: { $0.id == shape.id }) else { return }
        
        withAnimation(.spring(response: 0.2)) {
            shapes.remove(at: index)
        }
        
        // Calculate points based on speed
        let basePoints = 10
        let difficultyMultiplier = Int(level.difficulty.multiplier * 10)
        score += basePoints + difficultyMultiplier
        
        currentRound += 1
        
        if currentRound >= totalRounds {
            endGame()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + spawnInterval * 0.5) {
                spawnNextShape()
            }
        }
    }
    
    private func endGame() {
        isGameActive = false
        let won = missedShapes < maxMisses && currentRound >= totalRounds
        onGameEnd(won)
    }
    
    private func randomPosition() -> CGPoint {
        let padding: CGFloat = 60
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let x = CGFloat.random(in: padding...(screenWidth - padding))
        let y = CGFloat.random(in: 150...(screenHeight - 250))
        
        return CGPoint(x: x, y: y)
    }
    
    private func randomColor() -> Color {
        [Color("PrimaryAccent"), Color("SecondaryAccent"), Color.white].randomElement() ?? Color("PrimaryAccent")
    }
}

struct ReflexShape: Identifiable {
    let id: UUID
    let position: CGPoint
    let shapeType: ShapeType
    let color: Color
}

enum ShapeType: CaseIterable {
    case circle
    case square
    case diamond
    case hexagon
}

struct ReflexShapeView: View {
    let shape: ReflexShape
    let onTap: () -> Void
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        Button(action: onTap) {
            shapeContent
                .frame(width: 70, height: 70)
        }
        .buttonStyle(PlainButtonStyle())
        .position(shape.position)
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    @ViewBuilder
    private var shapeContent: some View {
        switch shape.shapeType {
        case .circle:
            ZStack {
                Circle()
                    .fill(shape.color.opacity(0.3))
                Circle()
                    .stroke(shape.color, lineWidth: 3)
            }
        case .square:
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(shape.color.opacity(0.3))
                RoundedRectangle(cornerRadius: 8)
                    .stroke(shape.color, lineWidth: 3)
            }
        case .diamond:
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(shape.color.opacity(0.3))
                    .rotationEffect(.degrees(45))
                RoundedRectangle(cornerRadius: 4)
                    .stroke(shape.color, lineWidth: 3)
                    .rotationEffect(.degrees(45))
            }
        case .hexagon:
            ZStack {
                Circle()
                    .fill(shape.color.opacity(0.3))
                Circle()
                    .stroke(shape.color, lineWidth: 3)
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        PathOfReflexGame(
            level: GameLevel(id: 1, gameType: .pathOfReflex, difficulty: .easy),
            score: .constant(0),
            onGameEnd: { _ in }
        )
    }
}

