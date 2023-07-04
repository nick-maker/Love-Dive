//
//  TideView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/3.
//

import Charts
import MapKit
import SwiftUI
import UIKit

// MARK: - TideView

struct TideView: View {

  // MARK: Internal

  @State var seaLevel: [SeaLevel]
  @State var viewSize: CGFloat = 0.0
  @State private var selectedElement: SeaLevel?
  @State private var plotWidth: CGFloat = 0.0
  @Environment(\.colorScheme) var colorScheme
  let dateFormatter = ISO8601DateFormatter()
  var chartColor: Color = .pacificBlue.opacity(0.5)

//  static var timeFormatter: DateFormatter = {
//    let timeFormatter = DateFormatter()
//    timeFormatter.dateFormat = "hh:mm:ss a"
//    timeFormatter.locale = Locale.current
//    return timeFormatter
//  }()

  var body: some View {
    GeometryReader { proxy in
      VStack {
        Spacer()
        ScrollView(.horizontal, showsIndicators: false) {
          VStack {
            chart
          }
          .padding(.horizontal, -100)
          .padding(.bottom, 10)
          .frame(width: viewSize / 12 * CGFloat(seaLevel.count), height: 350)
          .onAppear {
            viewSize = proxy.size.width
            fetchWeatherData()
          }
          .onDisappear {
            if let tabBar = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController as? UITabBarController {
              tabBar.tabBar.backgroundColor = UIColor.systemBackground
              tabBar.tabBar.backgroundImage = UIImage().withRenderingMode(.alwaysOriginal)
              tabBar.tabBar.shadowImage = UIImage().withRenderingMode(.alwaysOriginal)
            }
          }
        }
      }
      .ignoresSafeArea()
    }
  }

  var chart: some View {

    let minHeight = seaLevel.min(by: { $0.sg < $1.sg })?.sg ?? 0
    let maxHeight = seaLevel.max(by: { $1.sg > $0.sg })?.sg ?? 0

    return Chart(seaLevel) { tideHour in

      AreaMark(
        x: .value("time", tideHour.time),
        yStart: .value("minValue", minHeight * 2.5),
        yEnd: .value("seaLevel", tideHour.sg))
      .foregroundStyle(gradient)
      .interpolationMethod(.cardinal)

      LineMark(
        x: .value("time", tideHour.time),
        y: .value("seaLevel", tideHour.sg))
      .lineStyle(.init(lineWidth: 3.5))
      .foregroundStyle(Color.pacificBlue.gradient)
      .interpolationMethod(.cardinal)

      if let selectedElement, selectedElement.id == tideHour.id {

        BarMark(
          x: .value("time", selectedElement.time),
          yStart: .value("seaLevel", selectedElement.sg ),
          yEnd: .value("BPM Max", maxHeight * 1.1 ),
          width: .fixed(2)
        )
        .clipShape(Capsule())
        .foregroundStyle(gradient)
        .offset(x: (plotWidth / CGFloat(seaLevel.count)) / 2)

        .annotation(position: .top) {
          VStack() {
            Text(String(selectedElement.sg) + " m")
              .font(.system(size: 16, design: .rounded))
              .bold()
              .foregroundColor(.pacificBlue)

            Text(dateFormatter.date(from: selectedElement.time)!.formatted())
              .font(.footnote)
          }
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
        }
      }
    }
    .chartOverlay { proxy in
      GeometryReader { geometry in
        Rectangle().fill(.clear).contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { value in
                let location = value.location
                if let time: String = proxy.value(atX: location.x) {
                  if let currentItem = seaLevel.first(where: { tideHour in
                    tideHour.time == time
                  }) {
                    self.selectedElement = currentItem
                    self.plotWidth = proxy.plotAreaSize.width
                  }
                }
              }
              .onEnded { value in
                self.selectedElement = nil
              }
          )
      }
    }
    .chartXAxis { }
    .chartYAxis { }
    .chartYScale(domain: minHeight * 2...maxHeight * 1.6)
    .accentColor(.pacificBlue)

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
      seaLevel = networkManager.decodeJSON().data
    }
  }

}

// MARK: - TideView_Previews

struct TideView_Previews: PreviewProvider {
  static var previews: some View {
    let networkManager = NetworkManager()
    let weatherData = networkManager.decodeJSON()

    TideView(seaLevel: weatherData.data)
  }
}
