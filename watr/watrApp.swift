//
//  watrApp.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import SwiftUI
import SuperwallKit

@main
struct watrApp: App {
    
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    init() {
        // Configure Superwall
        Superwall.configure(apiKey: "pk_EjW84d2c2KcMOK_BZzMgg")
        
        // Register notification categories
        NotificationService.shared.registerCategories()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(subscriptionService)
        }
    }
}
    
