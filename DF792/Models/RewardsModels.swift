//
//  RewardsModels.swift
//  DF792
//

import Foundation

enum BadgeType: String, CaseIterable, Codable, Identifiable {
    case firstStep = "First Step"
    case reflexMaster = "Reflex Master"
    case balanceExpert = "Balance Expert"
    case patternGuru = "Pattern Guru"
    case fiveLevels = "Persistent"
    case tenLevels = "Dedicated"
    case allEasy = "Easy Champion"
    case allNormal = "Normal Champion"
    case allHard = "Hard Champion"
    case pathwayComplete = "Pathway Pioneer"
    case allPathways = "Grand Master"
    case streakFive = "Hot Streak"
    case streakTen = "Unstoppable"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .firstStep: return "star.fill"
        case .reflexMaster: return "bolt.circle.fill"
        case .balanceExpert: return "scalemass.fill"
        case .patternGuru: return "sparkles"
        case .fiveLevels: return "5.circle.fill"
        case .tenLevels: return "10.circle.fill"
        case .allEasy: return "leaf.fill"
        case .allNormal: return "flame.fill"
        case .allHard: return "crown.fill"
        case .pathwayComplete: return "flag.fill"
        case .allPathways: return "trophy.fill"
        case .streakFive: return "bolt.heart.fill"
        case .streakTen: return "bolt.shield.fill"
        }
    }
    
    var description: String {
        switch self {
        case .firstStep: return "Complete your first level"
        case .reflexMaster: return "Complete all Reflex levels"
        case .balanceExpert: return "Complete all Balance levels"
        case .patternGuru: return "Complete all Pattern levels"
        case .fiveLevels: return "Complete 5 levels total"
        case .tenLevels: return "Complete 10 levels total"
        case .allEasy: return "Complete all Easy levels"
        case .allNormal: return "Complete all Normal levels"
        case .allHard: return "Complete all Hard levels"
        case .pathwayComplete: return "Complete an entire pathway"
        case .allPathways: return "Complete all pathways"
        case .streakFive: return "Win 5 levels in a row"
        case .streakTen: return "Win 10 levels in a row"
        }
    }
}

struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let type: BadgeType
    var isEarned: Bool
    var earnedDate: Date?
    
    init(type: BadgeType, isEarned: Bool = false, earnedDate: Date? = nil) {
        self.id = type.rawValue
        self.type = type
        self.isEarned = isEarned
        self.earnedDate = earnedDate
    }
}

struct Milestone: Identifiable, Codable {
    let id: String
    let title: String
    let requirement: Int
    var currentProgress: Int
    var isCompleted: Bool
    
    var progress: Double {
        guard requirement > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(requirement))
    }
    
    init(id: String, title: String, requirement: Int, currentProgress: Int = 0) {
        self.id = id
        self.title = title
        self.requirement = requirement
        self.currentProgress = currentProgress
        self.isCompleted = currentProgress >= requirement
    }
}

