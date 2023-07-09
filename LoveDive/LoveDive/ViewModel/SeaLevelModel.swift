//
//  SeaLevelViewModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/7.
//

import Alamofire
import SwiftUI

class SeaLevelModel: ObservableObject {

  @Published var seaLevel: [SeaLevel] = []
  @Published var weatherData: [WeatherHour] = []
  let UTCFormatter = ISO8601DateFormatter()
  let calendar = Calendar.current
  let currentTime = Date()

  func getTenDaysSeaLevel(lat: Double, lng: Double) {
    let params: [String: Any] = [
      "lat": lat,
      "lng": lng,
    ]

    let headers: HTTPHeaders = [
      "Authorization": Config.weatherAPIKey,
    ]

    let key = "seaLevel\(lat),\(lng)"
    if
      let cachedData = UserDefaults.standard.object(forKey: key) as? Data,
      let tideCache = try? JSONDecoder().decode(TideCache.self, from: cachedData),
      currentTime.timeIntervalSince(UTCFormatter.date(from: tideCache.timestamp) ?? Date()) < 3600 * 24,
      !tideCache.seaLevel.isEmpty
    {
      seaLevel = tideCache.seaLevel
    } else {
      AF.request("https://api.stormglass.io/v2/tide/sea-level/point", method: .get, parameters: params, headers: headers)
        .validate()
        .responseDecodable(of: TideData.self) { response in
          switch response.result {
          case .success(let value):
            if !value.data.isEmpty {
              self.seaLevel = value.data
              let tideCache = TideCache(timestamp: (value.data.first?.time)!, seaLevel: value.data)
              if let encodedCacheData = try? JSONEncoder().encode(tideCache) {
                // Save the encoded Data to UserDefaults
                UserDefaults.standard.set(encodedCacheData, forKey: key)
              }
            }
          case .failure(let error):
            print("Error: \(error)")
          }
        }
    }
  }

  func getTenDaysWeatherData(lat: Double, lng: Double) {
    let startTime = calendar.startOfDay(for: currentTime)
    let endTime = startTime.addingTimeInterval(60 * 60 * 24) // Next Day

    let parameters = [
      "airTemperature",
      "waterTemperature",
      "waveHeight",
      "windSpeed",
    ]

    let params: [String: Any] = [
      "lat": lat,
      "lng": lng,
      "params": parameters.joined(separator: ","),
      "source": ["icon", "meteo", "noaa", "sg"],
    ]

    let headers: HTTPHeaders = [
      "Authorization": Config.weatherAPIKey,
    ]

    let key = "tenDaysWeather\(lat),\(lng)"
    if
      let cachedData = UserDefaults.standard.object(forKey: key) as? Data,
      let weatherCache = try? JSONDecoder().decode(WeatherCache.self, from: cachedData),
      currentTime.timeIntervalSince(UTCFormatter.date(from: weatherCache.timestamp) ?? Date()) < 3600 * 24,
      !weatherCache.weather.isEmpty
    {
      weatherData = weatherCache.weather
    } else {
      AF.request("https://api.stormglass.io/v2/weather/point", method: .get, parameters: params, headers: headers)
        .responseDecodable(of: WeatherData.self) { response in
          switch response.result {
          case .success(let value):

            // Create the WeatherCache object
            if !value.hours.isEmpty {
              let weatherCache = WeatherCache(timestamp: (value.hours.first?.time)!, weather: value.hours)
              self.weatherData = value.hours
              // Encode the WeatherCache object to Data
              if let encodedCacheData = try? JSONEncoder().encode(weatherCache) {
                // Save the encoded Data to UserDefaults
                UserDefaults.standard.set(encodedCacheData, forKey: key)
              }
            }
          case .failure(let error):
            print("Error: \(error)")
          }
        }
    }
  }
}
