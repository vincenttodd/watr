//
//  HomeView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI
import Combine

struct HomeView: View {
    
    @StateObject private var streakService = StreakService.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var plan: HydrationPlan? = nil
    @State private var weather: WeatherData? = nil
    @State private var weatherError: String? = nil
    @State private var lastWeatherFetch: Date? = nil

    private let weatherFetchInterval: TimeInterval = 10 * 60 // 10 minutes

    let engine = HydrationEngine()
    let weatherService = WeatherService()
    
    @ViewBuilder
    var gearButton: some View {
        let icon = Image(systemName: "gearshape")
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(.primary)
            .frame(width: 36, height: 36)
        if #available(iOS 26.0, *) {
            icon.glassEffect(.regular.interactive(), in: Circle())
        } else {
            icon
                .background(Color.watrPrimarySoft)
                .clipShape(Circle())
        }
    }

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
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            if let plan {
                VStack(spacing: 0) {
                        // Header
                        HStack {
                            Image("WATR")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 28)
                            Spacer()
                            if #available(iOS 26.0, *) {
                                GlassEffectContainer {
                                    NavigationLink {
                                        SettingsView()
                                    } label: {
                                        gearButton
                                    }
                                }
                            } else {
                                NavigationLink {
                                    SettingsView()
                                } label: {
                                    gearButton
                                }
                            }
                        }
                        .watrScreenHorizontalPadding()
                        .padding(.top, 52)
                        .padding(.bottom, 28)
                        
                    ScrollView{

                        // Hero
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today")
                                .watrSectionLabel()
                            
                            HStack(alignment: .bottom, spacing: 4) {
                                Text("\(Int(plan.totalOz))")
                                    .font(.system(size: 64, weight: .light))
                                Text("oz")
                                    .font(.system(size: 20, weight: .light))
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 10)
                            }
                            
                            if let weather {
                                Text("\(weather.condition) · \(Int(weather.temperatureF))°F")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(.secondary)
                            } else if weatherError != nil {
                                Button {
                                    Task { await loadPlan(forceWeatherRefresh: true) }
                                } label: {
                                    Text("Weather unavailable — tap to retry")
                                        .font(.system(size: 14, weight: .light))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .watrScreenHorizontalPadding()
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
                            .background(Color.watrPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .watrScreenHorizontalPadding()
                            .padding(.bottom, 28)
                        }
                        
                        // Windows list
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Today's windows")
                                .watrSectionLabel()
                                .watrScreenHorizontalPadding()
                                .padding(.bottom, 14)
                            
                            ForEach(plan.windows) { window in
                            HStack {
                                Circle()
                                    .frame(width: 8, height: 8)
                                    .foregroundStyle(
                                        isCurrentWindow(window, plan: plan) ?
                                        Color.watrPrimary :
                                        Color.gray.opacity(0.3)
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(window.name)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(
                                            isCurrentWindow(window, plan: plan) ?
                                            Color.watrPrimary :
                                            .primary
                                        )
                                    Text(windowTimeString(window))
                                        .font(.system(size: 14))
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                HStack(alignment: .bottom, spacing: 2) {
                                    Text("\(Int(window.minOz))–\(Int(window.maxOz))")
                                        .font(.system(size: 24, weight: .light))
                                    Text("oz")
                                        .font(.system(size: 13))
                                        .foregroundStyle(.secondary)
                                        .padding(.bottom, 4)
                                }
                            }
                            .padding(.vertical, 14)
                            .watrScreenHorizontalPadding()
                            Divider()
                                .padding(.leading, 28)
                        }
                        }

                        StreakFooterView(
                            streak: streakService.currentStreak,
                            message: streakService.message
                        )
                    }
                    .scrollIndicators(.hidden)
                }
            } else {
                ProgressView()
                    .tint(Color.watrPrimary)
            }
        }
        .navigationBarHidden(true)
        .task {
            streakService.recordDailyVisit()
            await loadPlan()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await loadPlan() }
            }
        }
    }
    
    private static let fallbackWeather = WeatherData(
        temperatureF: 72,
        humidityPercent: 50,
        condition: "Clear"
    )

    func loadPlan(forceWeatherRefresh: Bool = false) async {
        guard let profile = ProfileService.shared.load() else { return }

        let now = Date()
        let shouldFetchWeather = forceWeatherRefresh
            || lastWeatherFetch == nil
            || now.timeIntervalSince(lastWeatherFetch!) >= weatherFetchInterval

        await MainActor.run { self.weatherError = nil }

        let weatherData: WeatherData
        var fetchError: String? = nil

        if shouldFetchWeather {
            do {
                weatherData = try await weatherService.fetchCurrentConditions(for: profile.zipCode)
                await MainActor.run { self.lastWeatherFetch = now }
            } catch {
                weatherData = weather ?? Self.fallbackWeather
                fetchError = error.localizedDescription
            }
        } else {
            weatherData = weather ?? Self.fallbackWeather
        }

        let referenceDate = Date()
        let plans = engine.plansForUpcomingDays(
            profile: profile,
            weather: weatherData,
            referenceDate: referenceDate
        )

        await MainActor.run {
            self.weather = fetchError == nil ? weatherData : nil
            self.weatherError = fetchError
            self.plan = plans.today
            NotificationService.shared.scheduleUpcoming(
                profile: profile,
                todayPlan: plans.today,
                tomorrowPlan: plans.tomorrow,
                referenceDate: referenceDate
            )
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
    
    func isCurrentWindow(_ window: HydrationWindow, plan: HydrationPlan) -> Bool {
        plan.currentWindow?.id == window.id
    }
}
