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
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sleep schedule")
                                .watrScreenTitle()

                            Text("We use this to space your hydration windows and reminders.")
                                .watrScreenSubtitle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .watrScreenHorizontalPadding()
                        .padding(.top, 48)

                        VStack(spacing: 12) {
                            timePicker(label: "Wake", hour: $profile.weekdayWakeHour, minute: $profile.weekdayWakeMinute)
                            timePicker(label: "Sleep", hour: $profile.weekdaySleepHour, minute: $profile.weekdaySleepMinute)
                        }
                        .frame(maxWidth: .infinity)
                        .watrScreenHorizontalPadding()
                    }
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.bottom, 24)
                }


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
        .onChange(of: profile.sameScheduleOnWeekends) { _, isSame in
            if isSame {
                profile.weekendWakeHour = profile.weekdayWakeHour
                profile.weekendWakeMinute = profile.weekdayWakeMinute
                profile.weekendSleepHour = profile.weekdaySleepHour
                profile.weekendSleepMinute = profile.weekdaySleepMinute
            }
        }
    }

    @ViewBuilder
    private func timePicker(label: String, hour: Binding<Int>, minute: Binding<Int>) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .watrScreenSubtitle()
            DatePicker(
                "",
                selection: Binding(
                    get: {
                        Calendar.current.date(
                            bySettingHour: hour.wrappedValue,
                            minute: minute.wrappedValue,
                            second: 0,
                            of: Date()
                        ) ?? Date()
                    },
                    set: { newValue in
                        let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        hour.wrappedValue = components.hour ?? hour.wrappedValue
                        minute.wrappedValue = components.minute ?? minute.wrappedValue
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
}
