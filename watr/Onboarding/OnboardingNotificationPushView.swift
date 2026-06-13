//
//   OnboardingNotificationPushView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingNotificationPushView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var navigate = false
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Don't miss your hydration windows")
                        .watrScreenTitle()
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("Users who enable notifications drink 40% more water and hit their daily goals consistently.")
                        .watrScreenSubtitle()
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        Task {
                            await NotificationService.shared.requestPermission()
                            navigate = true
                        }
                    } label: {
                        Text("Turn On Notifications")
                            .watrPrimaryButton()
                    }
                    
                    NavigationLink {
                        OnboardingReminderHowItWorksView()
                            .environmentObject(profile)
                    } label: {
                        Text("Skip for now")
                            .watrLinkButton()
                    }
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigate) {
            OnboardingCompleteView()
                .environmentObject(profile)
        }
    }
}
