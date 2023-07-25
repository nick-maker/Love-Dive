//
//  NetworkManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import Alamofire
import FirebaseFirestore
import FirebaseFirestoreSwift
import MapKit

// MARK: - NetworkManager

class NetworkManager {

  let UTCFormatter = ISO8601DateFormatter()
  let calendar = Calendar.current
  let currentTime = Date()
  weak var currentDelegate: CurrentDelegate?
  let currentWeather = Firestore.firestore().collection("currentWeather")

  func getCurrentWeatherData(lat: Double, lng: Double) {
    let key = "currentWeather\(lat),\(lng)"
    // check if there is data in UserDefault
    if
      let cachedData = UserDefaults.standard.object(forKey: key) as? Data,
      let weatherCache = try? JSONDecoder().decode(WeatherCache.self, from: cachedData),
      currentTime.timeIntervalSince(UTCFormatter.date(from: weatherCache.timestamp) ?? Date()) < 3600 * 24,
      !weatherCache.weather.isEmpty
    {
      // if yes then call delegate
      currentDelegate?.manager(didGet: weatherCache.weather, forKey: key)
    } else {
      // if no then check Firebase
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

  func weatherDocument(lat: Double, lng: Double) -> DocumentReference {
    let key = "currentWeather\(lat),\(lng)"
    let startTime = calendar.startOfDay(for: currentTime)
    return currentWeather.document(key).collection(startTime.description).document(key)
  }

  func getFromFirebase(lat: Double, lng: Double, key: String) async throws {
    let data = try await weatherDocument(lat: lat, lng: lng).getDocument(as: WeatherData.self)
    currentDelegate?.manager(didGet: data.hours, forKey: key)
    saveToUserDefault(value: data, key: key)
  }

  func getFromAPI(lat: Double, lng: Double, key: String) {
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
      "start": UTCFormatter.string(from: startTime),
      "end": UTCFormatter.string(from: endTime),
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
            self.currentDelegate?.manager(didGet: value.hours, forKey: key)
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

    // Encode the WeatherCache object to Data
    if let encodedCacheData = try? JSONEncoder().encode(weatherCache) {
      // Save the encoded Data to UserDefaults
      UserDefaults.standard.set(encodedCacheData, forKey: key)
    }
  }

  func saveToFirebase(lat: Double, lng: Double, data: WeatherData) async throws {
    try weatherDocument(lat: lat, lng: lng).setData(from: data)
  }

}

// MARK: - CurrentDelegate

protocol CurrentDelegate: AnyObject {
  func manager(didGet weatherData: [WeatherHour], forKey: String)
}
