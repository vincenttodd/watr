//
//  OnboardingWorkoutView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingWorkoutView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @State private var navigate = false
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("How often do\nyou work out?")
                        .watrScreenTitle()
                    
                    Text("This will be used to calibrate your custom plan.")
                        .watrScreenSubtitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        profile.workoutIntensity = .light
                        profile.workoutDays = [.monday, .thursday]
                        navigate = true
                    } label: {
                        WorkoutOptionLabel(
                            icon: "square.fill",
                            range: "0–2",
                            description: "Workout now and then"
                        )
                    }
                    
                    Button {
                        profile.workoutIntensity = .moderate
                        profile.workoutDays = [.monday, .tuesday, .wednesday, .thursday, .friday]
                        navigate = true
                    } label: {
                        WorkoutOptionLabel(
                            icon: "square.grid.2x2.fill",
                            range: "4–6",
                            description: "A few workouts per week"
                        )
                    }
                    
                    Button {
                        profile.workoutIntensity = .heavy
                        profile.workoutDays = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
                        navigate = true
                    } label: {
                        WorkoutOptionLabel(
                            icon: "square.grid.3x2.fill",
                            range: "6+",
                            description: "Dedicated athlete"
                        )
                    }
                }
                .tint(.primary)
                .watrScreenHorizontalPadding()
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigate) {
            OnboardingBirthDateView()
                .environmentObject(profile)
        }
    }
}

private struct WorkoutOptionLabel: View {
    let icon: String
    let range: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.primary)
                .frame(width: 32, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(range)
                    .font(.unica(17))
                    .foregroundStyle(.primary)
                Text(description)
                    .font(.unica(14))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .frame(height: 69)
        .background(Color.watrNeutralButtonBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
