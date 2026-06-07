//
//   OnboardingSexView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingSexView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var navigate = false
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose your\ngender")
                        .watrScreenTitle()
                    
                    Text("This will be used to calibrate your custom plan.")
                        .watrScreenSubtitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(UserProfile.Sex.allCases, id: \.self) { sex in
                        Button {
                            profile.sex = sex
                            navigate = true
                        } label: {
                            Text(sex.rawValue.capitalized)
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
            OnboardingWorkoutView()
                .environmentObject(profile)
        }
    }
}
