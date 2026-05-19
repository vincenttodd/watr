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
    init() {
        Superwall.configure(apiKey: "your_superwall_api_key")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
