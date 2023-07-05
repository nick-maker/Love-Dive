//
//  WeatherData.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/16.
//

import Foundation

// MARK: - WeatherData

struct WeatherData: Codable {
  let hours: [WeatherHour]
}

// MARK: - WeatherCache

struct WeatherCache: Codable {
  let timestamp: String
  let weather: [WeatherHour]
}

// MARK: - WeatherHour

// Structure for each hour of data
struct WeatherHour: Codable, Identifiable {
  var id = UUID().uuidString
  let time: String
  let airTemperature: TemperatureData
  let waterTemperature: TemperatureData
  let waveHeight: WaveHeightData
  let windSpeed: WindSpeedData

  enum CodingKeys: String, CodingKey {
    case time
    case airTemperature
    case waterTemperature
    case waveHeight
    case windSpeed
  }
}

// MARK: - TemperatureData

// Structure for temperature data
struct TemperatureData: Codable {
  let noaa: Double?
  let sg: Double?
  let meto: Double?

  var average: String {
    let values = [noaa, sg, meto].compactMap { $0 }
    guard !values.isEmpty else { return "" }
    let average = values.reduce(0, +) / Double(values.count)
    return String(format: "%.2f", average)
  }
}

// MARK: - WaveHeightData

// Structure for wave height data
struct WaveHeightData: Codable {
  let icon: Double?
  let meteo: Double?
  let noaa: Double?
  let sg: Double?

  var average: String {
    let values = [icon, meteo, noaa, sg].compactMap { $0 }
    guard !values.isEmpty else { return "" }
    let average = values.reduce(0, +) / Double(values.count)
    return String(format: "%.2f", average)
  }
}

// MARK: - WindSpeedData

// Structure for wind speed data
struct WindSpeedData: Codable {
  let icon: Double?
  let noaa: Double?
  let sg: Double?

  var average: String {
    let values = [icon, noaa, sg].compactMap { $0 }
    guard !values.isEmpty else { return "" }
    let average = values.reduce(0, +) / Double(values.count)
    return String(format: "%.2f", average)
  }
}

// MARK: - TideData

struct TideData: Codable {
  let data: [SeaLevel]
}

// MARK: - TideHour

struct TideHour: Codable, Identifiable {
  var id = UUID().uuidString
  var time: String
  let type: String
  var height: Double

  enum CodingKeys: String, CodingKey {
    case time
    case type
    case height
  }
}

// MARK: - SeaLevel

struct SeaLevel: Codable, Identifiable {
  var id = UUID().uuidString
  var sg: Double
  var time: String

  enum CodingKeys: String, CodingKey {
    case sg
    case time
  }
}
