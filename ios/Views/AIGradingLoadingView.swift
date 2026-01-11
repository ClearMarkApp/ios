//
//  AIGradingLoadingView.swift
//  ios
//
//  Created by Lucian Cheng on 2026-01-10.
//

import SwiftUI

struct AIGradingLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.0
    @State private var particleRotation: Double = 0
    @State private var glowPulse: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        ZStack {
            // Blurred background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            VStack(spacing: 24) {
                // Animated sparkles icon
                ZStack {
                    ForEach(0..<8) { index in
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.cyan.opacity(0.6),
                                        Color.purple.opacity(0.6)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 6, height: 6)
                            .offset(y: -60)
                            .rotationEffect(.degrees(Double(index) * 45 + particleRotation))
                            .opacity(0.8)
                    }
                    
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(
                                Color.white.opacity(0.7)
                            )
                            .frame(width: 4, height: 4)
                            .offset(y: -50)
                            .rotationEffect(.degrees(Double(index) * 60 - particleRotation * 0.7))
                            .opacity(0.6)
                    }
                    
                    // Outer rotating ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.5),
                                    Color.blue.opacity(0.6),
                                    Color.cyan.opacity(0.7),
                                    Color.purple.opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(rotation))
                        .shadow(color: Color.cyan.opacity(0.5), radius: 8, x: 0, y: 0)
                    
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.4),
                                    Color.blue.opacity(0.5),
                                    Color.purple.opacity(0.4)
                                ],
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-rotation * 0.7))
                    
                    // Inner pulsing circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.purple.opacity(0.3),
                                    Color.blue.opacity(0.2),
                                    Color.cyan.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(scale)
                        .blur(radius: 2)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.cyan.opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 70, height: 70)
                        .scaleEffect(glowPulse)
                        .blur(radius: 8)
                    
                    // Sparkles icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.cyan, Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.cyan.opacity(0.8), radius: 10, x: 0, y: 0)
                        .shadow(color: Color.purple.opacity(0.6), radius: 15, x: 0, y: 0)
                }
                .frame(width: 100, height: 100)
                
                VStack(spacing: 12) {
                    ZStack {
                        Text("AI Grading in Progress")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("AI Grading in Progress")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.8),
                                        Color.cyan.opacity(0.6),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.clear, Color.white, Color.clear],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .offset(x: shimmerOffset)
                            )
                    }
                    
                    Text("Analyzing submission and generating grades...")
                        .font(.system(size: 15))
                        .foregroundColor(.black.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Animated dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.cyan, Color.blue],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 8, height: 8)
                                .scaleEffect(scale)
                                .shadow(color: Color.cyan.opacity(0.6), radius: 4, x: 0, y: 0)
                                .animation(
                                    Animation
                                        .easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: scale
                                )
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.purple.opacity(0.5), radius: 25, x: 0, y: 10)
                    .shadow(color: Color.cyan.opacity(0.4), radius: 15, x: 0, y: 5)
                    .shadow(color: Color.blue.opacity(0.3), radius: 30, x: 0, y: 15)
            )
            .scaleEffect(opacity)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
            
            withAnimation(
                Animation.linear(duration: 2.0)
                    .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
            
            withAnimation(
                Animation.spring(response: 1.2, dampingFraction: 0.6)
                    .repeatForever(autoreverses: true)
            ) {
                scale = 1.2
            }
            
            withAnimation(
                Animation.linear(duration: 8.0)
                    .repeatForever(autoreverses: false)
            ) {
                particleRotation = 360
            }
            
            withAnimation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                glowPulse = 1.4
            }
            
            withAnimation(
                Animation.linear(duration: 2.5)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerOffset = 400
            }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 16_666_666) // ~60 FPS
                rotation += 0.5 // Smooth continuous rotation
                particleRotation += 0.33 // Slower particle rotation
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        AIGradingLoadingView()
    }
}
