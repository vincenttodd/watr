//
//  NotificationPlanCache.swift
//  watr
//

import Foundation

struct CachedNotificationPlans: Codable {
    var today: HydrationPlan
    var tomorrow: HydrationPlan
    var referenceDate: Date
}

final class NotificationPlanCache {

    static let shared = NotificationPlanCache()

    private let key = "cachedNotificationPlans"

    func save(today: HydrationPlan, tomorrow: HydrationPlan, referenceDate: Date) {
        let cached = CachedNotificationPlans(
            today: today,
            tomorrow: tomorrow,
            referenceDate: referenceDate
        )
        if let data = try? JSONEncoder().encode(cached) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func load(referenceDate: Date = Date(), calendar: Calendar = .current) -> CachedNotificationPlans? {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let cached = try? JSONDecoder().decode(CachedNotificationPlans.self, from: data)
        else { return nil }

        let cachedDay = calendar.startOfDay(for: cached.referenceDate)
        let currentDay = calendar.startOfDay(for: referenceDate)
        guard cachedDay == currentDay || cachedDay == calendar.date(byAdding: .day, value: -1, to: currentDay) else {
            return nil
        }

        return cached
    }

    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
