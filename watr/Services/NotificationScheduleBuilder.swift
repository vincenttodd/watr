//
//  NotificationScheduleBuilder.swift
//  watr
//

import Foundation

enum NotificationScheduleBuilder {

    static let wakeWindowMinutes = 5
    static let periodWindowMinutes = 30
    static let bedBufferMinutes = 60

    /// Picks a fire time for one hydration period. Times are deterministic for a given
    /// calendar day + window name so reopening the app does not reshuffle today's schedule.
    static func fireTime(
        for window: HydrationWindow,
        index: Int,
        totalCount: Int,
        profile: UserProfile,
        on date: Date,
        calendar: Calendar = .current
    ) -> Date? {
        guard let schedule = ScheduleTime.wakeAndSleepDates(profile: profile, on: date, calendar: calendar) else {
            return nil
        }

        let wakeDate = schedule.wake
        let lastAllowed = calendar.date(byAdding: .minute, value: -bedBufferMinutes, to: schedule.sleep)!
        let seed = dailySeed(for: window.name, on: date, calendar: calendar)

        if index == 0 {
            let windowEnd = calendar.date(byAdding: .minute, value: wakeWindowMinutes, to: wakeDate)!
            return randomTime(between: wakeDate, and: min(windowEnd, lastAllowed), seed: seed)
        }

        if index == totalCount - 1 {
            let windowStart = calendar.date(byAdding: .minute, value: -periodWindowMinutes, to: lastAllowed)!
            let earliest = calendar.date(byAdding: .minute, value: wakeWindowMinutes, to: wakeDate)!
            let clampedStart = max(windowStart, earliest)
            guard clampedStart < lastAllowed else { return nil }
            return randomTime(between: clampedStart, and: lastAllowed, seed: seed)
        }

        guard let anchor = ScheduleTime.resolvedTime(from: window.startTime, on: date, calendar: calendar) else {
            return nil
        }

        let halfWindow = periodWindowMinutes / 2
        var rangeStart = calendar.date(byAdding: .minute, value: -halfWindow, to: anchor)!
        var rangeEnd = calendar.date(byAdding: .minute, value: halfWindow, to: anchor)!

        let earliest = calendar.date(byAdding: .minute, value: wakeWindowMinutes, to: wakeDate)!
        rangeStart = max(rangeStart, earliest)
        rangeEnd = min(rangeEnd, lastAllowed)

        guard rangeStart < rangeEnd else { return nil }
        return randomTime(between: rangeStart, and: rangeEnd, seed: seed)
    }

    private static func dailySeed(for windowName: String, on date: Date, calendar: Calendar) -> UInt64 {
        let day = calendar.startOfDay(for: date)
        let dayKey = ISO8601DateFormatter().string(from: day)
        var hasher = Hasher()
        hasher.combine(dayKey)
        hasher.combine(windowName)
        return UInt64(bitPattern: Int64(hasher.finalize()))
    }

    private static func randomTime(between start: Date, and end: Date, seed: UInt64) -> Date? {
        let span = end.timeIntervalSince(start)
        guard span > 0 else { return start }

        var generator = SeededRandomNumberGenerator(seed: seed)
        let offset = Double.random(in: 0...span, using: &generator)
        return start.addingTimeInterval(offset)
    }
}

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0xDEADBEEF : seed
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1
        return state
    }
}
