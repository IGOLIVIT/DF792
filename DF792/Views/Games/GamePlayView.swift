//
//  GamePlayView.swift
//  DF792
//

import SwiftUI

struct GamePlayView: View {
    let gameType: GameType
    let level: GameLevel
    @ObservedObject var progressManager: ProgressManager
    let onComplete: (Bool, Int) -> Void
    let onDismiss: () -> Void
    
    @State private var showingInstructions = true
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @State private var showResult = false
    @State private var didWin = false
    
    enum GameState {
        case ready
        case playing
        case finished
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            if showingInstructions {
                instructionsOverlay
            } else if showResult {
                resultOverlay
            } else {
                VStack(spacing: 0) {
                    // Game header
                    gameHeader
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    // Game content
                    gameContent
                }
            }
        }
    }
    
    private var gameHeader: some View {
        HStack {
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: 44, height: 44)
                    .background(Circle().fill(Color.white.opacity(0.1)))
            }
            
            Spacer()
            
            VStack(spacing: 2) {
                Text("Score")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                Text("\(score)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color("SecondaryAccent"))
            }
            
            Spacer()
            
            // Difficulty badge
            Text(level.difficulty.rawValue)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("PrimaryAccent").opacity(0.3))
                )
        }
    }
    
    @ViewBuilder
    private var gameContent: some View {
        switch gameType {
        case .pathOfReflex:
            PathOfReflexGame(
                level: level,
                score: $score,
                onGameEnd: handleGameEnd
            )
        case .balancedSteps:
            BalancedStepsGame(
                level: level,
                score: $score,
                onGameEnd: handleGameEnd
            )
        case .patternTrails:
            PatternTrailsGame(
                level: level,
                score: $score,
                onGameEnd: handleGameEnd
            )
        }
    }
    
    private var instructionsOverlay: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color("PrimaryAccent").opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: gameType.icon)
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundColor(Color("PrimaryAccent"))
            }
            
            VStack(spacing: 16) {
                Text(gameType.rawValue)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(getInstructions())
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            
            VStack(spacing: 8) {
                HStack(spacing: 16) {
                    InfoBadge(title: "Difficulty", value: level.difficulty.rawValue)
                    InfoBadge(title: "Level", value: "\(getLevelDisplayNumber())")
                }
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                AccentButton(title: "Start") {
                    withAnimation(.spring(response: 0.4)) {
                        showingInstructions = false
                        gameState = .playing
                    }
                }
                
                Button("Cancel") {
                    onDismiss()
                }
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
    
    private var resultOverlay: some View {
        VStack(spacing: 32) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill((didWin ? Color("SecondaryAccent") : Color("PrimaryAccent")).opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(1.2)
                    .opacity(0.5)
                
                Circle()
                    .fill((didWin ? Color("SecondaryAccent") : Color("PrimaryAccent")).opacity(0.3))
                    .frame(width: 120, height: 120)
                
                Image(systemName: didWin ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 60, weight: .semibold))
                    .foregroundColor(didWin ? Color("SecondaryAccent") : Color("PrimaryAccent"))
            }
            
            VStack(spacing: 12) {
                Text(didWin ? "Excellent!" : "Keep Trying!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(didWin ? "You completed the level successfully" : "Better luck next time")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // Score display
            VStack(spacing: 8) {
                Text("Final Score")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                Text("\(score)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color("SecondaryAccent"))
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            
            Spacer()
            
            VStack(spacing: 12) {
                AccentButton(title: didWin ? "Continue" : "Try Again") {
                    onComplete(didWin, score)
                }
                
                Button("Back to Levels") {
                    onComplete(didWin, score)
                }
                .foregroundColor(.white.opacity(0.5))
                .font(.system(size: 16, weight: .medium))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }
    
    private func getInstructions() -> String {
        switch gameType {
        case .pathOfReflex:
            return "Tap the highlighted shapes as quickly as possible before they disappear. React fast and don't miss any!"
        case .balancedSteps:
            return "Tap at the right moment to place tiles and build a stable path. Timing is everything!"
        case .patternTrails:
            return "Watch the light sequence carefully, then reproduce it in the same order. The sequence grows longer each round."
        }
    }
    
    private func getLevelDisplayNumber() -> Int {
        guard let pathway = progressManager.userProgress.pathways.first(where: { $0.gameType == gameType }) else {
            return 1
        }
        let levels = pathway.levels.filter { $0.difficulty == level.difficulty }
        return (levels.firstIndex(where: { $0.id == level.id }) ?? 0) + 1
    }
    
    private func handleGameEnd(won: Bool) {
        didWin = won
        gameState = .finished
        withAnimation(.spring(response: 0.5)) {
            showResult = true
        }
    }
}

struct InfoBadge: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.08))
        )
    }
}

#Preview {
    GamePlayView(
        gameType: .pathOfReflex,
        level: GameLevel(id: 1, gameType: .pathOfReflex, difficulty: .easy),
        progressManager: ProgressManager(),
        onComplete: { _, _ in },
        onDismiss: {}
    )
}

