//
//  OnboardingReminderHowItWorksView.swift
//  watr
//

import SwiftUI

struct OnboardingReminderHowItWorksView: View {

    @EnvironmentObject var profile: OnboardingState

    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How reminders work")
                                .watrScreenTitle()

                            Text("One at a time — tap the notification when you drink to get the next one.")
                                .watrScreenSubtitle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .watrScreenHorizontalPadding()
                        .padding(.top, 48)

                        VStack(spacing: 0) {
                            howItWorksRow(
                                number: "1",
                                title: "You get one reminder",
                                detail: "We send a single nudge for your current hydration window."
                            )
                            Divider().padding(.leading, 56)
                            howItWorksRow(
                                number: "2",
                                title: "Tap the notification",
                                detail: "Just tap it like any other alert — that counts. Or long-press to see a Got it button."
                            )
                            Divider().padding(.leading, 56)
                            howItWorksRow(
                                number: "3",
                                title: "Next one schedules automatically",
                                detail: "You don't need to open the app. Got it clears the alert and queues the next reminder."
                            )
                            Divider().padding(.leading, 56)
                            howItWorksRow(
                                number: "4",
                                title: "Miss one? No pile-up",
                                detail: "If you skip a window, we move on to where you are now — no stack of old alerts."
                            )
                        }
                        .watrCardSurface()
                        .watrScreenHorizontalPadding()
                    }
                    .padding(.bottom, 24)
                }

                NavigationLink {
                    OnboardingCompleteView()
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

    @ViewBuilder
    private func howItWorksRow(number: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text(number)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.watrPrimary)
                .frame(width: 28, height: 28)
                .background(Color.watrPrimarySoft)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
