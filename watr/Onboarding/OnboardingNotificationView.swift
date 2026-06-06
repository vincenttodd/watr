//
//  OnboardingNotificationView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingNotificationView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Turn on notification reminders")
                        .font(.system(size: 34, weight: .regular))
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("We only send daily notifications based on your preferences. You can pause notifications at any time.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    NavigationLink {
                        OnboardingCompleteView()
                            .environmentObject(profile)
                    } label: {
                        Text("Allow")
                            .watrPrimaryButton()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            await NotificationService.shared.requestPermission()
                        }
                    })
                    
                    NavigationLink {
                        OnboardingCompleteView()
                            .environmentObject(profile)
                    } label: {
                        Text("Don't Allow")
                            .font(.system(size: 17))
                            .foregroundStyle(.primary)
                    }
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
