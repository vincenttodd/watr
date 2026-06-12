//
//  watrApp.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import SwiftUI

@main
struct watrApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        SubscriptionService.shared.start()
        NotificationService.shared.registerCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionService)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active {
                        Task { await SubscriptionService.shared.refreshSubscriptionStatus() }
                    }
                }
        }
    }
}
    