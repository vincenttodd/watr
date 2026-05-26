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
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Height & weight")
                        .font(.system(size: 34, weight: .light))
                    
                    Text("This will be used to calibrate your custom plan.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
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
                .padding(.horizontal, 28)
                
                Spacer()
                
                NavigationLink {
                    OnboardingSleepView()
                        .environmentObject(profile)
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color(red: 0.18, green: 0.35, blue: 0.24))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
