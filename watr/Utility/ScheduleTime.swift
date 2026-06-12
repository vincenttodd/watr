//
//  ScheduleTime.swift
//  watr
//

import Foundation

enum ScheduleTime {

    /// Mon–Fri uses weekday wake/sleep. Sat–Sun uses weekend wake/sleep.
    static func components(for profile: UserProfile, on date: Date, calendar: Calendar = .current) -> (wake: DateComponents, sleep: DateComponents) {
        isWeekend(date, calendar: calendar)
            ? (profile.weekendWake, profile.weekendSleep)
            : (profile.weekdayWake, profile.weekdaySleep)
    }

    static func isWeekend(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDateInWeekend(date)
    }

    static func resolvedTime(
        from components: DateComponents,
        on date: Date,
        calendar: Calendar = .current
    ) -> Date? {
        guard let hour = components.hour, let minute = components.minute else { return nil }

        var resolved = calendar.dateComponents([.year, .month, .day], from: date)
        resolved.hour = hour
        resolved.minute = minute
        resolved.second = 0
        return calendar.date(from: resolved)
    }

    /// Returns wake and sleep on the given day. Sleep rolls to the next calendar day
    /// when it falls at or before wake (e.g. midnight bedtime after an 8 AM wake).
    static func wakeAndSleepDates(
        profile: UserProfile,
        on date: Date,
        calendar: Calendar = .current
    ) -> (wake: Date, sleep: Date)? {
        let schedule = components(for: profile, on: date, calendar: calendar)

        guard let wake = resolvedTime(from: schedule.wake, on: date, calendar: calendar) else { return nil }
        guard var sleep = resolvedTime(from: schedule.sleep, on: date, calendar: calendar) else { return nil }

        if sleep <= wake {
            guard let nextDaySleep = calendar.date(byAdding: .day, value: 1, to: sleep) else { return nil }
            sleep = nextDaySleep
        }

        return (wake, sleep)
    }

    static func minutesSinceMidnight(hour: Int, minute: Int) -> Int {
        (hour * 60) + minute
    }

    static func minutesBetweenWakeAndSleep(wake: DateComponents, sleep: DateComponents) -> Int {
        let wakeMinutes = minutesSinceMidnight(hour: wake.hour ?? 7, minute: wake.minute ?? 0)
        let sleepMinutes = minutesSinceMidnight(hour: sleep.hour ?? 23, minute: sleep.minute ?? 0)
        let minutesInDay = 24 * 60
        let normalized = (sleepMinutes - wakeMinutes + minutesInDay) % minutesInDay
        return normalized == 0 ? minutesInDay : normalized
    }
}
