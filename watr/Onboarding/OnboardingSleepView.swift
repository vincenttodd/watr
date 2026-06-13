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

                        scheduleSection(
                            title: "Weekdays",
                            subtitle: "Mon – Fri",
                            wakeHour: $profile.weekdayWakeHour,
                            wakeMinute: $profile.weekdayWakeMinute,
                            sleepHour: $profile.weekdaySleepHour,
                            sleepMinute: $profile.weekdaySleepMinute
                        )

                        VStack(spacing: 0) {
                            Toggle(isOn: $profile.sameScheduleOnWeekends) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Same schedule on weekends")
                                        .font(.system(size: 15))
                                    Text("Sat – Sun use these weekday times")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .tint(Color.watrPrimary)
                            .padding(.horizontal, 16)
                            .frame(minHeight: 52)
                        }
                        .watrCardSurface()
                        .watrScreenHorizontalPadding()

                        if !profile.sameScheduleOnWeekends {
                            scheduleSection(
                                title: "Weekends",
                                subtitle: "Sat – Sun",
                                wakeHour: $profile.weekendWakeHour,
                                wakeMinute: $profile.weekendWakeMinute,
                                sleepHour: $profile.weekendSleepHour,
                                sleepMinute: $profile.weekendSleepMinute
                            )
                        }
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
    private func scheduleSection(
        title: String,
        subtitle: String,
        wakeHour: Binding<Int>,
        wakeMinute: Binding<Int>,
        sleepHour: Binding<Int>,
        sleepMinute: Binding<Int>
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .watrSectionLabel()
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .watrScreenHorizontalPadding()

            VStack(spacing: 12) {
                timePicker(label: "Wake", hour: wakeHour, minute: wakeMinute)
                timePicker(label: "Sleep", hour: sleepHour, minute: sleepMinute)
            }
            .frame(maxWidth: .infinity)
            .watrScreenHorizontalPadding()
        }
    }

    @ViewBuilder
    private func timePicker(label: String, hour: Binding<Int>, minute: Binding<Int>) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
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
