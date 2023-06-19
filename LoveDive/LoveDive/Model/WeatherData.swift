//
//  WeatherData.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/16.
//

import Foundation

// MARK: - WeatherData

struct WeatherData: Decodable {
  let hours: [WeatherHour]
}

// MARK: - WeatherCache

struct WeatherCache {
  let timestamp: Date
  let weather: [WeatherHour]
}

// MARK: - WeatherHour

// Structure for each hour of data
struct WeatherHour: Decodable {
  let time: String
  let airTemperature: TemperatureData
  let waterTemperature: TemperatureData
  let waveHeight: WaveHeightData
  let windSpeed: WindSpeedData
}

// MARK: - TemperatureData

// Structure for temperature data
struct TemperatureData: Decodable {
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
struct WaveHeightData: Decodable {
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
struct WindSpeedData: Decodable {
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