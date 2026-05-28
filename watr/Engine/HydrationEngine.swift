//
//  HydrationEngine.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation

struct WeatherData {
    let temperatureF: Double
    let humidityPercent: Double
    let condition: String
}

class HydrationEngine {
    
    func calculate(profile: UserProfile, weather: WeatherData, isWorkoutDay: Bool) -> HydrationPlan {
        
        // BASELINE
        let rawBaseline = profile.weightLbs / 2.0
        let baseline = min(rawBaseline, 75.0)
        
        // SEX MODIFIER
        let sexModifier: Double = profile.sex == .male ? 4.0 : 0.0
        
        // WEATHER MODIFIER
        let heatModifier: Double
        switch weather.temperatureF {
        case ..<65:   heatModifier = -4
        case 65..<75: heatModifier = 0
        case 75..<85: heatModifier = 4
        case 85..<95: heatModifier = 8
        default:      heatModifier = 12
        }
        
        let humidityModifier: Double = weather.humidityPercent > 70 ? 3.0 : 0.0
        
        // WORKOUT MODIFIER
        let workoutModifier: Double
        switch profile.workoutIntensity {
        case .none:     workoutModifier = 0
        case .light:    workoutModifier = isWorkoutDay ? 6 : 0
        case .moderate: workoutModifier = isWorkoutDay ? 10 : 0
        case .heavy:    workoutModifier = isWorkoutDay ? 14 : 0
        }
        
        // WAKE DURATION MODIFIER
        let wakeHours = calculateWakeHours(profile: profile)
        let wakeModifier: Double = wakeHours > 16 ? 4.0 : 0.0
        
        // TOTAL with hard cap
        let total = min(
            baseline + sexModifier + heatModifier + humidityModifier + workoutModifier + wakeModifier,
            100.0
        )
        
        let windows = buildWindows(
            totalOz: total,
            profile: profile,
            isWorkoutDay: isWorkoutDay
        )
        
        return HydrationPlan(
            totalOz: total,
            windows: windows,
            generatedAt: Date()
        )
    }
    
    private func buildWindows(totalOz: Double, profile: UserProfile, isWorkoutDay: Bool) -> [HydrationWindow] {
        
        var windowDefinitions: [(name: String, weight: Double, isWorkout: Bool)] = [
            ("Upon Waking",     0.20, false),
            ("After Breakfast", 0.15, false),
            ("Mid Morning",     0.10, false),
            ("With Lunch",      0.20, false),
            ("Afternoon",       0.15, false),
            ("Wind Down",       0.10, false),
        ]
        
        if isWorkoutDay {
            windowDefinitions.remove(at: 4)
            windowDefinitions.insert(("Pre-Workout",  0.08, true), at: 4)
            windowDefinitions.insert(("Post-Workout", 0.12, true), at: 5)
        }
        
        let wakeHour = profile.weekdayWake.hour ?? 7
        let wakeMinute = profile.weekdayWake.minute ?? 0
        let sleepHour = profile.weekdaySleep.hour ?? 23
        let sleepMinute = profile.weekdaySleep.minute ?? 0

        let wakeStartMinutes = minutesSinceMidnight(hour: wakeHour, minute: wakeMinute)
        let sleepStartMinutes = minutesSinceMidnight(hour: sleepHour, minute: sleepMinute)
        let totalWakeMinutes = minutesBetween(start: wakeStartMinutes, end: sleepStartMinutes)
        
        var cumulativeWeight = 0.0
        
        return windowDefinitions.map { definition in
            let oz = totalOz * definition.weight
            let minOz = (oz * 0.85).rounded()
            let maxOz = (oz * 1.15).rounded()
            
            let startMinuteOffset = Int(cumulativeWeight * Double(totalWakeMinutes))
            cumulativeWeight += definition.weight
            
            let startTotalMinutes = wakeStartMinutes + startMinuteOffset
            let endTotalMinutes = startTotalMinutes + Int(definition.weight * Double(totalWakeMinutes))
            let startComponents = dateComponentsFromTotalMinutes(startTotalMinutes)
            let endComponents = dateComponentsFromTotalMinutes(endTotalMinutes)
            
            return HydrationWindow(
                id: UUID(),
                name: definition.name,
                startTime: startComponents,
                endTime: endComponents,
                minOz: minOz,
                maxOz: maxOz,
                isWorkoutWindow: definition.isWorkout
            )
        }
    }
    
    private func calculateWakeHours(profile: UserProfile) -> Double {
        let wakeHour = profile.weekdayWake.hour ?? 7
        let wakeMinute = profile.weekdayWake.minute ?? 0
        let sleepHour = profile.weekdaySleep.hour ?? 23
        let sleepMinute = profile.weekdaySleep.minute ?? 0

        let wakeStartMinutes = minutesSinceMidnight(hour: wakeHour, minute: wakeMinute)
        let sleepStartMinutes = minutesSinceMidnight(hour: sleepHour, minute: sleepMinute)
        return Double(minutesBetween(start: wakeStartMinutes, end: sleepStartMinutes)) / 60.0
    }

    private func minutesSinceMidnight(hour: Int, minute: Int) -> Int {
        (hour * 60) + minute
    }

    private func minutesBetween(start: Int, end: Int) -> Int {
        let minutesInDay = 24 * 60
        let normalized = (end - start + minutesInDay) % minutesInDay
        return normalized == 0 ? minutesInDay : normalized
    }

    private func dateComponentsFromTotalMinutes(_ totalMinutes: Int) -> DateComponents {
        let minutesInDay = 24 * 60
        let normalized = ((totalMinutes % minutesInDay) + minutesInDay) % minutesInDay

        var components = DateComponents()
        components.hour = normalized / 60
        components.minute = normalized % 60
        return components
    }
}
