//
//  Location.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/16.
//

import Foundation

struct Location: Codable, Identifiable {

  var id: String { "\(latitude)," + "\(longitude)" }
  let name: String
  let latitude: Double
  let longitude: Double
  var weather: [WeatherHour]?
}
