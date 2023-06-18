//
//  NetworkManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import Alamofire
import Foundation

// MARK: - NetworkManager

class NetworkManager {

  // MARK: Internal

  weak var delegate: WeatherDelegate?

  func getData(lat: Double, lng: Double) {
    let key = "\(lat),\(lng)"
    if let cachedData = cache[key], Date().timeIntervalSince(cachedData.timestamp) < 3600 {
      delegate?.manager(didGet: cachedData.weather)
    } else {
      let currentTime = Date()

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
      formatter.locale = Locale(identifier: "en_US_POSIX")
      formatter.timeZone = TimeZone(secondsFromGMT: 0)

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
        "start": formatter.string(from: currentTime),
        "end": formatter.string(from: currentTime),
        "source": ["icon", "meteo", "noaa", "sg"],
      ]

      let headers: HTTPHeaders = [
        "Authorization": Config.weatherAPIKey,
      ]

      AF.request("https://api.stormglass.io/v2/weather/point", method: .get, parameters: params, headers: headers)
        .responseDecodable(of: WeatherData.self) { response in
          switch response.result {
          case .success(let value):
            self.delegate?.manager(didGet: value.hours)
          case .failure(let error):
            print("Error: \(error)")
          }
        }
    }
  }

  // MARK: Private

  private var cache: [String: WeatherCache] = [:]

}

// MARK: - WeatherDelegate

protocol WeatherDelegate: AnyObject {

  func manager(didGet weatherData: [WeatherHour])

}
