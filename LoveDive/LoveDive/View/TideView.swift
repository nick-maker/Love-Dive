//
//  TideView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/3.
//

import Charts
import MapKit
import SwiftUI

// MARK: - TideView

struct TideView: View {

  // MARK: Internal

  @State var weatherData: [WeatherHour]
  var chartColor: Color = .pacificBlue.opacity(0.5)

  var body: some View {
    VStack {
      Spacer()
      ScrollView(.horizontal, showsIndicators: false) {
        VStack {
          Chart(weatherData) { weatherHour in

            AreaMark(
              x: .value("time", weatherHour.time),
              y: .value("waveHeight", Double(weatherHour.waveHeight.average) ?? 0))
              .foregroundStyle(gradient)
              .interpolationMethod(.catmullRom)

            LineMark(
              x: .value("time", weatherHour.time),
              y: .value("waveHeight", Double(weatherHour.waveHeight.average) ?? 0))
              .lineStyle(.init(lineWidth: 5))
              .foregroundStyle(Color.pacificBlue.gradient)
              .interpolationMethod(.cardinal)
          }
          .padding(.horizontal, -25) // clip to the left
          .ignoresSafeArea()
          .chartYScale(domain: 0.5...1.2)
          .chartYAxis { }
          .chartXAxis { }
          .frame(width: 25 * CGFloat(weatherData.count), height: 500)
        }
        .onAppear {
          fetchWeatherData()
        }
      }
      .ignoresSafeArea()
    }
  }

  // MARK: Private

  private let networkManager = NetworkManager()

  //  let selectedAnnotaion: MKPointAnnotation?
  private var gradient: Gradient {
    var colors = [chartColor]

    colors.append(chartColor.opacity(0))

    return Gradient(colors: colors)
  }

  private func fetchWeatherData() {
    let networkManager = NetworkManager()
    DispatchQueue.main.async {
      weatherData = networkManager.decodeJSON().hours
      for weather in weatherData {
        print(weather.waveHeight.average)
      }
    }
  }

}

// MARK: - TideView_Previews

struct TideView_Previews: PreviewProvider {
  static var previews: some View {
    let networkManager = NetworkManager()
    let weatherData = networkManager.decodeJSON()

    TideView(weatherData: weatherData.hours)
  }
}
