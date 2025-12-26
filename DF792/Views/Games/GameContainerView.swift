//
//  GameContainerView.swift
//  DF792
//

import SwiftUI

struct GameContainerView: View {
    let gameType: GameType
    @ObservedObject var progressManager: ProgressManager
    let onDismiss: () -> Void
    
    @State private var selectedDifficulty: Difficulty = .easy
    @State private var selectedLevel: GameLevel?
    
    var pathway: Pathway? {
        progressManager.userProgress.pathways.first { $0.gameType == gameType }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(gameType.pathwayName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Invisible spacer for centering
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                    }
                    .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Game info
                gameInfoSection
                    .padding(.top, 24)
                
                // Difficulty selector
                difficultySelector
                    .padding(.top, 24)
                
                // Levels grid
                levelsSection
                    .padding(.top, 20)
                
                Spacer()
            }
        }
        .fullScreenCover(item: $selectedLevel) { level in
            GamePlayView(
                gameType: gameType,
                level: level,
                progressManager: progressManager,
                onComplete: { success, score in
                    if success {
                        progressManager.completeLevel(gameType: gameType, levelId: level.id, score: score)
                    } else {
                        progressManager.failLevel()
                    }
                    selectedLevel = nil
                },
                onDismiss: {
                    selectedLevel = nil
                }
            )
        }
    }
    
    private var gameInfoSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color("PrimaryAccent").opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Circle()
                    .fill(Color("PrimaryAccent").opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: gameType.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(Color("PrimaryAccent"))
            }
            
            Text(gameType.description)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private var difficultySelector: some View {
        HStack(spacing: 12) {
            ForEach(Difficulty.allCases) { difficulty in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDifficulty = difficulty
                    }
                } label: {
                    Text(difficulty.rawValue)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(selectedDifficulty == difficulty ? .white : .white.opacity(0.5))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedDifficulty == difficulty ? Color("PrimaryAccent") : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    private var levelsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Level")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(getLevelsForDifficulty()) { level in
                        LevelCard(level: level, levelNumber: getLevelNumber(level)) {
                            selectedLevel = level
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func getLevelsForDifficulty() -> [GameLevel] {
        guard let pathway = pathway else { return [] }
        return pathway.levels.filter { $0.difficulty == selectedDifficulty }
    }
    
    private func getLevelNumber(_ level: GameLevel) -> Int {
        let levels = getLevelsForDifficulty()
        return (levels.firstIndex(where: { $0.id == level.id }) ?? 0) + 1
    }
}

struct LevelCard: View {
    let level: GameLevel
    let levelNumber: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            level.isCompleted ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("SecondaryAccent").opacity(0.3),
                                    Color("SecondaryAccent").opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.white.opacity(0.05)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 80)
                    
                    VStack(spacing: 4) {
                        if level.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(Color("SecondaryAccent"))
                        } else {
                            Text("\(levelNumber)")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Text("Level \(levelNumber)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                
                if level.bestScore > 0 {
                    Text("Best: \(level.bestScore)")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryAccent"))
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    GameContainerView(gameType: .pathOfReflex, progressManager: ProgressManager()) {}
}

