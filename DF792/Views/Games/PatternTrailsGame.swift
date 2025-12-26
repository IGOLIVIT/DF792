//
//  PatternTrailsGame.swift
//  DF792
//

import SwiftUI

struct PatternTrailsGame: View {
    let level: GameLevel
    @Binding var score: Int
    let onGameEnd: (Bool) -> Void
    
    @State private var gridSize = 3
    @State private var pattern: [Int] = []
    @State private var playerInput: [Int] = []
    @State private var currentRound = 1
    @State private var maxRounds = 5
    @State private var isShowingPattern = false
    @State private var currentShowIndex = 0
    @State private var highlightedCell: Int? = nil
    @State private var isInputEnabled = false
    @State private var mistakes = 0
    @State private var maxMistakes = 2
    @State private var isGameActive = false
    @State private var countdown = 3
    @State private var showCountdown = true
    @State private var hasStarted = false
    @State private var showMessage = ""
    
    private var patternLength: Int {
        let base: Int
        switch level.difficulty {
        case .easy: base = 3
        case .normal: base = 4
        case .hard: base = 5
        }
        return base + currentRound - 1
    }
    
    private var displaySpeed: Double {
        switch level.difficulty {
        case .easy: return 0.8
        case .normal: return 0.6
        case .hard: return 0.45
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
                            // Mistakes
                            HStack(spacing: 4) {
                                ForEach(0..<maxMistakes, id: \.self) { index in
                                    Image(systemName: index < (maxMistakes - mistakes) ? "heart.fill" : "heart")
                                        .foregroundColor(Color("PrimaryAccent"))
                                        .font(.system(size: 18))
                                }
                            }
                            
                            Spacer()
                            
                            // Round indicator
                            Text("Round \(currentRound)/\(maxRounds)")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        Spacer()
                        
                        // Message
                        if !showMessage.isEmpty {
                            Text(showMessage)
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("SecondaryAccent"))
                                .padding(.bottom, 20)
                                .transition(.opacity)
                        }
                        
                        // Grid
                        let cellSize = min((geometry.size.width - 80) / CGFloat(gridSize), 100)
                        
                        VStack(spacing: 12) {
                            ForEach(0..<gridSize, id: \.self) { row in
                                HStack(spacing: 12) {
                                    ForEach(0..<gridSize, id: \.self) { col in
                                        let index = row * gridSize + col
                                        PatternCell(
                                            index: index,
                                            isHighlighted: highlightedCell == index,
                                            isPlayerInput: playerInput.contains(index) && !isShowingPattern,
                                            size: cellSize,
                                            isEnabled: isInputEnabled
                                        ) {
                                            handleCellTap(index)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(20)
                        
                        Spacer()
                        
                        // Pattern length indicator
                        HStack(spacing: 4) {
                            Text("Sequence length:")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            Text("\(patternLength)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(Color("SecondaryAccent"))
                        }
                        .padding(.bottom, 40)
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
        startNewRound()
    }
    
    private func startNewRound() {
        guard isGameActive else { return }
        
        playerInput = []
        pattern = []
        isInputEnabled = false
        
        // Generate pattern
        for _ in 0..<patternLength {
            var newCell: Int
            repeat {
                newCell = Int.random(in: 0..<(gridSize * gridSize))
            } while pattern.last == newCell
            pattern.append(newCell)
        }
        
        withAnimation {
            showMessage = "Watch the sequence..."
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showPattern()
        }
    }
    
    private func showPattern() {
        isShowingPattern = true
        currentShowIndex = 0
        showNextInPattern()
    }
    
    private func showNextInPattern() {
        guard currentShowIndex < pattern.count else {
            // Done showing pattern
            isShowingPattern = false
            highlightedCell = nil
            withAnimation {
                showMessage = "Your turn!"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputEnabled = true
                withAnimation {
                    showMessage = ""
                }
            }
            return
        }
        
        let cell = pattern[currentShowIndex]
        
        withAnimation(.easeInOut(duration: 0.2)) {
            highlightedCell = cell
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + displaySpeed * 0.7) {
            withAnimation(.easeInOut(duration: 0.15)) {
                highlightedCell = nil
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + displaySpeed * 0.3) {
                currentShowIndex += 1
                showNextInPattern()
            }
        }
    }
    
    private func handleCellTap(_ index: Int) {
        guard isInputEnabled && isGameActive else { return }
        
        playerInput.append(index)
        
        // Check if correct
        let currentIndex = playerInput.count - 1
        if pattern[currentIndex] == index {
            // Correct!
            withAnimation(.spring(response: 0.2)) {
                highlightedCell = index
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation {
                    highlightedCell = nil
                }
            }
            
            // Add points
            score += 5 + Int(level.difficulty.multiplier * 3)
            
            // Check if pattern complete
            if playerInput.count == pattern.count {
                isInputEnabled = false
                
                // Bonus for completing pattern
                score += 20 + currentRound * 5
                
                withAnimation {
                    showMessage = "Correct!"
                }
                
                if currentRound >= maxRounds {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        endGame(won: true)
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        currentRound += 1
                        withAnimation {
                            showMessage = ""
                        }
                        startNewRound()
                    }
                }
            }
        } else {
            // Wrong!
            mistakes += 1
            isInputEnabled = false
            
            withAnimation(.spring(response: 0.1)) {
                highlightedCell = index
            }
            
            withAnimation {
                showMessage = "Wrong sequence!"
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    highlightedCell = nil
                }
                
                if mistakes >= maxMistakes {
                    endGame(won: false)
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            showMessage = ""
                        }
                        startNewRound()
                    }
                }
            }
        }
    }
    
    private func endGame(won: Bool) {
        isGameActive = false
        onGameEnd(won)
    }
}

struct PatternCell: View {
    let index: Int
    let isHighlighted: Bool
    let isPlayerInput: Bool
    let size: CGFloat
    let isEnabled: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isHighlighted ?
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("SecondaryAccent"),
                            Color("SecondaryAccent").opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color("BackgroundSecondary").opacity(0.8),
                            Color("BackgroundSecondary").opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isHighlighted ? Color("SecondaryAccent") : Color.white.opacity(0.15),
                            lineWidth: isHighlighted ? 3 : 1
                        )
                )
                .frame(width: size, height: size)
                .shadow(
                    color: isHighlighted ? Color("SecondaryAccent").opacity(0.5) : Color.clear,
                    radius: 15,
                    x: 0,
                    y: 5
                )
                .scaleEffect(isHighlighted ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .animation(.spring(response: 0.2), value: isHighlighted)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        PatternTrailsGame(
            level: GameLevel(id: 1, gameType: .patternTrails, difficulty: .easy),
            score: .constant(0),
            onGameEnd: { _ in }
        )
    }
}

