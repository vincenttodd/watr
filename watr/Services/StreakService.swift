//
//  StreakService.swift
//  watr
//

import Foundation
import Combine

struct StreakMessage {
    let title: String
    let body: String
}

@MainActor
final class StreakService: ObservableObject {
    static let shared = StreakService()

    private let streakCountKey = "watrStreakCount"
    private let lastActiveDayKey = "watrStreakLastActiveDay"

    @Published private(set) var currentStreak = 0

    private init() {
        currentStreak = UserDefaults.standard.integer(forKey: streakCountKey)
    }

    func recordDailyVisit() {
        let today = Calendar.current.startOfDay(for: Date())
        let defaults = UserDefaults.standard

        if let lastDay = defaults.object(forKey: lastActiveDayKey) as? Date {
            let lastDayStart = Calendar.current.startOfDay(for: lastDay)
            let dayGap = Calendar.current.dateComponents([.day], from: lastDayStart, to: today).day ?? 0

            switch dayGap {
            case 0:
                break
            case 1:
                currentStreak += 1
            default:
                currentStreak = 1
            }
        } else {
            currentStreak = max(currentStreak, 1)
        }

        defaults.set(today, forKey: lastActiveDayKey)
        defaults.set(currentStreak, forKey: streakCountKey)
    }

    var message: StreakMessage {
        switch currentStreak {
        case 0:
            return StreakMessage(
                title: "Start your streak",
                body: "Open WATR each day and stay on track with your hydration plan."
            )
        case 1...6:
            return StreakMessage(
                title: "Great start",
                body: "You're building a daily hydration habit. Keep showing up."
            )
        case 7...29:
            return StreakMessage(
                title: "Building momentum",
                body: "Your consistency is paying off. Stay with your plan today."
            )
        case 30...99:
            return StreakMessage(
                title: "Strong consistency",
                body: "You're among WATR's most consistent members. Keep it going."
            )
        default:
            return StreakMessage(
                title: "Legendary consistency",
                body: "Your streak is in the top 1% of all WATR members. This kind of consistency shapes your long-term health."
            )
        }
    }
}
