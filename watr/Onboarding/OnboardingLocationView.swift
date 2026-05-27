//
//  OnboardingLocationView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingLocationView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @FocusState private var zipFocused: Bool
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Where are\nyou located?")
                        .watrScreenTitle()
                    
                    Text("Used to factor in your local climate.")
                        .watrScreenSubtitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("ZIP Code")
                        .watrSectionLabel()
                    
                    TextField("e.g. 90210", text: $profile.zipCode)
                        .font(.system(size: 24, weight: .light))
                        .keyboardType(.numberPad)
                        .focused($zipFocused)
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .background(Color.watrSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
                
                NavigationLink {
                    OnboardingCompleteView()
                        .environmentObject(profile)
                } label: {
                    Text("Continue")
                        .watrPrimaryButton(enabled: profile.zipCode.count == 5)
                }
                .disabled(profile.zipCode.count != 5)
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { zipFocused = true }
    }
}
