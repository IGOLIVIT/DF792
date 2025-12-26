//
//  BackgroundView.swift
//  DF792
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("BackgroundMain"),
                    Color("BackgroundSecondary"),
                    Color("BackgroundMain")
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            GeometryReader { geometry in
                // Decorative circles
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color("PrimaryAccent").opacity(0.15),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.4
                        )
                    )
                    .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                    .offset(x: -geometry.size.width * 0.2, y: -geometry.size.height * 0.1)
                
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color("SecondaryAccent").opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: geometry.size.width * 0.5
                        )
                    )
                    .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    .offset(x: geometry.size.width * 0.5, y: geometry.size.height * 0.6)
                
                // Subtle geometric shapes
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("PrimaryAccent").opacity(0.1), lineWidth: 1)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(45))
                    .offset(x: geometry.size.width * 0.7, y: geometry.size.height * 0.15)
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color("SecondaryAccent").opacity(0.08), lineWidth: 1)
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(30))
                    .offset(x: geometry.size.width * 0.1, y: geometry.size.height * 0.75)
            }
        }
        .ignoresSafeArea()
    }
}

struct AccentButton: View {
    let title: String
    let action: () -> Void
    var isPrimary: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            isPrimary ?
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("PrimaryAccent"),
                                    Color("PrimaryAccent").opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color("SecondaryAccent"),
                                    Color("SecondaryAccent").opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: (isPrimary ? Color("PrimaryAccent") : Color("SecondaryAccent")).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct CardView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("BackgroundSecondary").opacity(0.8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        VStack(spacing: 20) {
            CardView {
                Text("Card Content")
                    .foregroundColor(.white)
            }
            AccentButton(title: "Primary Button", action: {}, isPrimary: true)
            AccentButton(title: "Secondary Button", action: {}, isPrimary: false)
        }
        .padding()
    }
}

