//
//  OnboardingBarrierView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingBarrierView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var selected: String? = nil
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What's stopping you from drinking enough water?")
                        .watrScreenTitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(["Lack of consistency", "Unhealthy life habits", "Lack of support", "Busy schedule"], id: \.self) { barrier in
                        Button {
                            selected = barrier
                        } label: {
                            Text(barrier)
                                .watrSelectionButton()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.watrPrimary, lineWidth: 2)
                                        .opacity(selected == barrier ? 1 : 0)
                                )
                        }
                    }
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
                
                NavigationLink {
                    OnboardingDrinkView()
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
