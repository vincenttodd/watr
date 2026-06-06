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
    @State private var weatherError: String? = nil
    
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
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            if let plan = plan {
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
                        .watrScreenHorizontalPadding()
                        .padding(.top, 52)
                        .padding(.bottom, 28)
                        
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
                            
                            if let weather = weather {
                                Text("\(weather.condition) · \(Int(weather.temperatureF))°F")
                                    .font(.system(size: 14, weight: .light))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .watrScreenHorizontalPadding()
                        .padding(.bottom, 24)
                        
                    ScrollView{
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
                                        isNextWindow(window, plan: plan) ?
                                        Color.watrPrimary :
                                        Color.gray.opacity(0.3)
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(window.name)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(
                                            isNextWindow(window, plan: plan) ?
                                            Color.watrPrimary :
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
                            .watrScreenHorizontalPadding()
                            Divider()
                                .padding(.leading, 28)
                        }
                        }
                    }
                    .scrollIndicators(.hidden)
                        
                        NavigationLink {
                            CustomizeView()
                        } label: {
                            Text("Customize schedule")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.watrPrimary)
                                .padding(.top, 24)
                        }
                        
                        Spacer().frame(height: 48)
                    }
            } else if let weatherError = weatherError {
                VStack(spacing: 12) {
                    Text("Weather unavailable")
                        .font(.system(size: 20, weight: .medium))
                    Text(weatherError)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry weather") {
                        Task { await loadPlan() }
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.watrPrimary)
                }
                .watrScreenHorizontalPadding()
            } else {
                ProgressView()
                    .tint(Color.watrPrimary)
            }
        }
        .navigationBarHidden(true)
        .task {
            await loadPlan()
        }
        .fullScreenCover(isPresented: Binding(
            get: { !subscriptionService.isSubscribed },
            set: { _ in }
        )) {
            Color.clear.onAppear {
                SubscriptionService.shared.showPaywall(from: "onboarding_complete")
            }
        }
    }
    
    func loadPlan() async {
        guard let profile = ProfileService.shared.load() else { return }
        await MainActor.run {
            self.weatherError = nil
        }

        do {
            let weatherData = try await weatherService.fetchCurrentConditions(
                for: profile.zipCode
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
        } catch {
            await MainActor.run {
                self.plan = nil
                self.weather = nil
                self.weatherError = error.localizedDescription
            }
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
