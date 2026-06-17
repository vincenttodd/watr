//
//  SettingsView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI
import StoreKit
import UserNotifications

struct SettingsView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var subscriptionService: SubscriptionService
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("pausedUntil") private var pausedUntilTimestamp: Double = 0
    @State private var showManageSubscriptions = false

    private var isPaused: Bool {
        pausedUntilTimestamp > Date().timeIntervalSince1970
    }

    private var activePauseDays: Int? {
        guard isPaused else { return nil }
        let remaining = pausedUntilTimestamp - Date().timeIntervalSince1970
        return Int(ceil(remaining / 86400))
    }

    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    backButton
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Settings")
                            .font(.unica(38))
                            .padding(.bottom, 12)
                            .padding(.horizontal, 20)

                        divider

                        // Pause Notifications row
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Text("Pause Notifications")
                                    .font(.unica(17))
                                    .foregroundStyle(.primary)
                                Spacer()
                                HStack(spacing: 8) {
                                    ForEach(["1d", "3d", "5d"], id: \.self) { duration in
                                        pauseButton(duration)
                                    }
                                }
                            }
                            Text("Pausing notifications temporarily disables reminders and weekly reports")
                                .font(.unica(14))
                                .foregroundStyle(.secondary)

                            if isPaused, let days = activePauseDays {
                                Text("Paused · Resumes in \(days)d. Tap again to cancel.")
                                    .font(.unica(13))
                                    .foregroundStyle(Color.watrPrimary)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .animation(.easeInOut(duration: 0.2), value: isPaused)

                        divider

                        // Disable Notifications row
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 16) {
                                Text("Disable Notifications")
                                    .font(.unica(17))
                                    .foregroundStyle(.primary)
                                Spacer()
                                Toggle("", isOn: Binding(
                                    get: { !notificationsEnabled },
                                    set: { disable in
                                        notificationsEnabled = !disable
                                        if disable {
                                            NotificationService.shared.cancelAll()
                                            pausedUntilTimestamp = 0
                                        } else {
                                            if let profile = ProfileService.shared.load() {
                                                NotificationService.shared.rescheduleIfNeeded(profile: profile)
                                            }
                                        }
                                    }
                                ))
                                .tint(Color.watrPrimary)
                                .labelsHidden()
                            }
                            Text("Reminders and weekly report notifications will be disabled")
                                .font(.unica(14))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)

                        divider

                        Button {
                            showManageSubscriptions = true
                        } label: {
                            settingRow(label: "Manage Subscription")
                        }
                        .buttonStyle(.plain)

                        divider

                        Link(destination: URL(string: "mailto:watr@vincenttodd.com?subject=Bug%20Report")!) {
                            settingRow(label: "Report Bug")
                        }
                        .foregroundStyle(.primary)

                        divider

                        Link(destination: URL(string: "mailto:watr@vincenttodd.com?subject=Feedback")!) {
                            settingRow(label: "Send Feedback")
                        }
                        .foregroundStyle(.primary)

                        divider

                        Link(destination: URL(string: "https://vincenttodd.com/privacy")!) {
                            settingRow(label: "Privacy Policy")
                        }
                        .foregroundStyle(.primary)

                        divider

                        Link(destination: URL(string: "https://vincenttodd.com/terms")!) {
                            settingRow(label: "Terms")
                        }
                        .foregroundStyle(.primary)

                        divider

                        #if DEBUG
                        VStack(spacing: 0) {
                            // Test notification
                            Button {
                                let content = UNMutableNotificationContent()
                                content.title = "wakey wakey 💧"
                                content.body = "drink 13oz rn no excuses"
                                content.sound = .default
                                content.categoryIdentifier = "HYDRATION_REMINDER"
                                content.userInfo = [
                                    "windowName": "Upon Waking",
                                    "dayKey": dayKey(),
                                    "windowIndex": 0
                                ]
                                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                                let request = UNNotificationRequest(
                                    identifier: "watr-test",
                                    content: content,
                                    trigger: trigger
                                )
                                UNUserNotificationCenter.current().add(request)
                            } label: {
                                Text("Test notification (5s)")
                                    .font(.unica(15))
                                    .foregroundStyle(.orange)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }

                            divider

                            // Force activate notifications
                            Button {
                                NotificationService.isActivated = true
                                if let profile = ProfileService.shared.load() {
                                    NotificationService.shared.scheduleNext(profile: profile)
                                }
                            } label: {
                                Text("Force activate notifications")
                                    .font(.unica(15))
                                    .foregroundStyle(.green)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }

                            divider

                            // Print notification status
                            Button {
                                UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                                    print("=== PENDING NOTIFICATIONS ===")
                                    print("Count: \(requests.count)")
                                    for r in requests {
                                        print("ID: \(r.identifier)")
                                        print("Trigger: \(String(describing: r.trigger))")
                                    }
                                    print("isActivated: \(NotificationService.isActivated)")
                                    if let cached = NotificationPlanCache.shared.load() {
                                        print("Cache referenceDate: \(cached.referenceDate)")
                                        print("Cache today windows: \(cached.today.windows.count)")
                                    } else {
                                        print("Cache: nil")
                                    }
                                }
                            } label: {
                                Text("Print notification status")
                                    .font(.unica(15))
                                    .foregroundStyle(.purple)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }

                            divider

                            // Bypass subscription
                            Button {
                                SubscriptionService.shared.bypassPaywall()
                            } label: {
                                Text("Bypass subscription")
                                    .font(.unica(15))
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }

                            divider

                            // Re-show onboarding
                            Button {
                                hasCompletedOnboarding = false
                            } label: {
                                Text("Re-show onboarding")
                                    .font(.unica(15))
                                    .foregroundStyle(.blue.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }

                            divider

                            // Reset onboarding
                            Button {
                                ProfileService.shared.clear()
                                SubscriptionService.shared.clearBypass()
                                hasCompletedOnboarding = false
                            } label: {
                                Text("Reset onboarding")
                                    .font(.unica(15))
                                    .foregroundStyle(.red.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                            }

                            divider
                        }
                        #endif
                    }
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarHidden(true)
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
    }

    // MARK: - Pause button

    @ViewBuilder
    private func pauseButton(_ duration: String) -> some View {
        let days: Double = duration == "1d" ? 1 : duration == "3d" ? 3 : 5
        let isActive: Bool = {
            guard isPaused, let activeDays = activePauseDays else { return false }
            return activeDays == Int(days)
        }()

        let label = Text(duration)
            .font(.unica(14))
            .foregroundStyle(isActive ? Color.watrPrimary : .primary)
            .padding(.horizontal, 14)
            .frame(height: 32)

        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if isActive {
                    pausedUntilTimestamp = 0
                    if notificationsEnabled, let profile = ProfileService.shared.load() {
                        NotificationService.shared.rescheduleIfNeeded(profile: profile)
                    }
                } else {
                    pausedUntilTimestamp = Date().addingTimeInterval(days * 86400).timeIntervalSince1970
                    NotificationService.shared.cancelAll()
                    DispatchQueue.main.asyncAfter(deadline: .now() + days * 86400) {
                        guard Date().timeIntervalSince1970 >= self.pausedUntilTimestamp else { return }
                        if let profile = ProfileService.shared.load() {
                            NotificationService.shared.rescheduleIfNeeded(profile: profile)
                        }
                    }
                }
            }
        } label: {
            if #available(iOS 26.0, *) {
                label.glassEffect(.regular.interactive(), in: Capsule())
            } else {
                label
                    .background(isActive ? Color.watrPrimarySoft : Color.watrNeutralButtonBackground)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Divider

    private var divider: some View {
        Divider()
            .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
            .frame(height: 0.75)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
    }

    // MARK: - Back button

    @ViewBuilder
    private var backButton: some View {
        let label = Text("Back")
            .font(.unica(15))
            .foregroundStyle(Color.watrPrimary)
            .frame(height: 36)
            .padding(.horizontal, 18)
        Button {
            dismiss()
        } label: {
            if #available(iOS 26.0, *) {
                label.glassEffect(.regular.interactive(), in: Capsule())
            } else {
                label
                    .background(Color.watrPrimarySoft)
                    .clipShape(Capsule())
            }
        }
    }

    // MARK: - Setting row

    @ViewBuilder
    private func settingRow(label: String) -> some View {
        HStack {
            Text(label)
                .font(.unica(17))
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
    }

    // MARK: - Helpers

    private func dayKey() -> String {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }
}
