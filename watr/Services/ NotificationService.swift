//
//   NotificationService.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation
import UserNotifications

class NotificationService {
    
    static let shared = NotificationService()
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        return granted ?? false
    }
    
    func scheduleDay(plan: HydrationPlan) {
        // Cancel all existing watr notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        for window in plan.windows {
            schedule(window: window)
        }
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func schedule(window: HydrationWindow) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle(for: window)
        content.body = notificationBody(for: window)
        content.sound = .default
        content.categoryIdentifier = "HYDRATION_REMINDER"
        
        guard let hour = window.startTime.hour,
              let minute = window.startTime.minute else { return }
        
        var triggerComponents = DateComponents()
        triggerComponents.hour = hour
        triggerComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: triggerComponents,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "watr-\(window.id)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
    
    private func notificationTitle(for window: HydrationWindow) -> String {
        switch window.name {
        case "Upon Waking":
            return "Good morning — start your day hydrated."
        case "After Breakfast":
            return "Small hydration break?"
        case "Mid Morning":
            return "You're on pace today."
        case "With Lunch":
            return "Good time to sip."
        case "Pre-Workout":
            return "Hydrate before you sweat."
        case "Post-Workout":
            return "Replenish after your workout."
        case "Wind Down":
            return "Last hydration window of the day."
        default:
            return "Small hydration break?"
        }
    }
    
    private func notificationBody(for window: HydrationWindow) -> String {
        let oz = Int(window.minOz)
        return "Around \(oz)oz for your \(window.name.lowercased()) window."
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
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
}
