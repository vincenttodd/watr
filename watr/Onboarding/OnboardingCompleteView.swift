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
    @State private var weatherError: String? = nil
    
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
                } else if let weatherError = weatherError {
                    VStack(spacing: 12) {
                        Text("Weather unavailable")
                            .font(.unica(20))
                        Text(weatherError)
                            .font(.unica(14))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry weather") {
                            Task { await calculatePlan() }
                        }
                        .watrLinkButton()
                    }
                    .watrScreenHorizontalPadding()
                } else if let plan = plan {
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
                    }
                }
                
                Spacer()
                
                if !isCalculating && plan != nil {
                    NavigationLink {
                        OnboardingTrialView()
                            .environmentObject(profile)
                    } label: {
                        Text("Continue")
                            .watrPrimaryButton()
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        saveAndContinue()
                    })
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
        await MainActor.run {
            self.isCalculating = true
            self.weatherError = nil
        }

        do {
            async let weatherFetch = weatherService.fetchCurrentConditions(for: userProfile.zipCode)
            async let minimumDelay: Void = Task.sleep(nanoseconds: 1_800_000_000)

            let (weatherData, _) = try await (weatherFetch, minimumDelay)

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
        } catch {
            await MainActor.run {
                self.weather = nil
                self.plan = nil
                self.weatherError = error.localizedDescription
                self.isCalculating = false
            }
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
