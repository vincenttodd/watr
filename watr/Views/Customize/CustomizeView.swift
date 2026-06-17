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

    // Workout add sheet
    @State private var showAddWorkout = false
    @State private var addWorkoutDay: UserProfile.Weekday = .monday
    @State private var addWorkoutHour: Int = 16
    @State private var addWorkoutMinute: Int = 0

    enum EditingField: Identifiable, Equatable {
        case weekdaySleep, weekendSleep
        case height, weight, age, zip
        case workout(UserProfile.Weekday)
        case meal(UserProfile.MealType)

        var id: String {
            switch self {
            case .weekdaySleep:   return "weekdaySleep"
            case .weekendSleep:   return "weekendSleep"
            case .height:         return "height"
            case .weight:         return "weight"
            case .age:            return "age"
            case .zip:            return "zip"
            case .workout(let d): return "workout_\(d.rawValue)"
            case .meal(let m):    return "meal_\(m.rawValue)"
            }
        }

        var title: String {
            switch self {
            case .weekdaySleep:   return "Sleep (weekday)"
            case .weekendSleep:   return "Sleep (weekend)"
            case .height:         return "Height"
            case .weight:         return "Weight"
            case .age:            return "Age"
            case .zip:            return "ZIP Code"
            case .workout(let d): return "Workout (\(d.displayName))"
            case .meal(let m):    return m.displayName
            }
        }
    }

    var body: some View {
        ZStack {
            Color.watrScreenBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Top bar
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

                            // MARK: Sleep
                            row(field: .weekdaySleep,
                                label: "Sleep (weekday)",
                                value: timeRangeString(
                                    wakeHour:    profile.weekdayWake.hour ?? 7,
                                    wakeMinute:  profile.weekdayWake.minute ?? 0,
                                    sleepHour:   profile.weekdaySleep.hour ?? 23,
                                    sleepMinute: profile.weekdaySleep.minute ?? 0))
                            divider
                            row(field: .weekendSleep,
                                label: "Sleep (weekend)",
                                value: timeRangeString(
                                    wakeHour:    profile.weekendWake.hour ?? 8,
                                    wakeMinute:  profile.weekendWake.minute ?? 0,
                                    sleepHour:   profile.weekendSleep.hour ?? 23,
                                    sleepMinute: profile.weekendSleep.minute ?? 0))
                            divider

                            // MARK: Meals
                            let meals = UserProfile.MealType.allCases
                            let mealTimes = profile.mealTimes.isEmpty
                                ? UserProfile.defaultMealTimes()
                                : profile.mealTimes
                            ForEach(meals, id: \.self) { meal in
                                row(field: .meal(meal),
                                    label: meal.displayName,
                                    value: timeString(
                                        hour:   mealTimes[meal]?.hour   ?? defaultMealHour(meal),
                                        minute: mealTimes[meal]?.minute ?? 0))
                                divider
                            }

                            // MARK: Workouts
                            let sortedDays = profile.workoutDays.sorted { $0.rawValue < $1.rawValue }
                            ForEach(sortedDays, id: \.self) { day in
                                workoutRow(day: day, profile: profile)
                                divider
                            }

                            // Add workout row — always visible
                            addWorkoutRow
                            divider

                            // MARK: Body
                            row(field: .height, label: "Height", value: heightString(profile.heightInches))
                            divider
                            row(field: .weight, label: "Weight", value: "\(Int(profile.weightLbs))lb")
                            divider
                            row(field: .age,    label: "Age",    value: birthDateString(profile.birthDate))
                            divider
                            row(field: .zip,    label: "ZIP Code", value: profile.zipCode)
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
            .allowsHitTesting(editingField == nil && !showAddWorkout)
        }
        // Edit card overlay
        .overlay {
            if editingField != nil || showAddWorkout {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            editingField = nil
                            showAddWorkout = false
                        }
                    }
                    .transition(.opacity)
            }

            if let field = editingField {
                editCard(for: field)
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }

            if showAddWorkout {
                addWorkoutCard
                    .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.2), value: editingField?.id)
        .animation(.easeInOut(duration: 0.2), value: showAddWorkout)
    }

    // MARK: - Workout row (with × delete button)

    @ViewBuilder
    private func workoutRow(day: UserProfile.Weekday, profile: UserProfile) -> some View {
        let time = profile.workoutTimes[day]
        HStack(alignment: .center) {
            // × button — only in edit mode
            if isEditing {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        self.profile?.workoutDays.removeAll { $0 == day }
                        self.profile?.workoutTimes.removeValue(forKey: day)
                        saveProfile()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                        .font(.system(size: 22))
                }
                .padding(.trailing, 8)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }

            Text("Workout (\(day.shortName))")
                .font(.unica(17))
                .foregroundStyle(.primary)

            Spacer()

            Text(timeString(hour: time?.hour ?? 16, minute: time?.minute ?? 0))
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
                editingField = .workout(day)
            }
        }
    }

    // MARK: - Add workout row

    private var addWorkoutRow: some View {
        Button {
            // Pre-select first available day
            let taken = Set(profile?.workoutDays ?? [])
            addWorkoutDay = UserProfile.Weekday.allCases.first { !taken.contains($0) } ?? .monday
            addWorkoutHour = 16
            addWorkoutMinute = 0
            withAnimation(.easeInOut(duration: 0.2)) {
                showAddWorkout = true
            }
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(Color.watrPrimary)
                    .font(.system(size: 22))
                Text("Add workout")
                    .font(.unica(17))
                    .foregroundStyle(Color.watrPrimary)
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // Hide if all 7 days are taken
        .opacity((profile?.workoutDays.count ?? 0) >= 7 ? 0 : 1)
        .disabled((profile?.workoutDays.count ?? 0) >= 7)
    }

    // MARK: - Add workout card

    private var addWorkoutCard: some View {
        let takenDays = Set(profile?.workoutDays ?? [])
        let availableDays = UserProfile.Weekday.allCases.filter { !takenDays.contains($0) }

        return VStack(spacing: 0) {
            Text("Add Workout")
                .font(.unica(17))
                .padding(.top, 20)
                .padding(.bottom, 4)

            // Day picker
            VStack(spacing: 2) {
                Text("Day")
                    .watrScreenSubtitle()
                    .padding(.top, 8)
                Picker("Day", selection: $addWorkoutDay) {
                    ForEach(availableDays, id: \.self) { day in
                        Text(day.displayName).tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
                .clipped()
            }
            .padding(.horizontal, 16)

            Divider().padding(.horizontal, 8)

            // Time picker
            wheelTimePicker(
                label: "Time",
                hour: $addWorkoutHour,
                minute: $addWorkoutMinute
            )
            .padding(.horizontal, 16)

            cardDivider

            // Buttons
            HStack(spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { showAddWorkout = false }
                } label: {
                    Text("Cancel")
                        .font(.unica(17))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }

                Divider().frame(height: 44)

                Button {
                    var comps = DateComponents()
                    comps.hour = addWorkoutHour
                    comps.minute = addWorkoutMinute
                    profile?.workoutDays.append(addWorkoutDay)
                    profile?.workoutTimes[addWorkoutDay] = comps
                    saveProfile()
                    withAnimation(.easeInOut(duration: 0.2)) { showAddWorkout = false }
                } label: {
                    Text("Add")
                        .font(.unica(17))
                        .foregroundStyle(Color.watrPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
        }
        .background(Color.watrSurface)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
        .padding(.horizontal, 20)
    }

    // MARK: - Divider

    private var divider: some View {
        Divider()
            .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
            .frame(height: 0.75)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
    }

    private var cardDivider: some View {
        Divider()
            .overlay(Color(red: 0.333, green: 0.369, blue: 0.384).opacity(0.68))
            .frame(height: 0.75)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
    }

    // MARK: - Top bar

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

    // MARK: - Standard row

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
            withAnimation(.easeInOut(duration: 0.2)) { editingField = field }
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

            cardDivider

            Button {
                withAnimation(.easeInOut(duration: 0.2)) { editingField = nil }
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
                wheelTimePicker(label: "Wake",
                    hour:   Binding(get: { profile?.weekdayWake.hour   ?? 7  }, set: { profile?.weekdayWake.hour   = $0 }),
                    minute: Binding(get: { profile?.weekdayWake.minute ?? 0  }, set: { profile?.weekdayWake.minute = $0 }))
                Divider().padding(.horizontal, 8)
                wheelTimePicker(label: "Sleep",
                    hour:   Binding(get: { profile?.weekdaySleep.hour   ?? 23 }, set: { profile?.weekdaySleep.hour   = $0 }),
                    minute: Binding(get: { profile?.weekdaySleep.minute ?? 0  }, set: { profile?.weekdaySleep.minute = $0 }))
            }
        case .weekendSleep:
            VStack(spacing: 0) {
                wheelTimePicker(label: "Wake",
                    hour:   Binding(get: { profile?.weekendWake.hour   ?? 8  }, set: { profile?.weekendWake.hour   = $0 }),
                    minute: Binding(get: { profile?.weekendWake.minute ?? 0  }, set: { profile?.weekendWake.minute = $0 }))
                Divider().padding(.horizontal, 8)
                wheelTimePicker(label: "Sleep",
                    hour:   Binding(get: { profile?.weekendSleep.hour   ?? 23 }, set: { profile?.weekendSleep.hour   = $0 }),
                    minute: Binding(get: { profile?.weekendSleep.minute ?? 0  }, set: { profile?.weekendSleep.minute = $0 }))
            }
        case .meal(let meal):
            wheelTimePicker(
                label: meal.displayName,
                hour:   Binding(
                    get: { profile?.mealTimes[meal]?.hour   ?? defaultMealHour(meal) },
                    set: { v in
                        var c = profile?.mealTimes[meal] ?? DateComponents()
                        c.hour = v
                        profile?.mealTimes[meal] = c
                    }),
                minute: Binding(
                    get: { profile?.mealTimes[meal]?.minute ?? 0 },
                    set: { v in
                        var c = profile?.mealTimes[meal] ?? DateComponents()
                        c.minute = v
                        profile?.mealTimes[meal] = c
                    }))
        case .workout(let day):
            wheelTimePicker(
                label: "Time",
                hour:   Binding(
                    get: { profile?.workoutTimes[day]?.hour   ?? 16 },
                    set: { v in
                        var c = profile?.workoutTimes[day] ?? DateComponents()
                        c.hour = v
                        profile?.workoutTimes[day] = c
                    }),
                minute: Binding(
                    get: { profile?.workoutTimes[day]?.minute ?? 0 },
                    set: { v in
                        var c = profile?.workoutTimes[day] ?? DateComponents()
                        c.minute = v
                        profile?.workoutTimes[day] = c
                    }))
        case .height:
            heightEditor
        case .weight:
            weightEditor
        case .age:
            birthDateEditor
        case .zip:
            zipEditor.padding(.bottom, 16)
        }
    }

    // MARK: - Pickers

    @ViewBuilder
    private func wheelTimePicker(label: String, hour: Binding<Int>, minute: Binding<Int>) -> some View {
        VStack(spacing: 2) {
            Text(label).watrScreenSubtitle().padding(.top, 8)
            DatePicker("",
                selection: Binding(
                    get: { Calendar.current.date(bySettingHour: hour.wrappedValue, minute: minute.wrappedValue, second: 0, of: Date()) ?? Date() },
                    set: { d in
                        let c = Calendar.current.dateComponents([.hour, .minute], from: d)
                        hour.wrappedValue   = c.hour   ?? hour.wrappedValue
                        minute.wrappedValue = c.minute ?? minute.wrappedValue
                    }),
                displayedComponents: .hourAndMinute)
            .labelsHidden()
            .datePickerStyle(.wheel)
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .clipped()
        }
    }

    private let heights: [Double] = Array(stride(from: 48.0, through: 96.0, by: 1.0))
    private let weights: [Double] = Array(stride(from: 80.0, through: 400.0, by: 1.0))

    @ViewBuilder private var heightEditor: some View {
        Picker("Height", selection: Binding(get: { profile?.heightInches ?? 71 }, set: { profile?.heightInches = $0 })) {
            ForEach(heights, id: \.self) { h in Text("\(Int(h)/12)ft \(Int(h)%12)in").tag(h) }
        }.pickerStyle(.wheel).frame(height: 150).clipped()
    }

    @ViewBuilder private var weightEditor: some View {
        Picker("Weight", selection: Binding(get: { profile?.weightLbs ?? 165 }, set: { profile?.weightLbs = $0 })) {
            ForEach(weights, id: \.self) { w in Text("\(Int(w)) lb").tag(w) }
        }.pickerStyle(.wheel).frame(height: 150).clipped()
    }

    @ViewBuilder private var birthDateEditor: some View {
        DatePicker("", selection: Binding(get: { profile?.birthDate ?? Date() }, set: { profile?.birthDate = $0 }), displayedComponents: .date)
            .labelsHidden().datePickerStyle(.wheel).frame(height: 150).clipped()
    }

    @ViewBuilder private var zipEditor: some View {
        TextField("ZIP Code", text: Binding(get: { profile?.zipCode ?? "" }, set: { profile?.zipCode = $0 }))
            .font(.unica(17)).keyboardType(.numberPad).multilineTextAlignment(.center)
            .textFieldStyle(.roundedBorder).padding(.top, 8)
    }

    // MARK: - Helpers

    private func saveProfile() {
        guard let profile else { return }
        ProfileService.shared.save(profile: profile)
    }

    private func defaultMealHour(_ meal: UserProfile.MealType) -> Int {
        switch meal { case .breakfast: return 8; case .lunch: return 12; case .dinner: return 18 }
    }

    func timeString(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let dh = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let ms = minute == 0 ? "" : ":\(String(format: "%02d", minute))"
        return "\(dh)\(ms)\(period)"
    }

    func timeRangeString(wakeHour: Int, wakeMinute: Int, sleepHour: Int, sleepMinute: Int) -> String {
        func fmt(_ h: Int, _ m: Int) -> String {
            let p = h >= 12 ? "PM" : "AM"
            let dh = h > 12 ? h - 12 : (h == 0 ? 12 : h)
            let ms = m == 0 ? "" : ":\(String(format: "%02d", m))"
            return "\(dh)\(ms)\(p)"
        }
        return "\(fmt(wakeHour, wakeMinute)) – \(fmt(sleepHour, sleepMinute))"
    }

    func heightString(_ inches: Double) -> String { "\(Int(inches)/12) ft \(Int(inches)%12) in" }

    func birthDateString(_ date: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .medium; return f.string(from: date)
    }
}
