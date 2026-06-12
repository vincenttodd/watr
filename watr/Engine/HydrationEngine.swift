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

    func calculate(
        profile: UserProfile,
        weather: WeatherData,
        isWorkoutDay: Bool,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> HydrationPlan {

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
        let wakeHours = calculateWakeHours(profile: profile, on: date, calendar: calendar)
        let wakeModifier: Double = wakeHours > 16 ? 4.0 : 0.0

        // TOTAL with hard cap
        let total = min(
            baseline + sexModifier + heatModifier + humidityModifier + workoutModifier + wakeModifier,
            100.0
        )

        let windows = buildWindows(
            totalOz: total,
            profile: profile,
            isWorkoutDay: isWorkoutDay,
            on: date,
            calendar: calendar
        )

        return HydrationPlan(
            totalOz: total,
            windows: windows,
            generatedAt: Date()
        )
    }

    func plansForUpcomingDays(
        profile: UserProfile,
        weather: WeatherData,
        referenceDate: Date = Date(),
        calendar: Calendar = .current
    ) -> (today: HydrationPlan, tomorrow: HydrationPlan) {
        let todayWeekday = calendar.component(.weekday, from: referenceDate)
        let isTodayWorkout = profile.workoutDays.contains(
            UserProfile.Weekday(rawValue: todayWeekday) ?? .monday
        )
        let today = calculate(
            profile: profile,
            weather: weather,
            isWorkoutDay: isTodayWorkout,
            on: referenceDate,
            calendar: calendar
        )

        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: referenceDate))!
        let tomorrowWeekday = calendar.component(.weekday, from: tomorrowDate)
        let isTomorrowWorkout = profile.workoutDays.contains(
            UserProfile.Weekday(rawValue: tomorrowWeekday) ?? .monday
        )
        let tomorrow = calculate(
            profile: profile,
            weather: weather,
            isWorkoutDay: isTomorrowWorkout,
            on: tomorrowDate,
            calendar: calendar
        )

        return (today, tomorrow)
    }

    private func buildWindows(
        totalOz: Double,
        profile: UserProfile,
        isWorkoutDay: Bool,
        on date: Date,
        calendar: Calendar
    ) -> [HydrationWindow] {

        // Weights sum to exactly 1.0. 7 windows mirrors the inspiration schedule:
        // waking (18%) → breakfast (14%) → lunch (18%) → afternoon (14%)
        // → late afternoon (13%) → dinner (13%) → wind down (10%)
        var windowDefinitions: [(name: String, weight: Double, isWorkout: Bool)] = [
            ("Upon Waking",     0.18, false),
            ("After Breakfast", 0.14, false),
            ("With Lunch",      0.18, false),
            ("Afternoon",       0.14, false),
            ("Late Afternoon",  0.13, false),
            ("With Dinner",     0.13, false),
            ("Wind Down",       0.10, false),
        ]

        if isWorkoutDay {
            // Replace Late Afternoon + With Dinner with workout windows; keep total = 1.0
            windowDefinitions.remove(at: 5) // With Dinner
            windowDefinitions.remove(at: 4) // Late Afternoon
            windowDefinitions.insert(("Pre-Workout",  0.08, true),  at: 4)
            windowDefinitions.insert(("Post-Workout", 0.13, true),  at: 5)
            windowDefinitions.insert(("With Dinner",  0.05, false), at: 6)
        }

        let schedule = ScheduleTime.components(for: profile, on: date, calendar: calendar)
        let wakeStartMinutes = ScheduleTime.minutesSinceMidnight(
            hour: schedule.wake.hour ?? 7,
            minute: schedule.wake.minute ?? 0
        )
        let totalWakeMinutes = ScheduleTime.minutesBetweenWakeAndSleep(
            wake: schedule.wake,
            sleep: schedule.sleep
        )

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

    private func calculateWakeHours(
        profile: UserProfile,
        on date: Date,
        calendar: Calendar
    ) -> Double {
        let schedule = ScheduleTime.components(for: profile, on: date, calendar: calendar)
        let totalMinutes = ScheduleTime.minutesBetweenWakeAndSleep(
            wake: schedule.wake,
            sleep: schedule.sleep
        )
        return Double(totalMinutes) / 60.0
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
