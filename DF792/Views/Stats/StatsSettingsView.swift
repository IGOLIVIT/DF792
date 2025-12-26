//
//  StatsSettingsView.swift
//  DF792
//

import SwiftUI

struct StatsSettingsView: View {
    @ObservedObject var progressManager: ProgressManager
    @State private var showResetConfirmation = false
    @State private var animateStats = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Stats section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Statistics")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        StatCard(
                            icon: "checkmark.circle.fill",
                            title: "Levels Completed",
                            value: "\(progressManager.userProgress.totalLevelsCompleted)",
                            color: Color("SecondaryAccent"),
                            animate: animateStats
                        )
                        
                        StatCard(
                            icon: "flame.fill",
                            title: "Best Streak",
                            value: "\(progressManager.userProgress.bestStreak)",
                            color: Color("PrimaryAccent"),
                            animate: animateStats
                        )
                        
                        StatCard(
                            icon: "gamecontroller.fill",
                            title: "Games Unlocked",
                            value: "\(progressManager.userProgress.gamesUnlocked)/3",
                            color: Color("SecondaryAccent"),
                            animate: animateStats
                        )
                        
                        StatCard(
                            icon: "trophy.fill",
                            title: "Badges Earned",
                            value: "\(progressManager.userProgress.earnedBadgesCount)/\(progressManager.userProgress.badges.count)",
                            color: Color("PrimaryAccent"),
                            animate: animateStats
                        )
                    }
                }
                
                // Pathways progress
                VStack(alignment: .leading, spacing: 16) {
                    Text("Pathway Progress")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    ForEach(progressManager.userProgress.pathways) { pathway in
                        PathwayProgressCard(pathway: pathway)
                    }
                }
                
                // Reset section
                VStack(spacing: 16) {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, 8)
                    
                    Button {
                        showResetConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Reset Progress")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(Color("PrimaryAccent"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("PrimaryAccent"), lineWidth: 2)
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .confirmationDialog("Reset Progress", isPresented: $showResetConfirmation, titleVisibility: .visible) {
            Button("Reset All Progress", role: .destructive) {
                withAnimation {
                    progressManager.resetProgress()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase all your progress, badges, and statistics. This action cannot be undone.")
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6)) {
                    animateStats = true
                }
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("BackgroundSecondary").opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(animate ? 1 : 0.8)
        .opacity(animate ? 1 : 0)
    }
}

struct PathwayProgressCard: View {
    let pathway: Pathway
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color("PrimaryAccent").opacity(pathway.isUnlocked ? 0.2 : 0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: pathway.isUnlocked ? pathway.gameType.icon : "lock.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(pathway.isUnlocked ? Color("PrimaryAccent") : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(pathway.gameType.pathwayName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(pathway.isUnlocked ? .white : .white.opacity(0.4))
                
                if pathway.isUnlocked {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color("PrimaryAccent"),
                                            Color("SecondaryAccent")
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * pathway.progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                } else {
                    Text("Locked")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            Spacer()
            
            if pathway.isUnlocked {
                Text("\(pathway.completedLevelsCount)/\(pathway.levels.count)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color("SecondaryAccent"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("BackgroundSecondary").opacity(0.6))
        )
    }
}

#Preview {
    ZStack {
        BackgroundView()
        StatsSettingsView(progressManager: ProgressManager())
    }
}

