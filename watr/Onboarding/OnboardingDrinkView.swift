//
//  OnboardingDrinkView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingDrinkView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var selected: String? = nil
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("What do you usually drink?")
                        .watrScreenTitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(["Tap/purified water", "Spring water", "Coffee", "Tea", "Soda", "Other"], id: \.self) { drink in
                        Button {
                            selected = drink
                        } label: {
                            Text(drink)
                                .watrSelectionButton()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .strokeBorder(Color.watrPrimary, lineWidth: 2)
                                        .opacity(selected == drink ? 1 : 0)
                                )
                        }
                    }
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
                
                NavigationLink {
                    OnboardingGoalView()
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
