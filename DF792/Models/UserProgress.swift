//
//  UserProgress.swift
//  DF792
//

import Foundation

struct UserProgress: Codable {
    var hasCompletedOnboarding: Bool
    var pathways: [Pathway]
    var badges: [Badge]
    var milestones: [Milestone]
    var totalLevelsCompleted: Int
    var currentStreak: Int
    var bestStreak: Int
    var gamesUnlocked: Int
    
    init() {
        self.hasCompletedOnboarding = false
        self.pathways = [
            Pathway(gameType: .pathOfReflex, isUnlocked: true),
            Pathway(gameType: .balancedSteps, isUnlocked: false),
            Pathway(gameType: .patternTrails, isUnlocked: false)
        ]
        self.badges = BadgeType.allCases.map { Badge(type: $0) }
        self.milestones = [
            Milestone(id: "levels_5", title: "Complete 5 Levels", requirement: 5),
            Milestone(id: "levels_10", title: "Complete 10 Levels", requirement: 10),
            Milestone(id: "levels_20", title: "Complete 20 Levels", requirement: 20),
            Milestone(id: "pathways_1", title: "Complete 1 Pathway", requirement: 1),
            Milestone(id: "pathways_all", title: "Complete All Pathways", requirement: 3)
        ]
        self.totalLevelsCompleted = 0
        self.currentStreak = 0
        self.bestStreak = 0
        self.gamesUnlocked = 1
    }
    
    var earnedBadgesCount: Int {
        badges.filter { $0.isEarned }.count
    }
    
    var completedPathwaysCount: Int {
        pathways.filter { $0.isCompleted }.count
    }
}

