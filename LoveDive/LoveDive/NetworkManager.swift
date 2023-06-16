//
//  NetworkManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import Alamofire
import Foundation

class NetworkManager {

  weak var delegate: WeatherDelegate?

  func getData(lat: Double, lng: Double) {
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
      "source": ["icon", "meteo", "noaa", "sg"]
    ]

    let headers: HTTPHeaders = [
      "Authorization": Config.weatherAPIKey,
    ]

    AF.request("https://api.stormglass.io/v2/weather/point", method: .get, parameters: params, headers: headers)
      .responseDecodable(of: WeatherData.self) { response in
        switch response.result {
        case .success(let value):
          self.delegate?.manager(didGet: value.hours)
//          print("JSON: \(value)")
        case .failure(let error):
          print("Error: \(error)")
        }
      }
  }

}

protocol WeatherDelegate: AnyObject {

  func manager(didGet: [WeatherHour])

}
