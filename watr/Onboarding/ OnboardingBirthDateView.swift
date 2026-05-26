//
//   OnboardingBirthDateView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingBirthDateView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("When were\nyou born?")
                        .font(.system(size: 34, weight: .light))
                    
                    Text("This will be used to calibrate your custom plan.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 48)
                
                Spacer()
                
                DatePicker(
                    "Birth Date",
                    selection: $profile.birthDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal, 28)
                
                Spacer()
                
                NavigationLink {
                    OnboardingBodyView()
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
