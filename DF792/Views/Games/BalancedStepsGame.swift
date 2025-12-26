//
//  BalancedStepsGame.swift
//  DF792
//

import SwiftUI

struct BalancedStepsGame: View {
    let level: GameLevel
    @Binding var score: Int
    let onGameEnd: (Bool) -> Void
    
    @State private var tiles: [PlacedTile] = []
    @State private var movingTile: MovingTile?
    @State private var currentHeight: Int = 0
    @State private var targetHeight: Int = 8
    @State private var failedPlacements = 0
    @State private var maxFailures = 3
    @State private var isGameActive = false
    @State private var countdown = 3
    @State private var showCountdown = true
    @State private var hasStarted = false
    @State private var tileOffset: CGFloat = 0
    @State private var movingRight = true
    
    private var tileSpeed: Double {
        let baseSpeed: Double
        switch level.difficulty {
        case .easy: baseSpeed = 2.5
        case .normal: baseSpeed = 1.8
        case .hard: baseSpeed = 1.2
        }
        // Speed up slightly as tower grows
        return max(0.6, baseSpeed - Double(currentHeight) * 0.08)
    }
    
    private var tileWidth: CGFloat { 80 }
    private var tileHeight: CGFloat { 30 }
    private var tolerance: CGFloat {
        switch level.difficulty {
        case .easy: return 30
        case .normal: return 20
        case .hard: return 12
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if showCountdown {
                    countdownView
                } else {
                    VStack(spacing: 0) {
                        // Stats bar
                        HStack {
                            // Lives
                            HStack(spacing: 4) {
                                ForEach(0..<maxFailures, id: \.self) { index in
                                    Image(systemName: index < (maxFailures - failedPlacements) ? "heart.fill" : "heart")
                                        .foregroundColor(Color("PrimaryAccent"))
                                        .font(.system(size: 18))
                                }
                            }
                            
                            Spacer()
                            
                            // Height indicator
                            Text("Height: \(currentHeight)/\(targetHeight)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // Game area
                        ZStack {
                            // Base platform
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 120, height: 20)
                                .position(
                                    x: geometry.size.width / 2,
                                    y: geometry.size.height - 100
                                )
                            
                            // Placed tiles
                            ForEach(tiles) { tile in
                                TileView(width: tile.width)
                                    .position(
                                        x: tile.xPosition,
                                        y: geometry.size.height - 120 - CGFloat(tile.level) * tileHeight
                                    )
                            }
                            
                            // Moving tile
                            if let moving = movingTile {
                                TileView(width: moving.width, isMoving: true)
                                    .position(
                                        x: geometry.size.width / 2 + tileOffset,
                                        y: geometry.size.height - 120 - CGFloat(currentHeight) * tileHeight
                                    )
                            }
                            
                            // Target indicator
                            if currentHeight > 0, let lastTile = tiles.last {
                                Rectangle()
                                    .fill(Color("SecondaryAccent").opacity(0.3))
                                    .frame(width: 2, height: CGFloat(currentHeight + 2) * tileHeight)
                                    .position(
                                        x: lastTile.xPosition,
                                        y: geometry.size.height - 110 - CGFloat(currentHeight) * tileHeight / 2
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            placeTile(in: geometry)
                        }
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
        spawnMovingTile()
    }
    
    private func spawnMovingTile() {
        guard isGameActive else { return }
        
        let width = currentHeight == 0 ? tileWidth : (tiles.last?.width ?? tileWidth)
        movingTile = MovingTile(id: UUID(), width: width)
        tileOffset = -150
        movingRight = true
        
        animateTile()
    }
    
    private func animateTile() {
        guard isGameActive, movingTile != nil else { return }
        
        let targetOffset: CGFloat = movingRight ? 150 : -150
        
        withAnimation(.linear(duration: tileSpeed)) {
            tileOffset = targetOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + tileSpeed) {
            movingRight.toggle()
            if isGameActive && movingTile != nil {
                animateTile()
            }
        }
    }
    
    private func placeTile(in geometry: GeometryProxy) {
        guard isGameActive, let moving = movingTile else { return }
        
        let centerX = geometry.size.width / 2
        let currentX = centerX + tileOffset
        
        // Check alignment
        var isAligned = false
        var newWidth = moving.width
        
        if currentHeight == 0 {
            // First tile - more forgiving
            isAligned = true
        } else if let lastTile = tiles.last {
            let diff = abs(currentX - lastTile.xPosition)
            if diff <= tolerance {
                isAligned = true
                // Reduce width based on offset
                let reduction = max(0, diff - tolerance / 2)
                newWidth = max(20, moving.width - reduction)
            }
        }
        
        if isAligned {
            // Success
            let placedTile = PlacedTile(
                id: UUID(),
                xPosition: currentX,
                level: currentHeight,
                width: newWidth
            )
            
            withAnimation(.spring(response: 0.3)) {
                tiles.append(placedTile)
                currentHeight += 1
            }
            
            // Points
            let basePoints = 15
            let difficultyBonus = Int(level.difficulty.multiplier * 5)
            let precisionBonus = currentHeight == 0 ? 0 : max(0, Int(tolerance - abs(currentX - (tiles.dropLast().last?.xPosition ?? currentX))))
            score += basePoints + difficultyBonus + precisionBonus
            
            movingTile = nil
            
            if currentHeight >= targetHeight {
                endGame(won: true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    spawnMovingTile()
                }
            }
        } else {
            // Failed placement
            failedPlacements += 1
            
            withAnimation(.spring(response: 0.2)) {
                movingTile = nil
            }
            
            if failedPlacements >= maxFailures {
                endGame(won: false)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    spawnMovingTile()
                }
            }
        }
    }
    
    private func endGame(won: Bool) {
        isGameActive = false
        movingTile = nil
        onGameEnd(won)
    }
}

struct MovingTile: Identifiable {
    let id: UUID
    let width: CGFloat
}

struct PlacedTile: Identifiable {
    let id: UUID
    let xPosition: CGFloat
    let level: Int
    let width: CGFloat
}

struct TileView: View {
    let width: CGFloat
    var isMoving: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        isMoving ? Color("SecondaryAccent") : Color("PrimaryAccent"),
                        isMoving ? Color("SecondaryAccent").opacity(0.7) : Color("PrimaryAccent").opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .frame(width: width, height: 28)
            .shadow(color: (isMoving ? Color("SecondaryAccent") : Color("PrimaryAccent")).opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        BalancedStepsGame(
            level: GameLevel(id: 1, gameType: .balancedSteps, difficulty: .easy),
            score: .constant(0),
            onGameEnd: { _ in }
        )
    }
}

