//
//   OnboardingNotificationPushView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingNotificationPushView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Don't miss your hydration windows")
                        .font(.unica(34))
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("Users who enable notifications drink 40% more water and hit their daily goals consistently.")
                        .font(.unica(16))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        Task {
                            await NotificationService.shared.requestPermission()
                        }
                    } label: {
                        Text("Turn On Notifications")
                            .watrPrimaryButton()
                    }
                    
                    NavigationLink {
                        OnboardingCompleteView()
                            .environmentObject(profile)
                    } label: {
                        Text("Skip for now")
                            .font(.unica(17))
                            .foregroundStyle(.secondary)
                    }
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
