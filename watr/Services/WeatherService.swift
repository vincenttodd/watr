//
//  WeatherService.swift
//  watr
//
//  Created by Vincent Todd on 5/18/26.
//

import Foundation

class WeatherService {
    private let apiKey = "your_openweather_api_key"
    
    func fetchCurrentConditions(for zipCode: String) async throws -> WeatherData {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?zip=\(zipCode),us&appid=\(apiKey)&units=imperial"
        
        guard let url = URL(string: urlString) else {
            throw WeatherError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
        
        return WeatherData(
            temperatureF: response.main.temp,
            humidityPercent: Double(response.main.humidity),
            condition: response.weather.first?.main ?? "Clear"
        )
    }
    
    enum WeatherError: Error {
        case invalidURL
        case locationNotFound
    }
}

// MARK: - Response Models
struct OpenWeatherResponse: Decodable {
    let main: Main
    let weather: [Weather]
    
    struct Main: Decodable {
        let temp: Double
        let humidity: Int
    }
    
    struct Weather: Decodable {
        let main: String
    }
}
