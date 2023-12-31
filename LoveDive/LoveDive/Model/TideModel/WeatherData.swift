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

struct WeatherHour: Codable, Identifiable, Equatable {

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

struct TemperatureData: Codable, Equatable {
  let noaa: Double?
  let sg: Double?
  let meto: Double?

  var average: String {
    let values = [noaa, sg, meto].compactMap { $0 }
    guard !values.isEmpty else { return "" }
    let average = values.reduce(0, +) / Double(values.count)
    return String(format: "%.1f°C", average)
  }
}

// MARK: - WaveHeightData

struct WaveHeightData: Codable, Equatable {
  let icon: Double?
  let meteo: Double?
  let noaa: Double?
  let sg: Double?

  var average: String {
    let values = [icon, meteo, noaa, sg].compactMap { $0 }
    guard !values.isEmpty else { return "" }
    let average = values.reduce(0, +) / Double(values.count)
    return String(format: "%.2f m", average)
  }
}

// MARK: - WindSpeedData


struct WindSpeedData: Codable, Equatable {
  let icon: Double?
  let noaa: Double?
  let sg: Double?

  var average: String {
    let values = [icon, noaa, sg].compactMap { $0 }
    guard !values.isEmpty else { return "" }
    let average = values.reduce(0, +) / Double(values.count)
    return String(format: "%.2f m/s", average)
  }
}

// MARK: - TideData

struct TideData: Codable {
  let data: [SeaLevel]
}

// MARK: - TideCache

struct TideCache: Codable {
  let timestamp: String
  let seaLevel: [SeaLevel]
}

// MARK: - SeaLevel

struct SeaLevel: Codable, Identifiable, Equatable {
  var time: String
  var sg: Double
  var id: String { "\(time)" }

  enum CodingKeys: String, CodingKey {
    case time
    case sg
  }
}
