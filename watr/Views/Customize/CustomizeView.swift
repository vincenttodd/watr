//
//  CustomizeView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import SwiftUI

struct CustomizeView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var profile: UserProfile? = ProfileService.shared.load()
    
    var body: some View {
        ZStack {
            Color(red: 0.957, green: 0.945, blue: 0.925)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    if let profile = profile {
                        // Sleep section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Sleep")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                settingRow(
                                    icon: "moon.fill",
                                    label: "Weekday sleep",
                                    value: timeRangeString(
                                        wakeHour: profile.weekdayWake.hour ?? 7,
                                        wakeMinute: profile.weekdayWake.minute ?? 0,
                                        sleepHour: profile.weekdaySleep.hour ?? 23,
                                        sleepMinute: profile.weekdaySleep.minute ?? 0
                                    )
                                )
                                Divider().padding(.leading, 56)
                                settingRow(
                                    icon: "moon.stars.fill",
                                    label: "Weekend sleep",
                                    value: timeRangeString(
                                        wakeHour: profile.weekendWake.hour ?? 8,
                                        wakeMinute: profile.weekendWake.minute ?? 0,
                                        sleepHour: profile.weekendSleep.hour ?? 0,
                                        sleepMinute: profile.weekendSleep.minute ?? 0
                                    )
                                )
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Body section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Body")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1)
                            
                            VStack(spacing: 0) {
                                settingRow(
                                    icon: "ruler",
                                    label: "Height",
                                    value: heightString(profile.heightInches)
                                )
                                Divider().padding(.leading, 56)
                                settingRow(
                                    icon: "scalemass",
                                    label: "Weight",
                                    value: "\(Int(profile.weightLbs)) lb"
                                )
                                Divider().padding(.leading, 56)
                                settingRow(
                                    icon: "calendar",
                                    label: "Date of birth",
                                    value: birthDateString(profile.birthDate)
                                )
                            }
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        
                        // Location section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Environment")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                                .textCase(.uppercase)
                                .tracking(1)
                            
                            settingRow(
                                icon: "location.fill",
                                label: "ZIP Code",
                                value: profile.zipCode
                            )
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 28)
                .padding(.top, 20)
                .padding(.bottom, 48)
            }
        }
        .navigationTitle("Customize")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    func settingRow(icon: String, label: String, value: String) -> some View {
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
            
            Text(value)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
    }
    
    func timeRangeString(wakeHour: Int, wakeMinute: Int, sleepHour: Int, sleepMinute: Int) -> String {
        func fmt(_ h: Int, _ m: Int) -> String {
            let period = h >= 12 ? "PM" : "AM"
            let dh = h > 12 ? h - 12 : (h == 0 ? 12 : h)
            let ms = m == 0 ? "" : ":\(String(format: "%02d", m))"
            return "\(dh)\(ms)\(period)"
        }
        return "\(fmt(wakeHour, wakeMinute)) – \(fmt(sleepHour, sleepMinute))"
    }
    
    func heightString(_ inches: Double) -> String {
        let feet = Int(inches) / 12
        let inch = Int(inches) % 12
        return "\(feet) ft \(inch) in"
    }
    
    func birthDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
