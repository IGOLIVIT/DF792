//
//  ProgressManager.swift
//  DF792
//

import Foundation
import SwiftUI
import Combine

class ProgressManager: ObservableObject {
    @Published var userProgress: UserProgress
    
    private let storageKey = "arcane_pathways_progress"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let progress = try? JSONDecoder().decode(UserProgress.self, from: data) {
            self.userProgress = progress
        } else {
            self.userProgress = UserProgress()
        }
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
    
    func completeOnboarding() {
        userProgress.hasCompletedOnboarding = true
        save()
    }
    
    func completeLevel(gameType: GameType, levelId: Int, score: Int) {
        guard let pathwayIndex = userProgress.pathways.firstIndex(where: { $0.gameType == gameType }),
              let levelIndex = userProgress.pathways[pathwayIndex].levels.firstIndex(where: { $0.id == levelId }) else {
            return
        }
        
        let wasAlreadyCompleted = userProgress.pathways[pathwayIndex].levels[levelIndex].isCompleted
        
        userProgress.pathways[pathwayIndex].levels[levelIndex].isCompleted = true
        if score > userProgress.pathways[pathwayIndex].levels[levelIndex].bestScore {
            userProgress.pathways[pathwayIndex].levels[levelIndex].bestScore = score
        }
        
        if !wasAlreadyCompleted {
            userProgress.totalLevelsCompleted += 1
            userProgress.currentStreak += 1
            if userProgress.currentStreak > userProgress.bestStreak {
                userProgress.bestStreak = userProgress.currentStreak
            }
        }
        
        unlockNextPathwayIfNeeded()
        updateMilestones()
        checkAndAwardBadges()
        save()
    }
    
    func failLevel() {
        userProgress.currentStreak = 0
        save()
    }
    
    private func unlockNextPathwayIfNeeded() {
        for (index, pathway) in userProgress.pathways.enumerated() {
            if pathway.isCompleted && index + 1 < userProgress.pathways.count {
                if !userProgress.pathways[index + 1].isUnlocked {
                    userProgress.pathways[index + 1].isUnlocked = true
                    userProgress.gamesUnlocked += 1
                }
            }
        }
    }
    
    private func updateMilestones() {
        for i in 0..<userProgress.milestones.count {
            let milestone = userProgress.milestones[i]
            switch milestone.id {
            case "levels_5", "levels_10", "levels_20":
                userProgress.milestones[i].currentProgress = userProgress.totalLevelsCompleted
                userProgress.milestones[i].isCompleted = userProgress.milestones[i].currentProgress >= milestone.requirement
            case "pathways_1":
                userProgress.milestones[i].currentProgress = userProgress.completedPathwaysCount
                userProgress.milestones[i].isCompleted = userProgress.milestones[i].currentProgress >= 1
            case "pathways_all":
                userProgress.milestones[i].currentProgress = userProgress.completedPathwaysCount
                userProgress.milestones[i].isCompleted = userProgress.milestones[i].currentProgress >= 3
            default:
                break
            }
        }
    }
    
    private func checkAndAwardBadges() {
        // First Step
        if userProgress.totalLevelsCompleted >= 1 {
            awardBadge(.firstStep)
        }
        
        // Game-specific badges
        if let reflexPathway = userProgress.pathways.first(where: { $0.gameType == .pathOfReflex }),
           reflexPathway.isCompleted {
            awardBadge(.reflexMaster)
        }
        
        if let balancePathway = userProgress.pathways.first(where: { $0.gameType == .balancedSteps }),
           balancePathway.isCompleted {
            awardBadge(.balanceExpert)
        }
        
        if let patternPathway = userProgress.pathways.first(where: { $0.gameType == .patternTrails }),
           patternPathway.isCompleted {
            awardBadge(.patternGuru)
        }
        
        // Level count badges
        if userProgress.totalLevelsCompleted >= 5 {
            awardBadge(.fiveLevels)
        }
        if userProgress.totalLevelsCompleted >= 10 {
            awardBadge(.tenLevels)
        }
        
        // Difficulty badges
        let allEasyCompleted = userProgress.pathways.allSatisfy { pathway in
            pathway.levels.filter { $0.difficulty == .easy }.allSatisfy { $0.isCompleted }
        }
        if allEasyCompleted {
            awardBadge(.allEasy)
        }
        
        let allNormalCompleted = userProgress.pathways.allSatisfy { pathway in
            pathway.levels.filter { $0.difficulty == .normal }.allSatisfy { $0.isCompleted }
        }
        if allNormalCompleted {
            awardBadge(.allNormal)
        }
        
        let allHardCompleted = userProgress.pathways.allSatisfy { pathway in
            pathway.levels.filter { $0.difficulty == .hard }.allSatisfy { $0.isCompleted }
        }
        if allHardCompleted {
            awardBadge(.allHard)
        }
        
        // Pathway badges
        if userProgress.completedPathwaysCount >= 1 {
            awardBadge(.pathwayComplete)
        }
        if userProgress.completedPathwaysCount >= 3 {
            awardBadge(.allPathways)
        }
        
        // Streak badges
        if userProgress.bestStreak >= 5 {
            awardBadge(.streakFive)
        }
        if userProgress.bestStreak >= 10 {
            awardBadge(.streakTen)
        }
    }
    
    private func awardBadge(_ type: BadgeType) {
        if let index = userProgress.badges.firstIndex(where: { $0.type == type && !$0.isEarned }) {
            userProgress.badges[index].isEarned = true
            userProgress.badges[index].earnedDate = Date()
        }
    }
    
    func resetProgress() {
        userProgress = UserProgress()
        userProgress.hasCompletedOnboarding = true
        save()
    }
    
    func getUnlockedPathways() -> [Pathway] {
        return userProgress.pathways.filter { $0.isUnlocked }
    }
    
    func getEarnedBadges() -> [Badge] {
        return userProgress.badges.filter { $0.isEarned }
    }
    
    func getLevelsForGame(_ gameType: GameType, difficulty: Difficulty) -> [GameLevel] {
        guard let pathway = userProgress.pathways.first(where: { $0.gameType == gameType }) else {
            return []
        }
        return pathway.levels.filter { $0.difficulty == difficulty }
    }
}

