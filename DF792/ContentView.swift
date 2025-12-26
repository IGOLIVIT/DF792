//
//  ContentView.swift
//  DF792
//

import SwiftUI

struct ContentView: View {
    @StateObject private var progressManager = ProgressManager()
    
    var body: some View {
        Group {
            if progressManager.userProgress.hasCompletedOnboarding {
                HomeView(progressManager: progressManager)
            } else {
                OnboardingView(progressManager: progressManager)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
