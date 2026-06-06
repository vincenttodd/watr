//
//   OnboardingState.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import Foundation
import Combine
import SwiftUI

class OnboardingState: ObservableObject {
    @Published var sex: UserProfile.Sex = .male
    @Published var birthDate: Date = Calendar.current.date(
        byAdding: .year, value: -30, to: Date()) ?? Date()
    @Published var heightInches: Double = 68
    @Published var weightLbs: Double = 160
    @Published var weekdayWakeHour: Int = 7
    @Published var weekdayWakeMinute: Int = 0
    @Published var weekdaySleepHour: Int = 23
    @Published var weekdaySleepMinute: Int = 0
    @Published var weekendWakeHour: Int = 8
    @Published var weekendWakeMinute: Int = 0
    @Published var weekendSleepHour: Int = 0
    @Published var weekendSleepMinute: Int = 0
    @Published var workoutDays: [UserProfile.Weekday] = []
    @Published var workoutIntensity: UserProfile.WorkoutIntensity = .none
    @Published var zipCode: String = ""
    
    func toUserProfile() -> UserProfile {
        var weekdayWake = DateComponents()
        weekdayWake.hour = weekdayWakeHour
        weekdayWake.minute = weekdayWakeMinute
        
        var weekdaySleep = DateComponents()
        weekdaySleep.hour = weekdaySleepHour
        weekdaySleep.minute = weekdaySleepMinute
        
        var weekendWake = DateComponents()
        weekendWake.hour = weekendWakeHour
        weekendWake.minute = weekendWakeMinute
        
        var weekendSleep = DateComponents()
        weekendSleep.hour = weekendSleepHour
        weekendSleep.minute = weekendSleepMinute
        
        return UserProfile(
            sex: sex,
            birthDate: birthDate,
            heightInches: heightInches,
            weightLbs: weightLbs,
            weekdayWake: weekdayWake,
            weekdaySleep: weekdaySleep,
            weekendWake: weekendWake,
            weekendSleep: weekendSleep,
            workoutDays: workoutDays,
            workoutIntensity: workoutIntensity,
            zipCode: zipCode
        )
    }
}
