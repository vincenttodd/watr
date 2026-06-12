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
                        profile.workoutIntensity = .none
                        profile.workoutDays = []
                        navigate = true
                    } label: {
                        Text("I don't work out")
                            .watrSelectionButton()
                    }

                    Button {
                        profile.workoutIntensity = .light
                        profile.workoutDays = [.monday, .thursday]
                        navigate = true
                    } label: {
                        Text("0–2 times per week")
                            .watrSelectionButton()
                    }
                    
                    Button {
                        profile.workoutIntensity = .moderate
                        profile.workoutDays = [.monday, .tuesday, .wednesday, .thursday, .friday]
                        navigate = true
                    } label: {
                        Text("3–5 times per week")
                            .watrSelectionButton()
                    }
                    
                    Button {
                        profile.workoutIntensity = .heavy
                        profile.workoutDays = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday]
                        navigate = true
                    } label: {
                        Text("6+ times per week")
                            .watrSelectionButton()
                    }
                }
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
