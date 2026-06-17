//
//   NotificationService.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation
import UIKit
import UserNotifications

class NotificationService {

    static let shared = NotificationService()

    private enum Action {
        static let done = "DONE"
        static let snooze = "SNOOZE"
    }

    private enum UserInfoKey {
        static let windowName = "windowName"
        static let dayKey = "dayKey"
        static let windowIndex = "windowIndex"
    }

    private static let activatedKey = "notificationsActivated"

    static var isActivated: Bool {
        get { UserDefaults.standard.bool(forKey: activatedKey) }
        set { UserDefaults.standard.set(newValue, forKey: activatedKey) }
    }

    private let snoozeMinutes = 15

    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }

    func activateAndScheduleDelayed(
        profile: UserProfile,
        todayPlan: HydrationPlan,
        tomorrowPlan: HydrationPlan
    ) {
        NotificationService.isActivated = true
        NotificationPlanCache.shared.save(
            today: todayPlan,
            tomorrow: tomorrowPlan,
            referenceDate: Date()
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 600) { [weak self] in
            self?.scheduleNext(profile: profile)
        }
    }

    func deactivate() {
        NotificationService.isActivated = false
        cancelAll()
    }

    func scheduleUpcoming(
        profile: UserProfile,
        todayPlan: HydrationPlan,
        tomorrowPlan: HydrationPlan,
        referenceDate: Date = Date()
    ) {
        guard NotificationService.isActivated else { return }
        NotificationPlanCache.shared.save(
            today: todayPlan,
            tomorrow: tomorrowPlan,
            referenceDate: referenceDate
        )
        scheduleNext(profile: profile, referenceDate: referenceDate)
    }

    func scheduleDay(plan: HydrationPlan, profile: UserProfile, on date: Date = Date()) {
        scheduleUpcoming(
            profile: profile,
            todayPlan: plan,
            tomorrowPlan: plan,
            referenceDate: date
        )
    }

    func rescheduleIfNeeded(profile: UserProfile, referenceDate: Date = Date()) {
        guard NotificationService.isActivated else { return }
        scheduleNext(profile: profile, referenceDate: referenceDate)
    }

    func scheduleNext(profile: UserProfile, referenceDate: Date = Date()) {
        guard NotificationService.isActivated else { return }
        guard let cached = NotificationPlanCache.shared.load(referenceDate: referenceDate) else { return }

        let calendar = Calendar.current
        let now = Date()
        let resolved = resolvedPlans(from: cached, referenceDate: referenceDate, calendar: calendar)

        let reminder: ScheduledReminder?
        if let next = nextReminder(
            plan: resolved.todayPlan,
            profile: profile,
            on: resolved.todayDate,
            now: now,
            calendar: calendar
        ) {
            reminder = next
        } else if
            let tomorrowPlan = resolved.tomorrowPlan,
            let tomorrowDate = resolved.tomorrowDate,
            let next = nextReminder(
                plan: tomorrowPlan,
                profile: profile,
                on: tomorrowDate,
                now: now,
                calendar: calendar
            )
        {
            reminder = next
        } else {
            reminder = nil
        }

        let center = UNUserNotificationCenter.current()
        clearDeliveredHydrationNotifications()
        center.getPendingNotificationRequests { [weak self] requests in
            guard let self else { return }
            let watrIds = requests.map(\.identifier).filter { $0.hasPrefix("watr-") }
            if !watrIds.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: watrIds)
            }
            if let reminder {
                self.enqueue(reminder, calendar: calendar)
            }
        }
    }

    func handle(response: UNNotificationResponse) {
        guard response.notification.request.content.categoryIdentifier == "HYDRATION_REMINDER" else { return }

        let userInfo = response.notification.request.content.userInfo
        guard
            let windowName = userInfo[UserInfoKey.windowName] as? String,
            let dayKey = userInfo[UserInfoKey.dayKey] as? String
        else { return }

        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: [response.notification.request.identifier])

        switch response.actionIdentifier {
        case Action.done, UNNotificationDefaultActionIdentifier:
            NotificationProgressService.shared.markComplete(windowName: windowName, dayKey: dayKey)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            rescheduleFromCache()
        case Action.snooze:
            if let index = userInfo[UserInfoKey.windowIndex] as? Int,
               let cached = NotificationPlanCache.shared.load() {
                let calendar = Calendar.current
                let planDay = dayDate(from: dayKey, calendar: calendar) ?? cached.referenceDate
                let plan = calendar.isDate(planDay, inSameDayAs: cached.referenceDate) ? cached.today : cached.tomorrow
                guard index < plan.windows.count else { return }
                let window = plan.windows[index]
                let fireDate = Date().addingTimeInterval(TimeInterval(snoozeMinutes * 60))
                let snoozeReminder = ScheduledReminder(
                    window: window,
                    index: index,
                    totalCount: plan.windows.count,
                    fireDate: fireDate,
                    dayKey: dayKey,
                    planDay: planDay
                )
                center.getPendingNotificationRequests { [weak self] requests in
                    guard let self else { return }
                    let watrIds = requests.map(\.identifier).filter { $0.hasPrefix("watr-") }
                    if !watrIds.isEmpty {
                        center.removePendingNotificationRequests(withIdentifiers: watrIds)
                    }
                    self.enqueue(snoozeReminder, calendar: calendar)
                }
            }
        default:
            break
        }
    }

    func cancelAll() {
        let center = UNUserNotificationCenter.current()
        cancelPendingWatrNotifications(center: center)
        clearDeliveredHydrationNotifications()
    }

    private func cancelPendingWatrNotifications(center: UNUserNotificationCenter) {
        center.getPendingNotificationRequests { requests in
            let ids = requests.map(\.identifier).filter { $0.hasPrefix("watr-") }
            guard !ids.isEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
    }

    func registerCategories() {
        let doneAction = UNNotificationAction(
            identifier: "DONE",
            title: "Done",
            options: []
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE",
            title: "Remind Me Later",
            options: []
        )
        let category = UNNotificationCategory(
            identifier: "HYDRATION_REMINDER",
            actions: [doneAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private struct ScheduledReminder {
        let window: HydrationWindow
        let index: Int
        let totalCount: Int
        let fireDate: Date
        let dayKey: String
        let planDay: Date
    }

    private struct ResolvedPlans {
        let todayPlan: HydrationPlan
        let todayDate: Date
        let tomorrowPlan: HydrationPlan?
        let tomorrowDate: Date?
    }

    private func resolvedPlans(
        from cached: CachedNotificationPlans,
        referenceDate: Date,
        calendar: Calendar
    ) -> ResolvedPlans {
        let todayStart = calendar.startOfDay(for: referenceDate)
        let cachedStart = calendar.startOfDay(for: cached.referenceDate)

        if cachedStart == todayStart {
            let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: todayStart)
            return ResolvedPlans(
                todayPlan: cached.today,
                todayDate: cached.referenceDate,
                tomorrowPlan: cached.tomorrow,
                tomorrowDate: tomorrowDate
            )
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: todayStart),
           cachedStart == yesterday {
            return ResolvedPlans(
                todayPlan: cached.tomorrow,
                todayDate: todayStart,
                tomorrowPlan: nil,
                tomorrowDate: nil
            )
        }

        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: cachedStart)
        return ResolvedPlans(
            todayPlan: cached.today,
            todayDate: cached.referenceDate,
            tomorrowPlan: cached.tomorrow,
            tomorrowDate: tomorrowDate
        )
    }

    private func rescheduleFromCache() {
        guard let profile = ProfileService.shared.load() else { return }
        scheduleNext(profile: profile)
    }

    private func nextReminder(
        plan: HydrationPlan,
        profile: UserProfile,
        on planDay: Date,
        now: Date,
        calendar: Calendar
    ) -> ScheduledReminder? {
        let dayKey = dayIdentifier(for: planDay, calendar: calendar)
        let completed = NotificationProgressService.shared.completedWindows(for: dayKey)

        for (index, window) in plan.windows.enumerated() {
            if completed.contains(window.name) { continue }

            guard
                let fireDate = NotificationScheduleBuilder.fireTime(
                    for: window,
                    index: index,
                    totalCount: plan.windows.count,
                    profile: profile,
                    on: planDay,
                    calendar: calendar
                ),
                let windowEnd = ScheduleTime.resolvedTime(from: window.endTime, on: planDay, calendar: calendar)
            else { continue }

            if now >= windowEnd { continue }

            let scheduleDate: Date
            if fireDate > now {
                scheduleDate = fireDate
            } else {
                scheduleDate = now.addingTimeInterval(5)
            }

            return ScheduledReminder(
                window: window,
                index: index,
                totalCount: plan.windows.count,
                fireDate: scheduleDate,
                dayKey: dayKey,
                planDay: planDay
            )
        }

        return nil
    }

    private func enqueue(_ reminder: ScheduledReminder, calendar: Calendar) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: reminder.window)
        content.body = notificationBody(for: reminder.window)
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"
        content.userInfo = [
            UserInfoKey.windowName: reminder.window.name,
            UserInfoKey.dayKey: reminder.dayKey,
            UserInfoKey.windowIndex: reminder.index
        ]

        let identifier = "watr-\(reminder.window.name)-\(reminder.dayKey)"
        let now = Date()
        let trigger: UNNotificationTrigger

        if reminder.fireDate.timeIntervalSince(now) < 60 {
            trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: max(reminder.fireDate.timeIntervalSince(now), 1),
                repeats: false
            )
        } else {
            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminder.fireDate
            )
            trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }

        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Notification error: \(error)")
            }
        }
    }

    private func clearDeliveredHydrationNotifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            let ids = notifications
                .map(\.request.identifier)
                .filter { $0.hasPrefix("watr-") }
            guard !ids.isEmpty else { return }
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ids)
        }
    }

    private func dayIdentifier(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 0
        let month = components.month ?? 0
        let day = components.day ?? 0
        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    private func dayDate(from dayKey: String, calendar: Calendar) -> Date? {
        let parts = dayKey.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        return calendar.date(from: components)
    }

    private func notificationTitle(for window: HydrationWindow) -> String {
        switch window.name {
        case "Upon Waking":     return "wakey wakey"
        case "After Breakfast": return "breakfast check"
        case "With Lunch":      return "lunch szn = hydration szn"
        case "Afternoon":       return "don't ghost your water bottle"
        case "Late Afternoon":  return "almost there, keep it up"
        case "Pre-Workout":     return "pre-workout hydration unlocked"
        case "Post-Workout":    return "you sweated. now drink up"
        case "With Dinner":     return "dinner time, water time"
        case "Wind Down":       return "last call for hydration"
        default:                return "yo, water break"
        }
    }

    private func notificationBody(for window: HydrationWindow) -> String {
        let oz = Int(window.minOz)
        let phrases = [
            "drink \(oz)oz rn no excuses",
            "your body is literally asking for \(oz)oz",
            "sip \(oz)oz and keep the streak alive",
            "\(oz)oz standing between you and peak hydration",
            "not drinking \(oz)oz is not the vibe",
            "hydration check: \(oz)oz, go",
            "\(oz)oz. tap done when you're good.",
        ]
        // Pick based on window name hash so it's consistent per window
        let index = abs(window.name.hashValue) % phrases.count
        return phrases[index]
    }
}
