//
//  OnboardingPrivacyView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingPrivacyView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 24) {
                    Text("Thank you for trusting us")
                        .font(.system(size: 34, weight: .regular))
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("We strive to keep your privacy and data secure. We do not sell or share your information.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                }
                
                Spacer()
                
                NavigationLink {
                    OnboardingLocationView()
                        .environmentObject(profile)
                } label: {
                    Text("Continue")
                        .watrPrimaryButton()
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
