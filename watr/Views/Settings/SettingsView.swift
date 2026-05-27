//
//  SettingsView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @State private var notificationsEnabled = true
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
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
                            settingRow(icon: "crown.fill", label: "Manage subscription")
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
                        }
                        .watrCardSurface()
                    }
                    
                    // Reset (for testing)
                    Button {
                        ProfileService.shared.clear()
                        hasCompletedOnboarding = false
                    } label: {
                        Text("Reset onboarding")
                            .font(.system(size: 15))
                            .foregroundStyle(.red.opacity(0.7))
                    }
                    
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
