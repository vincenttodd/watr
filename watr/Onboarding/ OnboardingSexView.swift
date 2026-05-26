//
//   OnboardingSexView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingSexView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Choose your\ngender")
                        .font(.system(size: 34, weight: .light))
                    
                    Text("This will be used to calibrate your custom plan.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    ForEach(UserProfile.Sex.allCases, id: \.self) { sex in
                        Button {
                            profile.sex = sex
                        } label: {
                            HStack {
                                Text(sex.rawValue.capitalized)
                                    .font(.system(size: 17))
                                    .foregroundStyle(.primary)
                                Spacer()
                                if profile.sex == sex {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color(red: 0.18, green: 0.35, blue: 0.24))
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(height: 56)
                            .background(
                                profile.sex == sex ?
                                Color(red: 0.18, green: 0.35, blue: 0.24).opacity(0.08) :
                                Color.white
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
                
                NavigationLink {
                    OnboardingBirthDateView()
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
