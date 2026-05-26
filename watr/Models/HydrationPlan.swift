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
            guard let hour = window.startTime.hour,
                  let minute = window.startTime.minute else { return false }
            let windowTime = calendar.date(
                bySettingHour: hour,
                minute: minute,
                second: 0,
                of: now
            )
            return windowTime ?? now > now
        }
    }
}
