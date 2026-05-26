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
        let sleepHour = profile.weekdaySleep.hour ?? 23
        let wakeMinute = profile.weekdayWake.minute ?? 0
        let totalWakeMinutes = (sleepHour - wakeHour) * 60
        
        var cumulativeWeight = 0.0
        
        return windowDefinitions.map { definition in
            let oz = totalOz * definition.weight
            let minOz = (oz * 0.85).rounded()
            let maxOz = (oz * 1.15).rounded()
            
            let startMinuteOffset = Int(cumulativeWeight * Double(totalWakeMinutes))
            cumulativeWeight += definition.weight
            
            let startTotalMinutes = wakeHour * 60 + wakeMinute + startMinuteOffset
            let endTotalMinutes = startTotalMinutes + Int(definition.weight * Double(totalWakeMinutes))
            
            var startComponents = DateComponents()
            startComponents.hour = startTotalMinutes / 60
            startComponents.minute = startTotalMinutes % 60
            
            var endComponents = DateComponents()
            endComponents.hour = endTotalMinutes / 60
            endComponents.minute = endTotalMinutes % 60
            
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
        let sleepHour = profile.weekdaySleep.hour ?? 23
        return Double((sleepHour - wakeHour + 24) % 24)
    }
}
