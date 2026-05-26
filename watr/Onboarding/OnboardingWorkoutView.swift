//
//  OnboardingWorkoutView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingWorkoutView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    let days: [(String, UserProfile.Weekday)] = [
        ("Mon", .monday), ("Tue", .tuesday), ("Wed", .wednesday),
        ("Thu", .thursday), ("Fri", .friday), ("Sat", .saturday), ("Sun", .sunday)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Workout\nschedule")
                        .font(.system(size: 34, weight: .light))
                    
                    Text("This will be used to calibrate your custom plan.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 24) {
                    // Workout days
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Which days do you work out?")
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 28)
                        
                        HStack(spacing: 8) {
                            ForEach(days, id: \.0) { label, day in
                                Button {
                                    if profile.workoutDays.contains(day) {
                                        profile.workoutDays.removeAll { $0 == day }
                                    } else {
                                        profile.workoutDays.append(day)
                                    }
                                } label: {
                                    Text(label)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(
                                            profile.workoutDays.contains(day) ? .white : .primary
                                        )
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(
                                            profile.workoutDays.contains(day) ?
                                            Color(red: 0.18, green: 0.35, blue: 0.24) :
                                            Color.white
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                    }
                    
                    // Workout intensity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How intense are your workouts?")
                            .font(.system(size: 15, weight: .medium))
                            .padding(.horizontal, 28)
                        
                        VStack(spacing: 8) {
                            ForEach(UserProfile.WorkoutIntensity.allCases, id: \.self) { intensity in
                                Button {
                                    profile.workoutIntensity = intensity
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(intensity.rawValue.capitalized)
                                                .font(.system(size: 16))
                                                .foregroundStyle(.primary)
                                            Text(intensityDescription(intensity))
                                                .font(.system(size: 13))
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        if profile.workoutIntensity == intensity {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color(red: 0.18, green: 0.35, blue: 0.24))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .frame(height: 60)
                                    .background(
                                        profile.workoutIntensity == intensity ?
                                        Color(red: 0.18, green: 0.35, blue: 0.24).opacity(0.08) :
                                        Color.white
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                    }
                }
                
                Spacer()
                
                NavigationLink {
                    OnboardingLocationView()
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
    
    func intensityDescription(_ intensity: UserProfile.WorkoutIntensity) -> String {
        switch intensity {
        case .none:     return "I don't work out"
        case .light:    return "1–2 sessions per week"
        case .moderate: return "3–5 sessions per week"
        case .heavy:    return "6+ sessions per week"
        }
    }
}
