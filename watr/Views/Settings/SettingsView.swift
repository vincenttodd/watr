//
//  SettingsView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @EnvironmentObject private var subscriptionService: SubscriptionService
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @State private var showManageSubscriptions = false
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Schedule section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Schedule")
                            .watrSectionLabel()
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                CustomizeView()
                            } label: {
                                settingRow(icon: "calendar", label: "Customize schedule")
                            }
                        }
                        .watrCardSurface()
                    }
                    
                    // Notifications section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notifications")
                            .watrSectionLabel()
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Hydration reminders")
                                    .font(.system(size: 15))
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .tint(Color.watrPrimary)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                            
                            Divider().padding(.leading, 16)
                            
                            HStack {
                                Text("Pause notifications")
                                    .font(.system(size: 15))
                                Spacer()
                                HStack(spacing: 8) {
                                    ForEach(["1d", "3d", "5d"], id: \.self) { duration in
                                        Button(duration) {
                                            // pause logic later
                                        }
                                        .font(.system(size: 13))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 12)
                                        .frame(height: 32)
                                        .background(Color.watrNeutralButtonBackground)
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                        }
                        .watrCardSurface()
                    }
                    
                    // Subscription section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subscription")
                            .watrSectionLabel()
                        
                        VStack(spacing: 0) {
                            NavigationLink {
                                NativeSubscriptionStoreView(productIDs: SubscriptionService.membershipProductIDs)
                            } label: {
                                settingRow(icon: "creditcard.fill", label: "View plans")
                            }

                            Divider().padding(.leading, 56)

                            Button {
                                showManageSubscriptions = true
                            } label: {
                                settingRow(icon: "crown.fill", label: "Manage subscription")
                            }
                            .buttonStyle(.plain)

                            Divider().padding(.leading, 56)
                            settingRow(icon: "gift.fill", label: "Refer a friend — get 1 month free")
                        }
                        .watrCardSurface()
                    }
                    
                    // Support section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support")
                            .watrSectionLabel()
                        
                        VStack(spacing: 0) {
                            settingRow(icon: "ant.fill", label: "Report a bug")
                            Divider().padding(.leading, 56)
                            settingRow(icon: "bubble.left.fill", label: "Send feedback")
                            Divider().padding(.leading, 56)
                            Link(destination: URL(string: "https://watrapp.com/privacy")!) {
                                settingRow(icon: "hand.raised.fill", label: "Privacy Policy")
                            }
                            .foregroundStyle(.primary)
                            Divider().padding(.leading, 56)
                            Link(destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!) {
                                settingRow(icon: "doc.text.fill", label: "Terms of Use")
                            }
                            .foregroundStyle(.primary)
                        }
                        .watrCardSurface()
                    }
                    
                    #if DEBUG
                    Button {
                        SubscriptionService.shared.bypassPaywall()
                    } label: {
                        Text("Bypass subscription")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        Text("Re-show onboarding")
                            .font(.system(size: 15))
                            .foregroundStyle(.blue.opacity(0.7))
                    }

                    Button {
                        ProfileService.shared.clear()
                        SubscriptionService.shared.clearBypass()
                        hasCompletedOnboarding = false
                    } label: {
                        Text("Reset onboarding")
                            .font(.system(size: 15))
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    #endif
                    
                    Text("Made with ♥ in Chicago")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .watrScreenHorizontalPadding()
                .padding(.top, 20)
                .padding(.bottom, 48)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptions)
        .onChange(of: notificationsEnabled) { _, enabled in
            if enabled {
                if let profile = ProfileService.shared.load() {
                    NotificationService.shared.rescheduleIfNeeded(profile: profile)
                }
            } else {
                NotificationService.shared.cancelAll()
            }
        }
    }
    
    @ViewBuilder
    func settingRow(icon: String, label: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .watrIconBadge()
            
            Text(label)
                .font(.system(size: 15))
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
}
