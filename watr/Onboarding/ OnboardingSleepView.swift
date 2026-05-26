//
//   OnboardingSleepView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingSleepView: View {
    
    @EnvironmentObject var profile: OnboardingState
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sleep schedule")
                        .font(.system(size: 34, weight: .light))
                    
                    Text("This will be used to calibrate your custom plan.")
                        .font(.system(size: 16, weight: .light))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Weekday schedule
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekdays")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)
                            .padding(.horizontal, 28)
                        
                        HStack(spacing: 0) {
                            VStack(spacing: 4) {
                                Text("Wake")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: {
                                            Calendar.current.date(
                                                bySettingHour: profile.weekdayWakeHour,
                                                minute: profile.weekdayWakeMinute,
                                                second: 0,
                                                of: Date()
                                            ) ?? Date()
                                        },
                                        set: { newValue in
                                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                            profile.weekdayWakeHour = components.hour ?? 7
                                            profile.weekdayWakeMinute = components.minute ?? 0
                                        }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                            }
                            .frame(maxWidth: .infinity)
                            
                            VStack(spacing: 4) {
                                Text("Sleep")
                                    .font(.system(size: 13))
                                    .foregroundStyle(.secondary)
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: {
                                            Calendar.current.date(
                                                bySettingHour: profile.weekdaySleepHour,
                                                minute: profile.weekdaySleepMinute,
                                                second: 0,
                                                of: Date()
                                            ) ?? Date()
                                        },
                                        set: { newValue in
                                            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                            profile.weekdaySleepHour = components.hour ?? 23
                                            profile.weekdaySleepMinute = components.minute ?? 0
                                        }
                                    ),
                                    displayedComponents: .hourAndMinute
                                )
                                .labelsHidden()
                                .datePickerStyle(.wheel)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 28)
                    }
                }
                
                Spacer()
                
                NavigationLink {
                    OnboardingWorkoutView()
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
