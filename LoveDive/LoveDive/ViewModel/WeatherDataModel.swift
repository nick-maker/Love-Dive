//
//  WeatherDataModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/17.
//

import Alamofire
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class WeatherDataModel: ObservableObject {

  @Published var weatherData: [WeatherHour] = []

  let calendar = Calendar.current
  let currentTime = Date()
  let tenDaysWeather = Firestore.firestore().collection("tenDaysWeather")

  func getTenDaysWeatherData(lat: Double, lng: Double) {
    let key = "tenDaysWeather\(lat),\(lng)"
    if
      let cachedData = UserDefaults.standard.object(forKey: key) as? Data,
      let weatherCache = try? JSONDecoder().decode(WeatherCache.self, from: cachedData),
      currentTime.timeIntervalSince(Formatter.utc.date(from: weatherCache.timestamp) ?? Date()) < 3600 * 24,
      !weatherCache.weather.isEmpty
    {
      weatherData = weatherCache.weather
    } else {
      Task {
        do {
          try await getFromFirebase(lat: lat, lng: lng, key: key)
        }
        catch {
          self.getFromAPI(lat: lat, lng: lng, key: key)
        }
      }
    }
  }

  func weatherDataDocument(lat: Double, lng: Double) -> DocumentReference {
    let key = "tenDaysWeather\(lat),\(lng)"
    let startTime = calendar.startOfDay(for: currentTime)
    return tenDaysWeather.document(key).collection(startTime.description).document(key)
  }

  func getFromFirebase(lat: Double, lng: Double, key: String) async throws {
    let data = try await weatherDataDocument(lat: lat, lng: lng).getDocument(as: WeatherData.self)
    DispatchQueue.main.async {
      self.weatherData = data.hours
    }
    saveToUserDefault(value: data, key: key)
  }

  func getFromAPI(lat: Double, lng: Double, key: String) {
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

    AF.request("https://api.stormglass.io/v2/weather/point", method: .get, parameters: params, headers: headers)
      .responseDecodable(of: WeatherData.self) { response in
        switch response.result {
        case .success(let value):
          if !value.hours.isEmpty {
            self.weatherData = value.hours
            self.saveToUserDefault(value: value, key: key)
            Task {
              do {
                try await self.saveToFirebase(lat: lat, lng: lng, data: value)
              }
            }
          }
        case .failure(let error):
          print("Error: \(error)")
        }
      }
  }

  func saveToUserDefault(value: WeatherData, key: String) {
    let weatherCache = WeatherCache(timestamp: (value.hours.first?.time)!, weather: value.hours)
    if let encodedCacheData = try? JSONEncoder().encode(weatherCache) {
      // Save the encoded Data to UserDefaults
      UserDefaults.standard.set(encodedCacheData, forKey: key)
    }
  }

  func saveToFirebase(lat: Double, lng: Double, data: WeatherData) async throws {
    try weatherDataDocument(lat: lat, lng: lng).setData(from: data)
  }

}
