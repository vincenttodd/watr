//
//  WeatherService.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import CoreLocation
import Foundation
import WeatherKit

class WeatherService {
    private let weatherKitService = WeatherKit.WeatherService()
    private let geocoder = CLGeocoder()
    
    func fetchCurrentConditions(for zipCode: String) async throws -> WeatherData {
        let location = try await geocode(zipCode: zipCode)

        do {
            let weather = try await weatherKitService.weather(for: location)
            let current = weather.currentWeather
            
            return WeatherData(
                temperatureF: current.temperature.converted(to: .fahrenheit).value,
                humidityPercent: current.humidity * 100,
                condition: String(describing: current.condition).capitalized
            )
        } catch {
            throw WeatherError.weatherKitFailed(error.localizedDescription)
        }
    }
    
    private func geocode(zipCode: String) async throws -> CLLocation {
        let query = "\(zipCode), US"
        
        return try await withCheckedThrowingContinuation { continuation in
            geocoder.geocodeAddressString(query) { placemarks, error in
                if let error {
                    continuation.resume(throwing: WeatherError.geocodingFailed(error.localizedDescription))
                    return
                }
                
                guard let location = placemarks?.first?.location else {
                    continuation.resume(throwing: WeatherError.locationNotFound)
                    return
                }
                
                continuation.resume(returning: location)
            }
        }
    }
    
    enum WeatherError: Error {
        case locationNotFound
        case geocodingFailed(String)
        case weatherKitFailed(String)
    }
}

extension WeatherService.WeatherError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .locationNotFound:
            return "Could not find location for this ZIP code."
        case .geocodingFailed(let reason):
            return "Could not resolve ZIP to location. \(reason)"
        case .weatherKitFailed(let reason):
            return "WeatherKit failed. \(reason)"
        }
    }
}
