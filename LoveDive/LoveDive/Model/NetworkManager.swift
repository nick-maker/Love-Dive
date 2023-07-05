//
//  NetworkManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import Alamofire
import MapKit

// MARK: - NetworkManager

class NetworkManager {

  let UTCFormatter = ISO8601DateFormatter()
  weak var delegate: WeatherDelegate?

  func getCurrentWeatherData(lat: Double, lng: Double, forAnnotation annotation: MKAnnotation) {
    let calendar = Calendar.current
    let currentTime = Date()
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

    let key = "\(lat),\(lng)"
    if
      let cachedData = UserDefaults.standard.object(forKey: key) as? Data,
      let weatherCache = try? JSONDecoder().decode(WeatherCache.self, from: cachedData),
      currentTime.timeIntervalSince(UTCFormatter.date(from: weatherCache.timestamp) ?? Date()) < 3600 * 24,
      !weatherCache.weather.isEmpty
    {
      delegate?.manager(didGet: weatherCache.weather, forAnnotation: annotation)
    } else {
      AF.request("https://api.stormglass.io/v2/weather/point", method: .get, parameters: params, headers: headers)
        .responseDecodable(of: WeatherData.self) { response in
          switch response.result {
          case .success(let value):
            self.delegate?.manager(didGet: value.hours, forAnnotation: annotation)
            // Create the WeatherCache object
            if !value.hours.isEmpty {
              let weatherCache = WeatherCache(timestamp: (value.hours.first?.time)!, weather: value.hours)

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

  func decodeJSON() -> TideData {
    guard let url = Bundle.main.url(forResource: "SeaLevel", withExtension: "json") else {
      print("Resources not found")
      return TideData(data: [])
    }
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(TideData.self, from: data)
      let jsonString = String(data: data, encoding: .utf8)
      return decodedData
    } catch {
      print("Error decoding JSON: \(error.localizedDescription)")
      return TideData(data: [])
    }
  }

}

// MARK: - WeatherDelegate

protocol WeatherDelegate: AnyObject {
  func manager(didGet weatherData: [WeatherHour], forAnnotation annotation: MKAnnotation)
}
