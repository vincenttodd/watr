//
//   SubscriptionService.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation
import Combine
import SuperwallKit

class SubscriptionService: ObservableObject {
    
    static let shared = SubscriptionService()
    
    @Published var isSubscribed = false
    
    func checkSubscription() async {
        let status = await Superwall.shared.subscriptionStatus
        await MainActor.run {
            switch status {
            case .active:
                self.isSubscribed = true
            default:
                self.isSubscribed = false
            }
        }
    }
    
    func showPaywall(from placement: String) {
        Superwall.shared.register(placement: placement)
    }
    
    func showPaywallWithCompletion(from placement: String, completion: @escaping () -> Void) {
        Superwall.shared.register(placement: placement) {
            completion()
        }
    }
}
