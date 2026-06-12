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
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                NavigationStack {
                    HomeView()
                }
                .fullScreenCover(isPresented: $showPaywall) {
                    NativeSubscriptionStoreView(productIDs: SubscriptionService.membershipProductIDs)
                        .environmentObject(subscriptionService)
                }
            } else {
                OnboardingWelcomeView()
            }
        }
        .onChange(of: subscriptionService.isLoadingStatus) { _, isLoading in
            if !isLoading && hasCompletedOnboarding && !subscriptionService.hasAccess {
                showPaywall = true
            }
        }
        .onChange(of: subscriptionService.hasAccess) { _, hasAccess in
            if hasAccess {
                showPaywall = false
            }
        }
    }
}
