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
                Color.watrScreenBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    Image("WATRLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        NavigationLink {
                            OnboardingSexView()
                                .environmentObject(profile)
                        } label: {
                            Text("Get Started")
                                .watrPrimaryButton()
                        }
                        
                        Button("Already have an account? Login") {
                            // login flow later
                        }
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                    }
                    .watrScreenHorizontalPadding()
                    .padding(.bottom, 48)
                }
            }
        }
    }
}
