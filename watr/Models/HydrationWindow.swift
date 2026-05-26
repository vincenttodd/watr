//
//  HydrationWindow.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation

struct HydrationWindow: Identifiable, Codable {
    let id: UUID
    var name: String
    var startTime: DateComponents
    var endTime: DateComponents
    var minOz: Double
    var maxOz: Double
    var isWorkoutWindow: Bool
    
    var snoozeCount: Int = 0
    var completedCount: Int = 0
    var ignoredCount: Int = 0
}
