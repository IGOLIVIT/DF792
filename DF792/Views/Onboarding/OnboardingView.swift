//
//  OnboardingView.swift
//  DF792
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var progressManager: ProgressManager
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "map.fill",
            title: "Begin Your Journey",
            description: "Embark on pathways of challenges designed to sharpen your focus and reaction skills.",
            accentColor: "PrimaryAccent"
        ),
        OnboardingPage(
            icon: "gamecontroller.fill",
            title: "Master Each Challenge",
            description: "Each pathway contains unique mini-games with increasing difficulty levels. Complete them to unlock new adventures.",
            accentColor: "SecondaryAccent"
        ),
        OnboardingPage(
            icon: "trophy.fill",
            title: "Earn Your Rewards",
            description: "Collect badges, achieve milestones, and track your progress as you conquer each pathway.",
            accentColor: "PrimaryAccent"
        )
    ]
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 0) {
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? Color("PrimaryAccent") : Color.white.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], isActive: currentPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        AccentButton(title: "Continue") {
                            withAnimation(.spring(response: 0.5)) {
                                currentPage += 1
                            }
                        }
                        
                        Button("Skip") {
                            completeOnboarding()
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .font(.system(size: 16, weight: .medium))
                    } else {
                        AccentButton(title: "Get Started") {
                            completeOnboarding()
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func completeOnboarding() {
        progressManager.completeOnboarding()
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
    let accentColor: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let isActive: Bool
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    @State private var textOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Background glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color(page.accentColor).opacity(0.3),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(isActive ? 1.2 : 0.8)
                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isActive)
                
                // Icon container
                ZStack {
                    Circle()
                        .fill(Color(page.accentColor).opacity(0.2))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: page.icon)
                        .font(.system(size: 60, weight: .medium))
                        .foregroundColor(Color(page.accentColor))
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)
            }
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 20)
            }
            .offset(y: textOffset)
            .opacity(textOpacity)
        }
        .padding(.horizontal, 32)
        .onChange(of: isActive) { newValue in
            animateContent(active: newValue)
        }
        .onAppear {
            if isActive {
                animateContent(active: true)
            }
        }
    }
    
    private func animateContent(active: Bool) {
        if active {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                textOffset = 0
                textOpacity = 1.0
            }
        } else {
            iconScale = 0.5
            iconOpacity = 0
            textOffset = 30
            textOpacity = 0
        }
    }
}

#Preview {
    OnboardingView(progressManager: ProgressManager())
}

