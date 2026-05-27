//
//  OnboardingCompleteView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct OnboardingCompleteView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    @State private var isCalculating = true
    @State private var plan: HydrationPlan? = nil
    @State private var weather: WeatherData? = nil
    
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
                } else if let plan = plan {
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
                    }
                }
                
                Spacer()
                
                if !isCalculating {
                    Button {
                        // Temporarily bypass paywall until Superwall is configured
                        saveAndContinue()
                    } label: {
                        Text("Start drinking")
                            .watrPrimaryButton()
                    }
                    .watrScreenHorizontalPadding()
                    .padding(.bottom, 48)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await calculatePlan()
        }
    }
    
    func calculatePlan() async {
        let userProfile = profile.toUserProfile()
        
        // Fetch weather
        let fetchedWeather = try? await weatherService.fetchCurrentConditions(
            for: userProfile.zipCode
        )
        
        let weatherData = fetchedWeather ?? WeatherData(
            temperatureF: 72,
            humidityPercent: 50,
            condition: "Clear"
        )
        
        let today = Calendar.current.component(.weekday, from: Date())
        let isWorkoutDay = userProfile.workoutDays.contains(
            UserProfile.Weekday(rawValue: today) ?? .monday
        )
        
        let calculatedPlan = engine.calculate(
            profile: userProfile,
            weather: weatherData,
            isWorkoutDay: isWorkoutDay
        )
        
        await MainActor.run {
            self.weather = weatherData
            self.plan = calculatedPlan
            self.isCalculating = false
        }
    }
    
    func saveAndContinue() {
        let userProfile = profile.toUserProfile()
        ProfileService.shared.save(profile: userProfile)
        
        if let plan = plan {
            NotificationService.shared.scheduleDay(plan: plan)
        }
        
        hasCompletedOnboarding = true
    }
}
