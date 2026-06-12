//
//   SubscriptionService.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation
import Combine
import StoreKit

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    static let productIDs = ["monthly", "annual", "exitoffer"]
    static let membershipProductIDs = ["monthly", "annual"]
    static let exitOfferProductIDs = ["exitoffer"]

    private static let bypassKey = "devSubscriptionBypass"

    @Published var isSubscribed = false
    @Published var isLoadingStatus = true
    @Published private(set) var isPaywallBypassed = UserDefaults.standard.bool(forKey: bypassKey)

    var hasAccess: Bool {
        isSubscribed || isPaywallBypassed
    }

    private var transactionListener: Task<Void, Never>?
    private var hasStarted = false

    func bypassPaywall() {
        isPaywallBypassed = true
        UserDefaults.standard.set(true, forKey: Self.bypassKey)
    }

    func clearBypass() {
        isPaywallBypassed = false
        UserDefaults.standard.set(false, forKey: Self.bypassKey)
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        transactionListener = Task.detached { [weak self] in
            for await update in Transaction.updates {
                guard case .verified(let transaction) = update else { continue }
                await transaction.finish()
                await self?.refreshSubscriptionStatus()
            }
        }

        Task {
            await refreshSubscriptionStatus()
        }
    }

    func refreshSubscriptionStatus() async {
        var active = false

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if Self.productIDs.contains(transaction.productID) {
                active = true
                break
            }
        }

        isSubscribed = active
        isLoadingStatus = false
    }
}
