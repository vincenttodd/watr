//
//  NotificationProgressService.swift
//  watr
//

import Foundation

final class NotificationProgressService {

    static let shared = NotificationProgressService()

    private let defaults = UserDefaults.standard
    private let keyPrefix = "notificationProgress."

    func completedWindows(for dayKey: String) -> Set<String> {
        Set(defaults.stringArray(forKey: storageKey(for: dayKey)) ?? [])
    }

    func markComplete(windowName: String, dayKey: String) {
        var completed = completedWindows(for: dayKey)
        completed.insert(windowName)
        defaults.set(Array(completed), forKey: storageKey(for: dayKey))
    }

    func isComplete(windowName: String, dayKey: String) -> Bool {
        completedWindows(for: dayKey).contains(windowName)
    }

    private func storageKey(for dayKey: String) -> String {
        "\(keyPrefix)\(dayKey)"
    }
}
