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
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    // Notifications section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notifications")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("Hydration reminders")
                                    .font(.system(size: 15))
                                Spacer()
                                Toggle("", isOn: $notificationsEnabled)
                                    .tint(Color(red: 0.18, green: 0.35, blue: 0.24))
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
                                        .background(Color.gray.opacity(0.1))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 52)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Subscription section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Subscription")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        VStack(spacing: 0) {
                            settingRow(icon: "crown.fill", label: "Manage subscription")
                            Divider().padding(.leading, 56)
                            settingRow(icon: "gift.fill", label: "Refer a friend — get 1 month free")
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    
                    // Support section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(1)
                        
                        VStack(spacing: 0) {
                            settingRow(icon: "ant.fill", label: "Report a bug")
                            Divider().padding(.leading, 56)
                            settingRow(icon: "bubble.left.fill", label: "Send feedback")
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
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
                .padding(.horizontal, 28)
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
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.18, green: 0.35, blue: 0.24))
                .frame(width: 32, height: 32)
                .background(Color(red: 0.18, green: 0.35, blue: 0.24).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
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
