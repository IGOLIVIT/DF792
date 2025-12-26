//
//  HomeView.swift
//  DF792
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var progressManager: ProgressManager
    @State private var selectedTab: HomeTab = .pathways
    @State private var showingGame: GameType?
    @State private var animateContent = true
    
    enum HomeTab: String, CaseIterable {
        case pathways = "Pathways"
        case rewards = "Rewards"
        case stats = "Stats"
        
        var icon: String {
            switch self {
            case .pathways: return "map.fill"
            case .rewards: return "trophy.fill"
            case .stats: return "chart.bar.fill"
            }
        }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Header
                headerView
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Tab selector
                tabSelector
                    .padding(.top, 20)
                
                // Content
                TabView(selection: $selectedTab) {
                    pathwaysContent
                        .tag(HomeTab.pathways)
                    
                    RewardsView(progressManager: progressManager)
                        .tag(HomeTab.rewards)
                    
                    StatsSettingsView(progressManager: progressManager)
                        .tag(HomeTab.stats)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .fullScreenCover(item: $showingGame) { gameType in
            GameContainerView(gameType: gameType, progressManager: progressManager) {
                showingGame = nil
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your Journey")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("\(progressManager.userProgress.totalLevelsCompleted) levels completed")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            // Streak indicator
            if progressManager.userProgress.currentStreak > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color("PrimaryAccent"))
                    Text("\(progressManager.userProgress.currentStreak)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("PrimaryAccent").opacity(0.2))
                )
            }
        }
    }
    
    private var tabSelector: some View {
        HStack(spacing: 8) {
            ForEach(HomeTab.allCases, id: \.rawValue) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 14, weight: .semibold))
                        Text(tab.rawValue)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.5))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(selectedTab == tab ? Color("PrimaryAccent") : Color.clear)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.1))
        )
    }
    
    private var pathwaysContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(progressManager.userProgress.pathways) { pathway in
                    PathwayCard(pathway: pathway, animateContent: animateContent) {
                        if pathway.isUnlocked {
                            showingGame = pathway.gameType
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
    }
}

struct PathwayCard: View {
    let pathway: Pathway
    let animateContent: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color("PrimaryAccent").opacity(pathway.isUnlocked ? 0.3 : 0.1),
                                        Color("PrimaryAccent").opacity(pathway.isUnlocked ? 0.1 : 0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: pathway.isUnlocked ? pathway.gameType.icon : "lock.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(pathway.isUnlocked ? Color("PrimaryAccent") : .white.opacity(0.3))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pathway.gameType.pathwayName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(pathway.isUnlocked ? .white : .white.opacity(0.4))
                        
                        Text(pathway.gameType.description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(pathway.isUnlocked ? 0.6 : 0.3))
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if pathway.isUnlocked {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                if pathway.isUnlocked {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.5))
                            
                            Spacer()
                            
                            Text("\(pathway.completedLevelsCount)/\(pathway.levels.count) levels")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("SecondaryAccent"))
                        }
                        
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
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
                                    .frame(width: geometry.size.width * pathway.progress, height: 8)
                                    .animation(.spring(response: 0.5), value: pathway.progress)
                            }
                        }
                        .frame(height: 8)
                    }
                } else {
                    // Locked message
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 14))
                        Text("Complete the previous pathway to unlock")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("BackgroundSecondary").opacity(pathway.isUnlocked ? 0.9 : 0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        pathway.isUnlocked ? Color("PrimaryAccent").opacity(0.3) : Color.white.opacity(0.05),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: pathway.isUnlocked ? Color("PrimaryAccent").opacity(0.1) : Color.clear, radius: 20, x: 0, y: 10)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(!pathway.isUnlocked)
        .opacity(animateContent ? 1 : 0)
        .offset(y: animateContent ? 0 : 20)
    }
}

#Preview {
    HomeView(progressManager: ProgressManager())
}

