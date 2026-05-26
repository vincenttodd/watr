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
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Where are\nyou located?")
                        .font(.system(size: 34, weight: .light))
                    
                    Text("Used to factor in your local climate.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 48)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("ZIP Code")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    TextField("e.g. 90210", text: $profile.zipCode)
                        .font(.system(size: 24, weight: .light))
                        .keyboardType(.numberPad)
                        .focused($zipFocused)
                        .padding(.horizontal, 20)
                        .frame(height: 60)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 28)
                
                Spacer()
                
                NavigationLink {
                    OnboardingCompleteView()
                        .environmentObject(profile)
                } label: {
                    Text("Continue")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            profile.zipCode.count == 5 ?
                            Color(red: 0.18, green: 0.35, blue: 0.24) :
                            Color.gray.opacity(0.4)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(profile.zipCode.count != 5)
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { zipFocused = true }
    }
}
