//
//  OnboardingCompleteView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingCompleteView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @EnvironmentObject private var subscriptionService: SubscriptionService
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    @State private var isCalculating = true
    @State private var plan: HydrationPlan? = nil
    @State private var weather: WeatherData? = nil
    @State private var weatherError: String? = nil
    @State private var showTrial = false
    
    let engine = HydrationEngine()
    let weatherService = WeatherService()
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                if isCalculating {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color.watrPrimary)
                        
                        Text("Setting everything\nup for you")
                            .font(.system(size: 28, weight: .light))
                            .multilineTextAlignment(.center)
                    }
                } else if let plan {
                    VStack(spacing: 32) {
                        Text("Your daily goal")
                            .watrSectionLabel()
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(Int(plan.totalOz))")
                                .font(.system(size: 80, weight: .light))
                            Text("oz")
                                .font(.system(size: 24, weight: .light))
                                .padding(.bottom, 16)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Based on your body, schedule,\nand current weather.")
                            .font(.system(size: 16, weight: .light))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        if weatherError != nil {
                            Button {
                                Task { await calculatePlan() }
                            } label: {
                                Text("Weather unavailable — tap to retry")
                                    .font(.system(size: 13, weight: .light))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if !isCalculating, plan != nil {
                    Button {
                        saveAndContinue()
                        Task {
                            await subscriptionService.refreshSubscriptionStatus()
                            if subscriptionService.isSubscribed {
                                hasCompletedOnboarding = true
                            } else {
                                showTrial = true
                            }
                        }
                    } label: {
                        Text("Continue")
                            .watrPrimaryButton()
                    }
                    .watrScreenHorizontalPadding()
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showTrial) {
            OnboardingTrialView()
                .environmentObject(profile)
        }
        .task {
            await calculatePlan()
        }
    }
    
    private static let fallbackWeather = WeatherData(
        temperatureF: 72,
        humidityPercent: 50,
        condition: "Clear"
    )

    func calculatePlan() async {
        let userProfile = profile.toUserProfile()
        await MainActor.run {
            self.isCalculating = true
            self.weatherError = nil
        }

        let weatherData: WeatherData
        var fetchError: String? = nil

        do {
            weatherData = try await weatherService.fetchCurrentConditions(for: userProfile.zipCode)
        } catch {
            weatherData = Self.fallbackWeather
            fetchError = error.localizedDescription
        }

        let referenceDate = Date()
        let plans = engine.plansForUpcomingDays(
            profile: userProfile,
            weather: weatherData,
            referenceDate: referenceDate
        )

        await MainActor.run {
            self.weather = fetchError == nil ? weatherData : nil
            self.weatherError = fetchError
            self.plan = plans.today
            self.isCalculating = false
        }
    }
    
    func saveAndContinue() {
        let userProfile = profile.toUserProfile()
        ProfileService.shared.save(profile: userProfile)
        
        if let plan = plan, let weather {
            let plans = engine.plansForUpcomingDays(profile: userProfile, weather: weather)
            NotificationService.shared.scheduleUpcoming(
                profile: userProfile,
                todayPlan: plans.today,
                tomorrowPlan: plans.tomorrow
            )
        } else if let plan {
            NotificationService.shared.scheduleDay(plan: plan, profile: userProfile)
        }
    }
}
