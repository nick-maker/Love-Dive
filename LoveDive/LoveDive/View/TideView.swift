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

  //  let selectedAnnotaion: MKPointAnnotation?

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 4) {
        Chart(weatherData) { weatherHour in

          LineMark(
            x: .value("time", weatherHour.time),
            y: .value("waveHeight", weatherHour.waveHeight.average))
        }
        .padding(.horizontal)
      }
      .onAppear {
        fetchWeatherData()
      }
    }
  }

  // MARK: Private

  private let networkManager = NetworkManager()

  private func fetchWeatherData() {
      let networkManager = NetworkManager()
      weatherData = networkManager.decodeJSON().hours
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
