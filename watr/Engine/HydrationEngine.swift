//
//  HydrationEngine.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation

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
        case .light:    workoutModifier = isWorkoutDay ? 6  : 0
        case .moderate: workoutModifier = isWorkoutDay ? 10 : 0
        case .heavy:    workoutModifier = isWorkoutDay ? 14 : 0
        }

        // WAKE DURATION MODIFIER
        let wakeHours = calculateWakeHours(profile: profile, on: date, calendar: calendar)
        let wakeModifier: Double = wakeHours > 16 ? 4.0 : 0.0

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

        return HydrationPlan(totalOz: total, windows: windows, generatedAt: Date())
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
        let today = calculate(profile: profile, weather: weather,
                              isWorkoutDay: isTodayWorkout, on: referenceDate, calendar: calendar)

        let tomorrowDate = calendar.date(byAdding: .day, value: 1,
                                         to: calendar.startOfDay(for: referenceDate))!
        let tomorrowWeekday = calendar.component(.weekday, from: tomorrowDate)
        let isTomorrowWorkout = profile.workoutDays.contains(
            UserProfile.Weekday(rawValue: tomorrowWeekday) ?? .monday
        )
        let tomorrow = calculate(profile: profile, weather: weather,
                                 isWorkoutDay: isTomorrowWorkout, on: tomorrowDate, calendar: calendar)

        return (today, tomorrow)
    }

    // MARK: - Window builder

    private func buildWindows(
        totalOz: Double,
        profile: UserProfile,
        isWorkoutDay: Bool,
        on date: Date,
        calendar: Calendar
    ) -> [HydrationWindow] {

        let schedule = ScheduleTime.components(for: profile, on: date, calendar: calendar)
        let wakeMinutes  = toMinutes(schedule.wake.hour ?? 7,  schedule.wake.minute ?? 0)
        let sleepMinutes = toMinutes(schedule.sleep.hour ?? 23, schedule.sleep.minute ?? 0)
        // Handle sleep past midnight
        let adjustedSleep = sleepMinutes <= wakeMinutes ? sleepMinutes + 1440 : sleepMinutes
        let totalWake = adjustedSleep - wakeMinutes

        // Meal anchors
        let mealTimes = profile.mealTimes.isEmpty
            ? UserProfile.defaultMealTimes()
            : profile.mealTimes
        let breakfastMin = toMinutes(mealTimes[.breakfast]?.hour ?? 8,  mealTimes[.breakfast]?.minute ?? 0)
        let lunchMin     = toMinutes(mealTimes[.lunch]?.hour     ?? 12, mealTimes[.lunch]?.minute     ?? 0)
        let dinnerMin    = toMinutes(mealTimes[.dinner]?.hour    ?? 18, mealTimes[.dinner]?.minute    ?? 0)
        let windDownMin  = adjustedSleep - 60  // 1hr before sleep

        // Workout anchor (only on workout days)
        let todayWeekday = UserProfile.Weekday(
            rawValue: calendar.component(.weekday, from: date)
        ) ?? .monday
        let workoutMins: Int? = isWorkoutDay
            ? toMinutes(
                profile.workoutTimes[todayWeekday]?.hour   ?? 16,
                profile.workoutTimes[todayWeekday]?.minute ?? 0
              )
            : nil

        // Build anchor list — always 7 slots
        struct Anchor {
            let name: String
            let startMinutes: Int   // absolute minutes since midnight
            let weight: Double      // fraction of totalOz
            let isWorkout: Bool
        }

        var anchors: [Anchor]

        if let workoutStart = workoutMins {
            let preWorkout  = workoutStart - 45
            let postWorkout = workoutStart + 60

            // Weights: upon waking 18, breakfast 14, lunch 18,
            //          pre 13, post 13, dinner 14, wind down 10 = 100
            anchors = [
                Anchor(name: "Upon Waking",     startMinutes: wakeMinutes,  weight: 0.18, isWorkout: false),
                Anchor(name: "After Breakfast", startMinutes: breakfastMin, weight: 0.14, isWorkout: false),
                Anchor(name: "With Lunch",      startMinutes: lunchMin,     weight: 0.18, isWorkout: false),
                Anchor(name: "Pre-Workout",     startMinutes: preWorkout,   weight: 0.13, isWorkout: true),
                Anchor(name: "Post-Workout",    startMinutes: postWorkout,  weight: 0.13, isWorkout: true),
                Anchor(name: "With Dinner",     startMinutes: dinnerMin,    weight: 0.14, isWorkout: false),
                Anchor(name: "Wind Down",       startMinutes: windDownMin,  weight: 0.10, isWorkout: false),
            ]
        } else {
            // Afternoon = midpoint between lunch and dinner
            let afternoonMin = (lunchMin + dinnerMin) / 2

            // Weights: 18+14+18+14+13+13+10 = 100
            anchors = [
                Anchor(name: "Upon Waking",     startMinutes: wakeMinutes,  weight: 0.18, isWorkout: false),
                Anchor(name: "After Breakfast", startMinutes: breakfastMin, weight: 0.14, isWorkout: false),
                Anchor(name: "With Lunch",      startMinutes: lunchMin,     weight: 0.18, isWorkout: false),
                Anchor(name: "Afternoon",       startMinutes: afternoonMin, weight: 0.14, isWorkout: false),
                Anchor(name: "Late Afternoon",  startMinutes: (afternoonMin + dinnerMin) / 2, weight: 0.13, isWorkout: false),
                Anchor(name: "With Dinner",     startMinutes: dinnerMin,    weight: 0.13, isWorkout: false),
                Anchor(name: "Wind Down",       startMinutes: windDownMin,  weight: 0.10, isWorkout: false),
            ]
        }

        // Sort by time so out-of-order workout anchors land correctly
        anchors.sort { $0.startMinutes < $1.startMinutes }

        // Each window runs from its anchor start to the next anchor start
        // (last window runs to sleep time)
        return anchors.enumerated().map { i, anchor in
            let endMinutes = i + 1 < anchors.count
                ? anchors[i + 1].startMinutes
                : adjustedSleep

            let oz     = totalOz * anchor.weight
            let minOz  = (oz * 0.85).rounded()
            let maxOz  = (oz * 1.15).rounded()

            return HydrationWindow(
                id: UUID(),
                name: anchor.name,
                startTime: dcFromMinutes(anchor.startMinutes),
                endTime:   dcFromMinutes(endMinutes),
                minOz: minOz,
                maxOz: maxOz,
                isWorkoutWindow: anchor.isWorkout
            )
        }
    }

    // MARK: - Helpers

    private func toMinutes(_ hour: Int, _ minute: Int) -> Int {
        hour * 60 + minute
    }

    private func dcFromMinutes(_ total: Int) -> DateComponents {
        let normalized = ((total % 1440) + 1440) % 1440
        var dc = DateComponents()
        dc.hour   = normalized / 60
        dc.minute = normalized % 60
        return dc
    }

    private func calculateWakeHours(profile: UserProfile, on date: Date, calendar: Calendar) -> Double {
        let schedule = ScheduleTime.components(for: profile, on: date, calendar: calendar)
        let minutes = ScheduleTime.minutesBetweenWakeAndSleep(wake: schedule.wake, sleep: schedule.sleep)
        return Double(minutes) / 60.0
    }
}
