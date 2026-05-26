//
//  HomeView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI
import Combine

struct HomeView: View {
    
    @EnvironmentObject var subscriptionService: SubscriptionService
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    @State private var plan: HydrationPlan? = nil
    @State private var weather: WeatherData? = nil
    
    let engine = HydrationEngine()
    let weatherService = WeatherService()
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning."
        case 12..<17: return "Good afternoon."
        default: return "Good evening."
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            if let plan = plan {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header
                        HStack {
                            Text("watr")
                                .font(.system(size: 28, weight: .light))
                                .tracking(4)
                            Spacer()
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 52)
                        .padding(.bottom, 28)
                        
                        // Hero
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1)
                            
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(Int(plan.totalOz))")
                                    .font(.system(size: 64, weight: .light))
                                Text("oz")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                            }
                            
                            if let condition = weather?.condition {
                                Text("\(condition) · \(Int(weather?.temperatureF ?? 72))°F")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .padding(.bottom, 24)
                        
                        // Next window card
                        if let nextWindow = plan.nextWindow {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Up next")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.7))
                                    .textCase(.uppercase)
                                    .tracking(1)
                                
                                Text(nextWindow.name)
                                    .font(.system(size: 22, weight: .medium))
                                    .foregroundStyle(.white)
                                
                                Text(windowTimeString(nextWindow))
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(.white.opacity(0.75))
                                
                                HStack(alignment: .bottom, spacing: 4) {
                                    Text("\(Int(nextWindow.minOz))–\(Int(nextWindow.maxOz))")
                                        .font(.system(size: 48, weight: .light))
                                        .foregroundStyle(.white)
                                    Text("oz")
                                        .font(.system(size: 18, weight: .light))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .padding(.bottom, 8)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(22)
                            .background(Color(red: 0.18, green: 0.35, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal, 28)
                            .padding(.bottom, 28)
                        }
                        
                        // Windows list
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Today's windows")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1)
                                .padding(.horizontal, 28)
                                .padding(.bottom, 14)
                            
                            ForEach(plan.windows) { window in
                                HStack {
                                    Circle()
                                        .frame(width: 8, height: 8)
                                        .foregroundStyle(
                                            isNextWindow(window, plan: plan) ?
                                            Color(red: 0.18, green: 0.35, blue: 0.24) :
                                            Color.gray.opacity(0.3)
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(window.name)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(
                                                isNextWindow(window, plan: plan) ?
                                                Color(red: 0.18, green: 0.35, blue: 0.24) :
                                                .primary
                                            )
                                        Text(windowTimeString(window))
                                            .font(.system(size: 12))
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(alignment: .bottom, spacing: 2) {
                                        Text("\(Int(window.minOz))–\(Int(window.maxOz))")
                                            .font(.system(size: 20, weight: .light))
                                        Text("oz")
                                            .font(.system(size: 11))
                                            .foregroundStyle(.secondary)
                                            .padding(.bottom, 3)
                                    }
                                }
                                .padding(.vertical, 14)
                                .padding(.horizontal, 28)
                                Divider()
                                    .padding(.leading, 28)
                            }
                        }
                        
                        NavigationLink {
                            CustomizeView()
                        } label: {
                            Text("Customize schedule")
                                .font(.system(size: 15))
                                .foregroundStyle(Color(red: 0.18, green: 0.35, blue: 0.24))
                                .padding(.top, 24)
                        }
                        
                        Spacer().frame(height: 48)
                    }
                }
            } else {
                ProgressView()
                    .tint(Color(red: 0.18, green: 0.35, blue: 0.24))
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadPlan()
        }
    }
    
    func loadPlan() async {
        guard let profile = ProfileService.shared.load() else { return }
        
        let fetchedWeather = try? await weatherService.fetchCurrentConditions(
            for: profile.zipCode
        )
        let weatherData = fetchedWeather ?? WeatherData(
            temperatureF: 72,
            humidityPercent: 50,
            condition: "Clear"
        )
        
        let today = Calendar.current.component(.weekday, from: Date())
        let isWorkoutDay = profile.workoutDays.contains(
            UserProfile.Weekday(rawValue: today) ?? .monday
        )
        
        let calculatedPlan = engine.calculate(
            profile: profile,
            weather: weatherData,
            isWorkoutDay: isWorkoutDay
        )
        
        await MainActor.run {
            self.weather = weatherData
            self.plan = calculatedPlan
        }
    }
    
    func windowTimeString(_ window: HydrationWindow) -> String {
        let startHour = window.startTime.hour ?? 0
        let startMinute = window.startTime.minute ?? 0
        let endHour = window.endTime.hour ?? 0
        let endMinute = window.endTime.minute ?? 0
        
        func formatTime(hour: Int, minute: Int) -> String {
            let period = hour >= 12 ? "PM" : "AM"
            let displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
            let minuteStr = minute == 0 ? "" : ":\(String(format: "%02d", minute))"
            return "\(displayHour)\(minuteStr) \(period)"
        }
        
        return "\(formatTime(hour: startHour, minute: startMinute)) – \(formatTime(hour: endHour, minute: endMinute))"
    }
    
    func isNextWindow(_ window: HydrationWindow, plan: HydrationPlan) -> Bool {
        return plan.nextWindow?.id == window.id
    }
}
