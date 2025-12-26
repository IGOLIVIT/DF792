//
//  RewardsView.swift
//  DF792
//

import SwiftUI

struct RewardsView: View {
    @ObservedObject var progressManager: ProgressManager
    @State private var selectedSection: RewardSection = .badges
    @State private var animateContent = false
    
    enum RewardSection: String, CaseIterable {
        case badges = "Badges"
        case milestones = "Milestones"
        
        var icon: String {
            switch self {
            case .badges: return "star.fill"
            case .milestones: return "flag.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Section selector
            HStack(spacing: 12) {
                ForEach(RewardSection.allCases, id: \.rawValue) { section in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedSection = section
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: section.icon)
                                .font(.system(size: 14, weight: .semibold))
                            Text(section.rawValue)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(selectedSection == section ? Color("BackgroundMain") : .white.opacity(0.6))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(selectedSection == section ? Color("SecondaryAccent") : Color.white.opacity(0.1))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            .padding(.top, 10)
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    switch selectedSection {
                    case .badges:
                        badgesContent
                    case .milestones:
                        milestonesContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.5)) {
                    animateContent = true
                }
            }
        }
    }
    
    private var badgesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Earned badges summary
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Earned Badges")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("\(progressManager.userProgress.earnedBadgesCount) of \(progressManager.userProgress.badges.count) unlocked")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(progressManager.userProgress.earnedBadgesCount) / CGFloat(progressManager.userProgress.badges.count))
                        .stroke(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("PrimaryAccent"), Color("SecondaryAccent")]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int((Double(progressManager.userProgress.earnedBadgesCount) / Double(progressManager.userProgress.badges.count)) * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("BackgroundSecondary").opacity(0.7))
            )
            
            // Badges grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(progressManager.userProgress.badges, id: \.id) { badge in
                    BadgeCard(badge: badge, animate: animateContent)
                }
            }
        }
    }
    
    private var milestonesContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Milestones")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            ForEach(progressManager.userProgress.milestones, id: \.id) { milestone in
                MilestoneCard(milestone: milestone, animate: animateContent)
            }
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        badge.isEarned ?
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
                    .frame(width: 60, height: 60)
                
                Image(systemName: badge.type.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(badge.isEarned ? Color("SecondaryAccent") : .white.opacity(0.2))
            }
            
            VStack(spacing: 4) {
                Text(badge.type.rawValue)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(badge.isEarned ? .white : .white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(badge.type.description)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(badge.isEarned ? 0.5 : 0.3))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("BackgroundSecondary").opacity(badge.isEarned ? 0.9 : 0.4))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            badge.isEarned ? Color("SecondaryAccent").opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(animate ? 1 : 0.9)
        .opacity(animate ? 1 : 0)
    }
}

struct MilestoneCard: View {
    let milestone: Milestone
    let animate: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        milestone.isCompleted ?
                        Color("SecondaryAccent").opacity(0.2) :
                        Color.white.opacity(0.1)
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(milestone.isCompleted ? Color("SecondaryAccent") : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(milestone.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(milestone.isCompleted ? .white : .white.opacity(0.6))
                
                // Progress bar
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
                            .frame(width: geometry.size.width * milestone.progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            // Progress text
            Text("\(milestone.currentProgress)/\(milestone.requirement)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(milestone.isCompleted ? Color("SecondaryAccent") : .white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color("BackgroundSecondary").opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            milestone.isCompleted ? Color("SecondaryAccent").opacity(0.2) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(animate ? 1 : 0.95)
        .opacity(animate ? 1 : 0)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        RewardsView(progressManager: ProgressManager())
    }
}

