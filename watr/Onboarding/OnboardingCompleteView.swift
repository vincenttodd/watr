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
                    VStack(spacing: 24) {
                        WatrLoadingView()
                        
                        Text("Setting everything\nup for you")
                            .font(.unica(28))
                            .multilineTextAlignment(.center)
                    }
                } else if let plan {
                    VStack(spacing: 32) {
                        Text("Your goal today")
                            .watrScreenTitle()
                            .multilineTextAlignment(.center)
                        
                        HStack(alignment: .bottom, spacing: 4) {
                            Text("\(Int(plan.totalOz))")
                                .font(.unica(80))
                            Text("oz")
                                .font(.unica(24))
                                .padding(.bottom, 16)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text("Based on your body, activity,\nand current weather.")
                            .font(.unica(16))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        if weatherError != nil {
                            Button {
                                Task { await calculatePlan() }
                            } label: {
                                Text("Weather unavailable — tap to retry")
                                    .font(.unica(13))
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
            // Run weather fetch and minimum 1.8s loading animation in parallel
            async let weatherFetch = weatherService.fetchCurrentConditions(for: userProfile.zipCode)
            async let minimumDelay: Void = Task.sleep(nanoseconds: 1_800_000_000)
            let (fetched, _) = try await (weatherFetch, minimumDelay)
            weatherData = fetched
        } catch {
            // Ensure minimum delay even on failure so loading animation completes
            try? await Task.sleep(nanoseconds: 1_800_000_000)
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

struct WatrLoadingView: View {
    @State private var isAnimating = false

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round))
            .frame(width: 28, height: 28)
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
            .animation(.linear(duration: 0.8).repeatForever(autoreverses: false), value: isAnimating)
            .onAppear { isAnimating = true }
    }
}
