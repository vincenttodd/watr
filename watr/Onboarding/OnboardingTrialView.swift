//
//  OnboardingTrialView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingTrialView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("We'll send you a reminder before your trial ends")
                        .font(.system(size: 34, weight: .regular))
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("No payment is due now.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button {
                    SubscriptionService.shared.showPaywall(from: "onboarding_complete")
                } label: {
                    Text("Continue")
                        .watrPrimaryButton()
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
