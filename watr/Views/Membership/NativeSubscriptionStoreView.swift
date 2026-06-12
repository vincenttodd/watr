//
//  NativeSubscriptionStoreView.swift
//  watr
//

import StoreKit
import SwiftUI

struct NativeSubscriptionStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var subscriptionService: SubscriptionService

    var productIDs: [String] = SubscriptionService.productIDs
    var onSubscribed: (() -> Void)? = nil

    // Guards against double-firing from onInAppPurchaseCompletion + onChange
    @State private var hasHandledCompletion = false

    var body: some View {
        SubscriptionStoreView(productIDs: productIDs)
            .storeButton(.visible, for: .restorePurchases)
            .onInAppPurchaseCompletion { _, result in
                guard case .success(.success) = result else { return }
                Task {
                    await subscriptionService.refreshSubscriptionStatus()
                    complete()
                }
            }
            // Catches restore purchases, which don't trigger onInAppPurchaseCompletion
            .onChange(of: subscriptionService.isSubscribed) { _, isSubscribed in
                if isSubscribed { complete() }
            }
    }

    private func complete() {
        guard subscriptionService.isSubscribed, !hasHandledCompletion else { return }
        hasHandledCompletion = true
        onSubscribed?()
        dismiss()
    }
}

#Preview {
    NativeSubscriptionStoreView()
        .environmentObject(SubscriptionService.shared)
}
