//
//  Location.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/16.
//

import Foundation

struct Location: Identifiable, Equatable {
  
  static func == (lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id
    && lhs.name == rhs.name
    && lhs.latitude == rhs.latitude
    && lhs.longitude == rhs.longitude
  }
  
  let id = UUID().uuidString
  let name: String
  let latitude: Double
  let longitude: Double
  var weather: [WeatherHour]?
}
