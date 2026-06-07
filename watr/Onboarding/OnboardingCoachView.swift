//
//  OnboardingCoachView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingCoachView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var navigate = false
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Do you currently work with a personal coach or nutritionist?")
                        .watrScreenTitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(["Yes", "No"], id: \.self) { option in
                        Button {
                            navigate = true
                        } label: {
                            Text(option)
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
            OnboardingBarrierView()
                .environmentObject(profile)
        }
    }
}
