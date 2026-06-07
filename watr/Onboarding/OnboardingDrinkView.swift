//
//  OnboardingDrinkView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingDrinkView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var navigate = false
    
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
                            navigate = true
                        } label: {
                            Text(drink)
                                .watrSelectionButton()
                        }
                    }
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigate) {
            OnboardingGoalView()
                .environmentObject(profile)
        }
    }
}
