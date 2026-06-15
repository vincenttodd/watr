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
    var workoutTimes: [Weekday: DateComponents]  // NEW
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

    enum Weekday: Int, Codable, CaseIterable, Hashable {  // add Hashable
        case sunday=1, monday, tuesday, wednesday, thursday, friday, saturday

        var displayName: String {
            switch self {
            case .sunday: return "Sunday"
            case .monday: return "Monday"
            case .tuesday: return "Tuesday"
            case .wednesday: return "Wednesday"
            case .thursday: return "Thursday"
            case .friday: return "Friday"
            case .saturday: return "Saturday"
            }
        }

        var shortName: String {
            switch self {
            case .sunday: return "Sun"
            case .monday: return "Mon"
            case .tuesday: return "Tue"
            case .wednesday: return "Wed"
            case .thursday: return "Thu"
            case .friday: return "Fri"
            case .saturday: return "Sat"
            }
        }
    }
}
