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
    @State private var isEditing = false
    @State private var editingField: EditingField? = nil

    enum EditingField: Identifiable, Equatable {
        case weekdaySleep
        case weekendSleep
        case height
        case weight
        case age
        case zip
        case workout(UserProfile.Weekday)

        var id: String {
            switch self {
            case .weekdaySleep: return "weekdaySleep"
            case .weekendSleep: return "weekendSleep"
            case .height: return "height"
            case .weight: return "weight"
            case .age: return "age"
            case .zip: return "zip"
            case .workout(let day): return "workout_\(day.rawValue)"
            }
        }

        var title: String {
            switch self {
            case .weekdaySleep: return "Sleep (weekday)"
            case .weekendSleep: return "Sleep (weekend)"
            case .height: return "Height"
            case .weight: return "Weight"
            case .age: return "Age"
            case .zip: return "ZIP Code"
            case .workout(let day): return "Workout (\(day.displayName))"
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    backButton
                    Spacer()
                    editButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 12)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Customize")
                            .font(.unica(38))
                            .padding(.bottom, 12)
                            .padding(.horizontal, 20)

                        divider

                        if let profile = profile {
                            // Sleep section
                            row(
                                field: .weekdaySleep,
                                label: "Sleep (weekday)",
                                value: timeRangeString(
                                    wakeHour: profile.weekdayWake.hour ?? 7,
                                    wakeMinute: profile.weekdayWake.minute ?? 0,
                                    sleepHour: profile.weekdaySleep.hour ?? 23,
                                    sleepMinute: profile.weekdaySleep.minute ?? 0
                                )
                            )
                            divider
                            row(
                                field: .weekendSleep,
                                label: "Sleep (weekend)",
                                value: timeRangeString(
                                    wakeHour: profile.weekendWake.hour ?? 8,
                                    wakeMinute: profile.weekendWake.minute ?? 0,
                                    sleepHour: profile.weekendSleep.hour ?? 23,
                                    sleepMinute: profile.weekendSleep.minute ?? 0
                                )
                            )
                            divider

                            // Workout section — only shown if they have workout days
                            if !profile.workoutDays.isEmpty {
                                let sortedDays = profile.workoutDays.sorted { $0.rawValue < $1.rawValue }
                                ForEach(sortedDays, id: \.self) { day in
                                    let time = profile.workoutTimes[day]
                                    row(
                                        field: .workout(day),
                                        label: "Workout (\(day.shortName))",
                                        value: timeString(
                                            hour: time?.hour ?? 16,
                                            minute: time?.minute ?? 0
                                        )
                                    )
                                    divider
                                }
                            }

                            // Body section
                            row(field: .height, label: "Height", value: heightString(profile.heightInches))
                            divider
                            row(field: .weight, label: "Weight", value: "\(Int(profile.weightLbs))lb")
                            divider
                            row(field: .age, label: "Age", value: birthDateString(profile.birthDate))
                            divider
                            row(field: .zip, label: "ZIP Code", value: profile.zipCode)
                            divider

                            Text("Information used to calculate daily hydration needs.")
                                .font(.unica(13))
                                .foregroundStyle(.secondary)
                                .padding(.top, 16)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 48)
                }
            }
            .allowsHitTesting(editingField == nil)
        }
        .overlay {
            if editingField != nil {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editingField = nil
                        }
                    }
                    .transition(.opacity)
            }

            if let field = editingField {
                editCard(for: field)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: editingField?.id)
    }

    // MARK: - Divider

    private var divider: some View {
        Divider()
            .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
            .frame(height: 0.75)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
    }

    // MARK: - Top bar buttons

    @ViewBuilder
    private var backButton: some View {
        let label = Text("Back")
            .font(.unica(15))
            .foregroundStyle(Color.watrPrimary)
            .frame(height: 36)
            .padding(.horizontal, 18)
        Button { dismiss() } label: {
            if #available(iOS 26.0, *) {
                label.glassEffect(.regular.interactive(), in: Capsule())
            } else {
                label.background(Color.watrPrimarySoft).clipShape(Capsule())
            }
        }
    }

    @ViewBuilder
    private var editButton: some View {
        let label = Text(isEditing ? "Done" : "Edit")
            .font(.unica(15))
            .foregroundStyle(Color.watrPrimary)
            .frame(height: 36)
            .padding(.horizontal, 18)
        Button {
            if isEditing { saveProfile(); editingField = nil }
            isEditing.toggle()
        } label: {
            if #available(iOS 26.0, *) {
                label.glassEffect(.regular.interactive(), in: Capsule())
            } else {
                label.background(Color.watrPrimarySoft).clipShape(Capsule())
            }
        }
    }

    // MARK: - Row

    @ViewBuilder
    private func row(field: EditingField, label: String, value: String) -> some View {
        HStack(alignment: .center) {
            Text(label)
                .font(.unica(17))
                .foregroundStyle(.primary)

            Spacer()

            Text(value)
                .font(.unica(38))
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            guard isEditing else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                editingField = field
            }
        }
    }

    // MARK: - Edit card

    @ViewBuilder
    private func editCard(for field: EditingField) -> some View {
        VStack(spacing: 0) {
            Text(field.title)
                .font(.unica(17))
                .padding(.top, 20)
                .padding(.bottom, 4)

            editorContent(for: field)
                .padding(.horizontal, 16)

            Divider()
                .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
                .frame(height: 0.75)
                .padding(.vertical, 12)
                .padding(.horizontal, 20)

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    editingField = nil
                }
            } label: {
                Text("Done")
                    .font(.unica(17))
                    .foregroundStyle(Color.watrPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
        }
        .background(Color.watrSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Editor content

    @ViewBuilder
    private func editorContent(for field: EditingField) -> some View {
        switch field {
        case .weekdaySleep:
            VStack(spacing: 0) {
                wheelTimePicker(
                    label: "Wake",
                    hour: Binding(get: { profile?.weekdayWake.hour ?? 7 }, set: { profile?.weekdayWake.hour = $0 }),
                    minute: Binding(get: { profile?.weekdayWake.minute ?? 0 }, set: { profile?.weekdayWake.minute = $0 })
                )
                Divider().padding(.horizontal, 8)
                wheelTimePicker(
                    label: "Sleep",
                    hour: Binding(get: { profile?.weekdaySleep.hour ?? 23 }, set: { profile?.weekdaySleep.hour = $0 }),
                    minute: Binding(get: { profile?.weekdaySleep.minute ?? 0 }, set: { profile?.weekdaySleep.minute = $0 })
                )
            }
        case .weekendSleep:
            VStack(spacing: 0) {
                wheelTimePicker(
                    label: "Wake",
                    hour: Binding(get: { profile?.weekendWake.hour ?? 8 }, set: { profile?.weekendWake.hour = $0 }),
                    minute: Binding(get: { profile?.weekendWake.minute ?? 0 }, set: { profile?.weekendWake.minute = $0 })
                )
                Divider().padding(.horizontal, 8)
                wheelTimePicker(
                    label: "Sleep",
                    hour: Binding(get: { profile?.weekendSleep.hour ?? 23 }, set: { profile?.weekendSleep.hour = $0 }),
                    minute: Binding(get: { profile?.weekendSleep.minute ?? 0 }, set: { profile?.weekendSleep.minute = $0 })
                )
            }
        case .height:
            heightEditor
        case .weight:
            weightEditor
        case .age:
            birthDateEditor
        case .zip:
            zipEditor.padding(.bottom, 16)
        case .workout(let day):
            wheelTimePicker(
                label: "Workout time",
                hour: Binding(
                    get: { profile?.workoutTimes[day]?.hour ?? 16 },
                    set: {
                        var comps = profile?.workoutTimes[day] ?? DateComponents()
                        comps.hour = $0
                        profile?.workoutTimes[day] = comps
                    }
                ),
                minute: Binding(
                    get: { profile?.workoutTimes[day]?.minute ?? 0 },
                    set: {
                        var comps = profile?.workoutTimes[day] ?? DateComponents()
                        comps.minute = $0
                        profile?.workoutTimes[day] = comps
                    }
                )
            )
        }
    }

    @ViewBuilder
    private func wheelTimePicker(label: String, hour: Binding<Int>, minute: Binding<Int>) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .watrScreenSubtitle()
                .padding(.top, 8)
            DatePicker(
                "",
                selection: Binding(
                    get: {
                        Calendar.current.date(bySettingHour: hour.wrappedValue, minute: minute.wrappedValue, second: 0, of: Date()) ?? Date()
                    },
                    set: { newValue in
                        let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                        hour.wrappedValue = c.hour ?? hour.wrappedValue
                        minute.wrappedValue = c.minute ?? minute.wrappedValue
                    }
                ),
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .clipped()
        }
    }

    private let heights: [Double] = Array(stride(from: 48.0, through: 96.0, by: 1.0))
    private let weights: [Double] = Array(stride(from: 80.0, through: 400.0, by: 1.0))

    @ViewBuilder
    private var heightEditor: some View {
        Picker("Height", selection: Binding(get: { profile?.heightInches ?? 71 }, set: { profile?.heightInches = $0 })) {
            ForEach(heights, id: \.self) { h in
                Text("\(Int(h) / 12)ft \(Int(h) % 12)in").tag(h)
            }
        }
        .pickerStyle(.wheel).frame(height: 150).clipped()
    }

    @ViewBuilder
    private var weightEditor: some View {
        Picker("Weight", selection: Binding(get: { profile?.weightLbs ?? 165 }, set: { profile?.weightLbs = $0 })) {
            ForEach(weights, id: \.self) { w in Text("\(Int(w)) lb").tag(w) }
        }
        .pickerStyle(.wheel).frame(height: 150).clipped()
    }

    @ViewBuilder
    private var birthDateEditor: some View {
        DatePicker("", selection: Binding(get: { profile?.birthDate ?? Date() }, set: { profile?.birthDate = $0 }), displayedComponents: .date)
            .labelsHidden().datePickerStyle(.wheel).frame(height: 150).clipped()
    }

    @ViewBuilder
    private var zipEditor: some View {
        TextField("ZIP Code", text: Binding(get: { profile?.zipCode ?? "" }, set: { profile?.zipCode = $0 }))
            .font(.unica(17))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder)
            .padding(.top, 8)
    }

    // MARK: - Helpers

    private func saveProfile() {
        guard let profile = profile else { return }
        ProfileService.shared.save(profile: profile)
    }

    func timeString(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let dh = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let ms = minute == 0 ? "" : ":\(String(format: "%02d", minute))"
        return "\(dh)\(ms)\(period)"
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
        "\(Int(inches) / 12) ft \(Int(inches) % 12) in"
    }

    func birthDateString(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium; return f.string(from: date)
    }
}
