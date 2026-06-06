//
//   OnboardingBodyView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingBodyView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    let heights: [Double] = Array(stride(from: 48.0, through: 96.0, by: 1.0))
    let weights: [Double] = Array(stride(from: 80.0, through: 400.0, by: 1.0))
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Height & weight")
                        .watrScreenTitle()
                    
                    Text("This will be used to calibrate your custom plan.")
                        .watrScreenSubtitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                HStack(spacing: 0) {
                    VStack(spacing: 8) {
                        Text("Height")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Picker("Height", selection: $profile.heightInches) {
                            ForEach(heights, id: \.self) { h in
                                let feet = Int(h) / 12
                                let inches = Int(h) % 12
                                Text("\(feet)ft \(inches)in").tag(h)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Weight (lb)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        Picker("Weight", selection: $profile.weightLbs) {
                            ForEach(weights, id: \.self) { w in
                                Text("\(Int(w)) lb").tag(w)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(maxWidth: .infinity)
                    }
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
                
                NavigationLink {
                    OnboardingCoachView()
                        .environmentObject(profile)
                } label: {
                    Text("Continue")
                        .watrPrimaryButton()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
