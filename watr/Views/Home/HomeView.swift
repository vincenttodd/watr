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
            .foregroundStyle(Color.watrPrimary)
            .frame(width: 36, height: 36)
        if #available(iOS 26.0, *) {
            icon.glassEffect(.regular.interactive(), in: Circle())
        } else {
            icon
                .background(Color.watrPrimarySoft)
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    var customizeButton: some View {
        let label = Text("Customize")
            .font(.unica(15))
            .foregroundStyle(Color.watrPrimary)
            .frame(height: 36)
            .padding(.horizontal, 18)
        if #available(iOS 26.0, *) {
            label.glassEffect(.regular.interactive(), in: Capsule())
        } else {
            label
                .background(Color.watrPrimarySoft)
                .clipShape(Capsule())
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
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        // SECTION 1 — Today + windows
                        todaySection(plan: plan)
                            .containerRelativeFrame(.vertical)

                        // SECTION 2 — Streak
                        streakSection
                            .containerRelativeFrame(.vertical)
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .ignoresSafeArea(edges: .bottom)
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

    // MARK: - Section 1

    @ViewBuilder
    private func todaySection(plan: HydrationPlan) -> some View {
        VStack(spacing: 0) {
            // Top buttons
            HStack {
                if #available(iOS 26.0, *) {
                    GlassEffectContainer {
                        NavigationLink {
                            CustomizeView()
                        } label: {
                            customizeButton
                        }
                    }
                } else {
                    NavigationLink {
                        CustomizeView()
                    } label: {
                        customizeButton
                    }
                }

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
            .padding(.top, 4)
            .padding(.bottom, 12)

            // Logo + Today total row
            HStack(alignment: .center) {
                Image("WATR")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)

                Spacer()

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("Today")
                        .font(.unica(16))
                        .foregroundStyle(.secondary)
                    Text("\(Int(plan.totalOz))")
                        .font(.unica(36))
                    Text("oz")
                        .font(.unica(24))
                        .foregroundStyle(.secondary)
                }
            }
            .watrScreenHorizontalPadding()
            .padding(.bottom, 16)

            Divider()
                .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
                .frame(height: 0.75)
                .padding(.horizontal, 16)

            // Windows list
            VStack(spacing: 0) {
                ForEach(Array(plan.windows.enumerated()), id: \.element.id) { index, window in
                    windowRow(window, plan: plan)
                    if index < plan.windows.count - 1 {
                        Divider()
                            .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
                            .frame(height: 0.75)
                            .padding(.horizontal, 16)
                    }
                }
            }

            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private func windowRow(_ window: HydrationWindow, plan: HydrationPlan) -> some View {
        let isCurrent = isCurrentWindow(window, plan: plan)

        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(window.name)
                    .font(.unica(16))
                    .foregroundStyle(.secondary)
                Text(roundedWindowTimeString(window))
                    .font(.unica(36))
                    .tracking(-0.36)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer()

            HStack(alignment: .bottom, spacing: 2) {
                Text("\(Int(window.minOz))-\(Int(window.maxOz))")
                    .font(.unica(48))
                Text("oz")
                    .font(.unica(24))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 6)
            }
        }
        .watrScreenHorizontalPadding()
        .padding(.vertical, 12)
        .frame(height: 92)
        .background(
            isCurrent
                ? RoundedRectangle(cornerRadius: 0)
                    .fill(Color(red: 0.008, green: 0.153, blue: 0.376).opacity(0.10))
                    .blur(radius: 12)
                : nil
        )
    }

    // MARK: - Section 2

    @ViewBuilder
    private var streakSection: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 12) {
                Text("\(streakService.currentStreak)")
                    .font(.unica(64))
                Text("Day Streak")
                    .font(.unica(18))
                    .foregroundStyle(.secondary)
            }

            ZStack {
                Color(red: 0.008, green: 0.153, blue: 0.376)
                    .opacity(0.10)
                    .blur(radius: 60)
                    .frame(height: 320)

                VStack(alignment: .leading, spacing: 6) {
                    Text(streakService.message.title)
                        .font(.unica(16))
                    Text(streakService.message.body)
                        .font(.unica(14))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            .frame(maxWidth: .infinity)
            .watrScreenHorizontalPadding()
            .padding(.top, 32)

            Spacer()

            Image("WATR")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
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

    /// Display-only: rounds each window's start/end to the nearest hour
    /// without mutating the underlying times used for notification scheduling.
    func roundedWindowTimeString(_ window: HydrationWindow) -> String {
        func roundedHour(hour: Int, minute: Int) -> Int {
            var h = hour
            if minute >= 30 {
                h = (h + 1) % 24
            }
            return h
        }

        let startHour = window.startTime.hour ?? 0
        let startMinute = window.startTime.minute ?? 0
        let endHour = window.endTime.hour ?? 0
        let endMinute = window.endTime.minute ?? 0

        let roundedStart = roundedHour(hour: startHour, minute: startMinute)
        let roundedEnd = roundedHour(hour: endHour, minute: endMinute)

        func formatHour(_ hour: Int) -> String {
            let period = hour >= 12 ? "PM" : "AM"
            let displayHour = hour % 12 == 0 ? 12 : hour % 12
            return "\(displayHour) \(period)"
        }

        let startPeriod = roundedStart >= 12 ? "PM" : "AM"
        let endPeriod = roundedEnd >= 12 ? "PM" : "AM"
        let startDisplayHour = roundedStart % 12 == 0 ? 12 : roundedStart % 12
        let endDisplayHour = roundedEnd % 12 == 0 ? 12 : roundedEnd % 12

        if startPeriod == endPeriod {
            return "\(startDisplayHour)-\(endDisplayHour) \(endPeriod)"
        } else {
            return "\(formatHour(roundedStart))-\(formatHour(roundedEnd))"
        }
    }
    
    func isCurrentWindow(_ window: HydrationWindow, plan: HydrationPlan) -> Bool {
        plan.currentWindow?.id == window.id
    }
}
