//
//  ContentView.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var subscriptionService: SubscriptionService
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                NavigationStack {
                    HomeView()
                }
            } else {
                OnboardingWelcomeView()
            }
        }
    }
}
