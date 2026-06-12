//
//  OnboardingTrialView.swift
//  watr
//
//  Created by Vincent Todd on 6/6/26.
//

import SwiftUI

struct OnboardingTrialView: View {
    
    @EnvironmentObject var profile: OnboardingState
    @EnvironmentObject private var subscriptionService: SubscriptionService
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showSubscriptionStore = false
    @State private var showExitOfferStore = false
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 16) {
                    Text("Try watr free\nfor 3 days")
                        .font(.system(size: 34, weight: .regular))
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                    
                    Text("Cancel anytime before your trial ends and you won't be charged.")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .watrScreenHorizontalPadding()
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        continueFromTrial()
                    } label: {
                        Text("Continue")
                            .watrPrimaryButton()
                    }
                }
                .watrScreenHorizontalPadding()
                .padding(.bottom, 48)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .task {
            await subscriptionService.refreshSubscriptionStatus()
            completeOnboardingIfSubscribed()
        }
        .fullScreenCover(isPresented: $showSubscriptionStore, onDismiss: handleMainPaywallDismiss) {
            NativeSubscriptionStoreView(productIDs: SubscriptionService.membershipProductIDs) {
                hasCompletedOnboarding = true
            }
            .environmentObject(subscriptionService)
        }
        .fullScreenCover(isPresented: $showExitOfferStore) {
            NativeSubscriptionStoreView(productIDs: SubscriptionService.exitOfferProductIDs) {
                hasCompletedOnboarding = true
            }
            .environmentObject(subscriptionService)
        }
    }
    
    private func continueFromTrial() {
        if subscriptionService.isSubscribed {
            hasCompletedOnboarding = true
        } else {
            showSubscriptionStore = true
        }
    }
    
    private func completeOnboardingIfSubscribed() {
        guard subscriptionService.isSubscribed else { return }
        hasCompletedOnboarding = true
    }
    
    private func handleMainPaywallDismiss() {
        guard !subscriptionService.isSubscribed else { return }
        showExitOfferStore = true
    }
}
