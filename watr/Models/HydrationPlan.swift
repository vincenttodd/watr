//
//  HydrationPlan.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation

struct HydrationPlan: Codable {
    var totalOz: Double
    var windows: [HydrationWindow]
    var generatedAt: Date
    
    var isWorkoutDay: Bool {
        windows.contains { $0.isWorkoutWindow }
    }
    
    var nextWindow: HydrationWindow? {
        let now = Date()
        let calendar = Calendar.current
        return windows.first { window in
            guard let windowTime = time(on: now, from: window.startTime, calendar: calendar) else {
                return false
            }
            return windowTime > now
        }
    }

    var currentWindow: HydrationWindow? {
        let now = Date()
        let calendar = Calendar.current
        return windows.first { window in
            guard
                let start = time(on: now, from: window.startTime, calendar: calendar),
                let end = time(on: now, from: window.endTime, calendar: calendar)
            else { return false }
            return now >= start && now < end
        }
    }

    private func time(on referenceDate: Date, from components: DateComponents, calendar: Calendar) -> Date? {
        guard let hour = components.hour, let minute = components.minute else { return nil }
        return calendar.date(
            bySettingHour: hour,
            minute: minute,
            second: 0,
            of: referenceDate
        )
    }
}
