//
//  OnboardingBarrierView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingBarrierView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var navigate = false
    
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
                            navigate = true
                        } label: {
                            Text(barrier)
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
            OnboardingDrinkView()
                .environmentObject(profile)
        }
    }
}
