//
//   UserProfile.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation

struct UserProfile: Codable {
    var sex: Sex
    var birthDate: Date
    var heightInches: Double
    var weightLbs: Double
    var weekdayWake: DateComponents
    var weekdaySleep: DateComponents
    var weekendWake: DateComponents
    var weekendSleep: DateComponents
    var workoutDays: [Weekday]
    var workoutIntensity: WorkoutIntensity
    var zipCode: String

    enum Sex: String, Codable, CaseIterable {
        case male, female, other
    }

    enum WorkoutIntensity: String, Codable, CaseIterable {
        case none
        case light
        case moderate
        case heavy
    }

    enum Weekday: Int, Codable, CaseIterable {
        case sunday=1, monday, tuesday, wednesday, thursday, friday, saturday
    }
}
