//
//  GameModels.swift
//  DF792
//

import Foundation

enum GameType: String, CaseIterable, Codable, Identifiable {
    case pathOfReflex = "Path of Reflex"
    case balancedSteps = "Balanced Steps"
    case patternTrails = "Pattern Trails"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .pathOfReflex:
            return "Tap the highlighted shapes before they vanish"
        case .balancedSteps:
            return "Time your taps to build a stable pathway"
        case .patternTrails:
            return "Reproduce the light sequence as it grows"
        }
    }
    
    var icon: String {
        switch self {
        case .pathOfReflex:
            return "bolt.fill"
        case .balancedSteps:
            return "square.stack.3d.up.fill"
        case .patternTrails:
            return "sparkles"
        }
    }
    
    var pathwayName: String {
        switch self {
        case .pathOfReflex:
            return "Reflex Pathway"
        case .balancedSteps:
            return "Balance Pathway"
        case .patternTrails:
            return "Pattern Pathway"
        }
    }
}

enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    
    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .easy: return 1.0
        case .normal: return 1.5
        case .hard: return 2.0
        }
    }
    
    var speedFactor: Double {
        switch self {
        case .easy: return 1.0
        case .normal: return 0.75
        case .hard: return 0.5
        }
    }
}

struct GameLevel: Identifiable, Codable, Equatable {
    let id: Int
    let gameType: GameType
    let difficulty: Difficulty
    var isCompleted: Bool
    var bestScore: Int
    
    init(id: Int, gameType: GameType, difficulty: Difficulty, isCompleted: Bool = false, bestScore: Int = 0) {
        self.id = id
        self.gameType = gameType
        self.difficulty = difficulty
        self.isCompleted = isCompleted
        self.bestScore = bestScore
    }
}

struct Pathway: Identifiable, Codable {
    let id: String
    let gameType: GameType
    var levels: [GameLevel]
    var isUnlocked: Bool
    
    var completedLevelsCount: Int {
        levels.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        guard !levels.isEmpty else { return 0 }
        return Double(completedLevelsCount) / Double(levels.count)
    }
    
    var isCompleted: Bool {
        levels.allSatisfy { $0.isCompleted }
    }
    
    init(gameType: GameType, isUnlocked: Bool = false) {
        self.id = gameType.rawValue
        self.gameType = gameType
        self.isUnlocked = isUnlocked
        
        var allLevels: [GameLevel] = []
        var levelId = 0
        for difficulty in Difficulty.allCases {
            for _ in 1...3 {
                levelId += 1
                allLevels.append(GameLevel(id: levelId, gameType: gameType, difficulty: difficulty))
            }
        }
        self.levels = allLevels
    }
}

