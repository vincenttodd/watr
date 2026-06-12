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
                        .watrScreenTitle()
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("We only send daily notifications based on your preferences. You can pause notifications at any time.")
                        .watrScreenSubtitle()
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
                        OnboardingNotificationPushView()
                            .environmentObject(profile)
                    } label: {
                        Text("Don't Allow")
                            .watrLinkButton()
                    }
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
