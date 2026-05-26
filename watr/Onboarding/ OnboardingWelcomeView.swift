//
//   OnboardingWelcomeView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingWelcomeView: View {
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @StateObject private var profile = OnboardingState()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.957, green: 0.945, blue: 0.925)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("watr")
                            .font(.system(size: 52, weight: .light))
                            .tracking(8)
                        
                        Text("Staying hydrated,\nmade effortless.")
                            .font(.system(size: 20, weight: .light))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        NavigationLink {
                            OnboardingSexView()
                                .environmentObject(profile)
                        } label: {
                            Text("Get Started")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color(red: 0.18, green: 0.35, blue: 0.24))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        Button("Already have an account? Login") {
                            // login flow later
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 48)
                }
            }
        }
    }
}
