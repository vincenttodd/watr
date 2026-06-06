//
//  OnboardingGoalView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingGoalView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var selected: String? = nil
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What would you like to accomplish?")
                        .watrScreenTitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(["Live healthier", "Boost my appearance", "Stay motivated and consistent", "Feel better about my body"], id: \.self) { goal in
                        Button {
                            selected = goal
                        } label: {
                            Text(goal)
                                .watrSelectionButton()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.watrPrimary, lineWidth: 2)
                                        .opacity(selected == goal ? 1 : 0)
                                )
                        }
                    }
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
                
                NavigationLink {
                    OnboardingPrivacyView()
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
