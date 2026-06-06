//
//  OnboardingLocationView.swift
//  watr
//
//  Created by Vincent Todd on 5/19/26.
//

import Combine
import CoreLocation
import SwiftUI

struct OnboardingLocationView: View {

    enum LocationEntryMode {
        case purpose
        case zipFallback
    }

    @EnvironmentObject var profile: OnboardingState
    @FocusState private var zipFocused: Bool
    @StateObject private var locationModel = OnboardingLocationModel()
    @State private var entryMode: LocationEntryMode = .purpose
    @State private var continueWithAutoLocation = false

    private var isZipValid: Bool {
        profile.zipCode.count == 5
    }

    var body: some View {
        ZStack {
            Color.watrScreenBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Where are\nyou located?")
                        .watrScreenTitle()

                    Text("We use your location to calculate hydration based on local weather.")
                        .watrScreenSubtitle()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .watrScreenHorizontalPadding()
                .padding(.top, 48)

                Spacer()

                if entryMode == .purpose {
                    locationPreviewCard
                }

                Spacer()

                if entryMode == .purpose {
                    purposeView
                } else {
                    zipFallbackView
                }
            }
            .watrScreenHorizontalPadding()
            .padding(.bottom, 48)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $continueWithAutoLocation) {
            OnboardingCompleteView()
                .environmentObject(profile)
        }
        .onChange(of: locationModel.resolvedZip) { resolvedZip in
            guard let resolvedZip else { return }
            profile.zipCode = resolvedZip
            continueWithAutoLocation = true
        }
        .onChange(of: locationModel.authorizationStatus) { status in
            if status == .denied || status == .restricted {
                entryMode = .zipFallback
            }
        }
        .onChange(of: profile.zipCode) { newValue in
            let sanitized = String(newValue.filter(\.isNumber).prefix(5))
            if sanitized != newValue {
                profile.zipCode = sanitized
            }
        }
    }

    private var purposeView: some View {
        VStack(spacing: 14) {
            if let errorMessage = locationModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                locationModel.requestLocationAccessAndFetch()
            } label: {
                Text(locationModel.isRequesting ? "Finding location..." : "Share Current Location")
                    .watrPrimaryButton(enabled: !locationModel.isRequesting)
            }
            .disabled(locationModel.isRequesting)

            Button {
                entryMode = .zipFallback
                zipFocused = true
            } label: {
                Text("Enter ZIP Instead")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.watrPrimary)
            }
        }
    }

    private var locationPreviewCard: some View {
        VStack(spacing: 14) {
            Text("72°F")
                .font(.system(size: 64, weight: .light))

            Text("Local weather preview")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)

            Text("Used to personalize your hydration target for heat and humidity.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text("Only used to estimate weather for your plan.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private var zipFallbackView: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("ZIP Code")
                    .watrSectionLabel()

                TextField("e.g. 90210", text: $profile.zipCode)
                    .font(.system(size: 24, weight: .light))
                    .keyboardType(.numberPad)
                    .focused($zipFocused)
                    .padding(.horizontal, 20)
                    .frame(height: 60)
                    .background(Color.watrSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            NavigationLink {
                OnboardingNotificationView()
                    .environmentObject(profile)
            } label: {
                Text("Continue")
                    .watrPrimaryButton(enabled: isZipValid)
            }
            .disabled(!isZipValid)
        }
    }
}

final class OnboardingLocationModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isRequesting = false
    @Published var errorMessage: String?
    @Published var resolvedZip: String?
    @Published var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var isWaitingForAuthorizationAfterTap = false

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func requestLocationAccessAndFetch() {
        errorMessage = nil
        resolvedZip = nil
        isWaitingForAuthorizationAfterTap = false

        switch manager.authorizationStatus {
        case .notDetermined:
            isWaitingForAuthorizationAfterTap = true
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            requestLocation()
        case .denied, .restricted:
            errorMessage = "Location permission is off. Enter ZIP instead."
        @unknown default:
            errorMessage = "Location permission status is unknown. Enter ZIP instead."
        }
    }

    private func requestLocation() {
        isRequesting = true
        manager.requestLocation()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if isWaitingForAuthorizationAfterTap &&
            (manager.authorizationStatus == .authorizedAlways ||
             manager.authorizationStatus == .authorizedWhenInUse) {
            isWaitingForAuthorizationAfterTap = false
            requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isRequesting = false
        errorMessage = "Couldn't access current location. Enter ZIP instead."
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            isRequesting = false
            errorMessage = "Couldn't resolve your location. Enter ZIP instead."
            return
        }

        Task {
            do {
                let placemarks = try await geocoder.reverseGeocodeLocation(location)
                let postalCode = placemarks
                    .first?
                    .postalCode?
                    .filter(\.isNumber)

                await MainActor.run {
                    self.isRequesting = false
                    if let postalCode, postalCode.count == 5 {
                        self.resolvedZip = postalCode
                    } else {
                        self.errorMessage = "Couldn't determine ZIP from location. Enter ZIP instead."
                    }
                }
            } catch {
                await MainActor.run {
                    self.isRequesting = false
                    self.errorMessage = "Couldn't determine ZIP from location. Enter ZIP instead."
                }
            }
        }
    }
}
