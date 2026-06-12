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
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Sleep schedule")
                        .watrScreenTitle()
                    
                    Text("This will be used to calibrate your custom plan.")
                        .watrScreenSubtitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)
                
                Spacer()
                
                VStack(spacing: 32) {
                    VStack(spacing: 8) {
                        Text("Wake")
                            .font(.unica(17))
                            .foregroundStyle(.primary)
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipped()
                    }
                    
                    VStack(spacing: 8) {
                        Text("Sleep")
                            .font(.unica(17))
                            .foregroundStyle(.primary)
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
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipped()
                    }
                }
                .watrScreenHorizontalPadding()
                
                Spacer()
                
                NavigationLink {
                    OnboardingBodyView()
                        .environmentObject(profile)
                } label: {
                    Text("Continue")
                        .watrPrimaryButton()
                }
                .watrScreenHorizontalPadding()
                .padding(.top, 12)
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
