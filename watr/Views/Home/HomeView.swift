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

    private let weatherFetchInterval: TimeInterval = 10 * 60

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

    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            if let plan {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        todaySection(plan: plan)
                            .containerRelativeFrame(.vertical)
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
            .padding(.horizontal, 18)
            .padding(.top, 4)
            .padding(.bottom, 12)

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
            .padding(.horizontal, 18)
            .padding(.bottom, 16)

            Divider()
                .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
                .frame(height: 0.75)
                .padding(.horizontal, 18)

            VStack(spacing: 0) {
                ForEach(Array(plan.windows.enumerated()), id: \.element.id) { index, window in
                    windowRow(window, plan: plan)
                    if index < plan.windows.count - 1 {
                        Divider()
                            .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
                            .frame(height: 0.75)
                            .padding(.horizontal, 18)
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
                Text(smartWindowTimeString(window))
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
        .padding(.horizontal, 18)
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

            VStack(spacing: 8) {
                Text("\(streakService.currentStreak)")
                    .font(.unica(64))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("Day Streak")
                    .font(.unica(18))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.bottom, 24)

            // Fixed-size streak box — blurred, no border
            VStack(alignment: .leading, spacing: 8) {
                Text(streakService.message.title)
                    .font(.unica(16))
                    .foregroundStyle(.primary)
                Text(streakService.message.body)
                    .font(.unica(14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                Color(red: 0.008, green: 0.153, blue: 0.376)
                    .opacity(0.10)
                    .blur(radius: 16)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 18)

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

    // Always: "8-9 AM", "11-1 PM", "11 AM-1 PM" — period only on the end time
    func smartWindowTimeString(_ window: HydrationWindow) -> String {
        func roundedHour(hour: Int, minute: Int) -> Int {
            var h = hour
            if minute >= 30 { h = (h + 1) % 24 }
            return h
        }

        let rStart = roundedHour(hour: window.startTime.hour ?? 0, minute: window.startTime.minute ?? 0)
        let rEnd   = roundedHour(hour: window.endTime.hour   ?? 0, minute: window.endTime.minute   ?? 0)

        let endPeriod    = rEnd   >= 12 ? "PM" : "AM"
        let startDisplay = rStart % 12 == 0 ? 12 : rStart % 12
        let endDisplay   = rEnd   % 12 == 0 ? 12 : rEnd   % 12

        // Always omit period on start, only show on end
        return "\(startDisplay)-\(endDisplay) \(endPeriod)"
    }
    
    func isCurrentWindow(_ window: HydrationWindow, plan: HydrationPlan) -> Bool {
        plan.currentWindow?.id == window.id
    }
}
