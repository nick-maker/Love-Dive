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
  @StateObject var seaLevelModel: SeaLevelModel = .init()
  @State var seaLevel: [SeaLevel]
  @State var weatherData: [WeatherHour]
  @State var location: Location?
  @State var viewSize: CGFloat = 0.0
  @State private var selectedElement: SeaLevel?
  @State private var currentElement: SeaLevel?
  @State private var plotWidth: CGFloat = 0.0
  @State var scrollSpot = ""

  let dateFormatter = ISO8601DateFormatter()
  var chartColor: Color = .pacificBlue.opacity(0.5)

  let titleFormatter: DateFormatter = {
    let titleFormatter = DateFormatter()
    titleFormatter.dateFormat = "MMM dd"
    titleFormatter.locale = Locale.current
    return titleFormatter
  }()

  let timeFormatter: DateFormatter = {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "MMM dd, ha"
    timeFormatter.locale = Locale.current
    return timeFormatter
  }()

  var body: some View {
    
    GeometryReader { proxy in
      ZStack {
        LinearGradient(gradient: Gradient(colors: colorsForCurrentTime()), startPoint: .topLeading, endPoint: .bottomTrailing)
        VStack {
          if let location {
            Text(location.name)
              .font(.system(size: 25, weight: .semibold, design: .rounded))
              .foregroundColor(.white)
              .padding(.vertical, 100)
          }
//          Spacer(minLength: 200)
          titleView
            .background(Blur(radius: 50, opaque: true))
//            .background(.ultraThinMaterial)
            .background(.white.opacity(0.05))
            .cornerRadius(20)
          Spacer()
          ScrollViewReader { scrollPosition in
            ScrollView(.horizontal, showsIndicators: false) {
              ZStack {
                HStack(spacing: 0) {
                  ForEach(seaLevel) { tideHour in
                    Rectangle()
                      .fill(.clear)
                      .frame(maxWidth: .infinity, maxHeight: 0)
                      .id(tideHour.time)
                  }
                }
                chartView
              }
              .padding(.horizontal, -100)
              .padding(.bottom, 10)
              .frame(width: viewSize / 12 * CGFloat(seaLevel.count), height: 350)
              .onAppear {
                viewSize = proxy.size.width
                fetchSeaLevelData()
                setTabBar()

                scrollPosition.scrollTo(currentElement?.time, anchor: .center)
              }
              .onDisappear {
                deSetTabBar()
              }
            }
            .onChange(of: scrollSpot) { _ in
              withAnimation {
                scrollPosition.scrollTo(scrollSpot, anchor: .center)
                scrollSpot = ""
              }
            }
          }
        }
        // Back to now button
        VStack {
          Spacer()
          HStack {
            Spacer()
            Button(action: {
              if let currentElement {
                scrollSpot = currentElement.time
              }
            }, label: {
              Image(systemName: "clock.arrow.circlepath")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .offset(x: -1.5, y: 0)
                .frame(width: 40, height: 40)
                .padding(8)
                .foregroundColor(.lightBlue)
                .background(Color.gray.opacity(0.7))
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.lightBlue, lineWidth: 1.5))
                .opacity(0.8)
            })
            .padding(20)
          }
          .padding(.vertical, 80)
        }
      }
      .onChange(of: seaLevelModel.seaLevel, perform: { newValue in
        seaLevel = newValue
        getCurrentElement()
      })
      .onChange(of: seaLevelModel.weatherData, perform: { newValue in
        weatherData = newValue

      })
      .ignoresSafeArea()
    }
    .ignoresSafeArea()
  }

  var titleView: some View {
    VStack {
      VStack {
        VStack {
          if let currentElement {
            let date = dateFormatter.date(from: currentElement.time)
            if let date {
              Text(date.formatted(date: .abbreviated, time: .omitted))
                .foregroundColor(.white)
                .font(.title)
                .fontDesign(.rounded)
            }
          }
        }
        .padding(.top, -30)
        .frame(width: 250, height: 10)
        Text((weatherData.first?.waveHeight.average ?? "-") + " m")
          .foregroundColor(.white)
          .font(.system(size: 50, weight: .bold, design: .rounded))
          .frame(width: 200, height: 80)
          .padding(.top, -10)
        Text("Wave Height")
          .foregroundColor(.white)
          .font(.title3)
          .fontDesign(.rounded)
          .frame(width: 200, height: 20)
      }
      .frame(width: 200, height: 250, alignment: .center)
    }
  }

  var chartView: some View {
    let minHeight = seaLevel.min(by: { $0.sg < $1.sg })?.sg ?? 0
    let maxHeight = seaLevel.max(by: { $1.sg > $0.sg })?.sg ?? 0

    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let hour = calendar.component(.hour, from: Date())
    @State var positionForNewColor = CGFloat(hour) / 240

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
        .foregroundStyle(
          .linearGradient(
            Gradient(
              stops: [
                .init(color: .lightBlue, location: 0),
                .init(color: .lightBlue, location: positionForNewColor),
                .init(color: .pacificBlue, location: positionForNewColor),
                .init(color: .pacificBlue, location: 1),
              ]),
            startPoint: .leading,
            endPoint: .trailing))
        .interpolationMethod(.cardinal)

      if let currentElement, currentElement.time == tideHour.time {
        PointMark(
          x: .value("time", currentElement.time),
          y: .value("seaLevel", currentElement.sg))
          .symbolSize(CGSize(width: 12, height: 12))
          .foregroundStyle(Color.pacificBlue)

        PointMark(
          x: .value("time", currentElement.time),
          y: .value("seaLevel", currentElement.sg))
          .symbolSize(CGSize(width: 5, height: 5))
          .foregroundStyle(.white)
      }

      if let selectedElement, selectedElement.id == tideHour.id {
        BarMark(
          x: .value("time", selectedElement.time),
          yStart: .value("seaLevel", selectedElement.sg),
          yEnd: .value("BPM Max", maxHeight * 1.1),
          width: .fixed(2))
          .clipShape(Capsule())
          .foregroundStyle(gradient)
//          .offset(x: (plotWidth / CGFloat(seaLevel.count)) / 2)
          .annotation(position: .top) {
            VStack {
              Text(String(format: "%.2f", selectedElement.sg) + " m")
                .font(.system(size: 16, design: .rounded))
                .bold()
                .foregroundColor(.pacificBlue)

              Text(timeFormatter.string(from: dateFormatter.date(from: selectedElement.time)!))
                .font(.footnote)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
          }
      }
    }
    .chartOverlay { proxy in
      GeometryReader { _ in
        Rectangle().fill(.clear).contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { value in
                let location = value.location
                if let time: String = proxy.value(atX: location.x) {
                  if
                    let selectItem = seaLevel.first(where: { tideHour in
                      tideHour.time == time
                    })
                  {
                    selectedElement = selectItem
                    plotWidth = proxy.plotAreaSize.width
                  }
                }
              }
              .onEnded { _ in
                selectedElement = nil
              })
      }
    }
    .chartXAxis { }
    .chartYAxis { }
    .chartYScale(domain: minHeight * 2...maxHeight * 1.6)
    .accentColor(.pacificBlue)
  }

  // MARK: Private

  private let networkManager = NetworkManager()
  private var gradient: Gradient {
    var colors = [chartColor]

    colors.append(chartColor.opacity(0))

    return Gradient(colors: colors)
  }

  private func fetchSeaLevelData() {
    guard let location else {
      return
    }
    seaLevelModel.getTenDaysSeaLevel(lat: location.latitude, lng: location.longitude)
    seaLevelModel.getTenDaysWeatherData(lat: location.latitude, lng: location.longitude)
  }

  private func getCurrentElement() {
    if
      let currentItem = seaLevel.first(where: { tideHour in

        ISO8601DateFormatter().date(from: tideHour.time) == Date()
          .startOfHour() // "2023-07-04T16:00:00+00:00" //Date().ISO8601Format()
      })
    {
      currentElement = currentItem
    }
  }

  private func setTabBar() {
    if
      let tabBar = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
        .rootViewController as? UITabBarController
    {
      tabBar.tabBar.backgroundColor = UIColor.clear
      tabBar.tabBar.backgroundImage = UIImage()
      tabBar.tabBar.shadowImage = UIImage()
    }
  }

  private func deSetTabBar() {
    if
      let tabBar = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
        .rootViewController as? UITabBarController
    {
      tabBar.tabBar.backgroundColor = UIColor.systemBackground
      tabBar.tabBar.backgroundImage = UIImage().withRenderingMode(.alwaysOriginal)
      tabBar.tabBar.shadowImage = UIImage().withRenderingMode(.alwaysOriginal)
    }
  }

  private func colorsForCurrentTime() -> [Color] {
    let hour = Calendar.current.component(.hour, from: Date())
    switch hour {
    case 0..<6: // Dawn
      return [Color.darkBlue, Color.lightBlue]
    case 6..<11: // Morning
      return [Color.pacificBlue, Color(red: 0.91, green: 0.98, blue: 1)]
    case 11..<15: // Afternoon
      return [Color.pacificBlue, Color(red: 0.84, green: 0.95, blue: 0.88)]
    case 16..<18: // Sunset
      return [Color.darkBlue.opacity(0.7), Color.orange.opacity(0.3)]
    case 18..<24: // Evening
      return [Color.darkBlue, Color.purple.opacity(0.17)]
    default:
      return [Color.darkBlue, Color.lightBlue]
    }
  }

}

// MARK: - TideView_Previews

struct TideView_Previews: PreviewProvider {
  static var previews: some View {
    let networkManager = NetworkManager()
    let weatherData = networkManager.decodeJSON()
    let location = Location(name: "小大福漁港", latitude: 22.3348440, longitude: 120.3776006)
    TideView(seaLevel: weatherData.data, weatherData: [], location: location)
  }
}
