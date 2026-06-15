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

                            Text("One at a time — tap it when you drink, and we'll send the next.")
                                .watrScreenSubtitle()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .watrScreenHorizontalPadding()
                        .padding(.top, 48)

                        VStack(spacing: 0) {
                            howItWorksRow(
                                number: "1",
                                title: "Get a reminder",
                                detail: "One nudge for your current window."
                            )
                            Divider().padding(.leading, 56)
                            howItWorksRow(
                                number: "2",
                                title: "Tap it when you drink",
                                detail: "That's it — no need to open the app."
                            )
                            Divider().padding(.leading, 56)
                            howItWorksRow(
                                number: "3",
                                title: "Next one comes automatically",
                                detail: "No pile-up if you miss one."
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
