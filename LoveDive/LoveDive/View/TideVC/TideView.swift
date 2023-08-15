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
  @StateObject var seaLevelModel = SeaLevelModel(networkRequest: AlamofireNetwork.shared)
  @StateObject var weatherDataModel = WeatherDataModel()
  @StateObject var favorites = Favorites()
  @State var seaLevel: [SeaLevel]
  @State var weatherData: [WeatherHour]
  @State var location: Location?
  @State var viewSize: CGFloat = 0.0
  @State var viewHeight: CGFloat = 0.0
  @State private var selectedElement: SeaLevel?
  @State private var currentElement: SeaLevel?
  @State private var plotWidth: CGFloat = 0.0
  @State var scrollSpot = ""
  @State private var tabBarHeight: CGFloat = 0.0

  var chartColor: Color = .pacificBlue.opacity(0.3)

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        LinearGradient(gradient: Gradient(colors: colorsForCurrentTime()), startPoint: .topLeading, endPoint: .bottomTrailing)
        VStack {
          Spacer()
          Rectangle() // Transparent TabBar
            .fill(.clear)
            .background(Blur(radius: 50, opaque: true))
            .background(.white.opacity(0.05))
            .frame(height: tabBarHeight + 15, alignment: .bottom)
            .cornerRadius(30)
        }
        VStack {
          if let location {
            Text(location.name)
              .font(.system(size: 25, weight: .semibold, design: .rounded))
              .foregroundColor(.white)
              .padding(.vertical, viewHeight / 10)
          }
          titleView
            .background(Blur(radius: 50, opaque: true))
            .background(.white.opacity(0.05))
            .cornerRadius(20)
            .padding(.top, -10)

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
              .padding(.horizontal, -50)
              .frame(width: viewSize / 12 * CGFloat(seaLevel.count))
              .onAppear {
                viewSize = proxy.size.width
                viewHeight = proxy.size.height
                fetchSeaLevelData()
                setTabBar()
              }
              .onDisappear {
                deSetTabBar()
              }
            }
            .onChange(of: currentElement, perform: { _ in
              scrollPosition.scrollTo(currentElement?.time, anchor: .center)
            })
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
          .padding(.vertical, viewHeight / 6)
        }
      }
      .onChange(of: seaLevelModel.seaLevel, perform: { newValue in
        seaLevel = newValue
        getCurrentElement()
      })
      .onChange(of: weatherDataModel.weatherData, perform: { newValue in
        weatherData = newValue

      })
      .onChange(of: selectedElement, perform: { _ in
        generateHapticFeedback(for: HapticFeedback.selection)
      })
      .ignoresSafeArea()
    }
    .ignoresSafeArea()
    .environmentObject(favorites)
    .navigationBarItems(trailing: heartView)
  }

  var heartView: some View {
    Button {
      withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
        favorites.contains(location!) ? favorites.remove(location!) : favorites.add(location!)
      }
    } label: {
      Image(systemName: favorites.contains(location!) ? "heart.fill" : "heart")
        .font(.system(size: 14, weight: .medium))
        .foregroundColor(.white)
        .padding(8)
        .background(.ultraThinMaterial.opacity(0.4), in: Circle())
    }
  }

  var titleView: some View {
    VStack {
      VStack {
        VStack {
          if let currentElement {
            let date = Formatter.dateFormatter.date(from: currentElement.time)
            if let date {
              Text(date.formatted(date: .abbreviated, time: .omitted))
                .foregroundColor(.white)
                .font(.system(.title, design: .rounded, weight: .regular))
            }
          }
        }
        .padding(.top, -30)
        .frame(width: 250, height: 10)
        Text(weatherData.first?.waveHeight.average ?? "0")
          .foregroundColor(.white)
          .font(.system(size: 40, weight: .bold, design: .rounded))
          .frame(width: 160, height: 80)
          .padding(.top, -10)
        Text("Wave Height")
          .foregroundColor(.white)
          .font(.system(.title3, design: .rounded, weight: .regular))
          .frame(width: 200, height: 20)
      }
      .frame(width: viewSize / 2, height: viewHeight / 3.4, alignment: .center)
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
        .foregroundStyle(gradient.opacity(0.7))
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

      if
        let selectedElement,
        let selectedDate = Formatter.dateFormatter.date(from: selectedElement.time),
        selectedElement.id == tideHour.id
      {
        BarMark(
          x: .value("time", selectedElement.time),
          yStart: .value("seaLevel", selectedElement.sg),
          yEnd: .value("BPM Max", maxHeight * 1.05),
          width: .fixed(2.5))
          .clipShape(Rectangle())
          .foregroundStyle(gradient)
          .annotation(position: .top) {
            VStack {
              Text(String(format: "%.2f", selectedElement.sg) + " m")
                .font(.system(size: 16, design: .rounded))
                .bold()
                .foregroundColor(.pacificBlue)

              Text(Formatter.dateFormatter.string(from: selectedDate))
                .font(.footnote)
                .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
          }

        PointMark(
          x: .value("time", selectedElement.time),
          y: .value("seaLevel", selectedElement.sg))
          .symbolSize(CGSize(width: 10, height: 10))
          .foregroundStyle(Color.white)

        PointMark(
          x: .value("time", selectedElement.time),
          y: .value("seaLevel", selectedElement.sg))
          .symbolSize(CGSize(width: 5, height: 5))
          .foregroundStyle(Color.gray.gradient)
      }

      if let currentElement, currentElement.time == tideHour.time {
        PointMark(
          x: .value("time", currentElement.time),
          y: .value("seaLevel", currentElement.sg))
          .symbolSize(CGSize(width: 12, height: 12))
          .foregroundStyle(Color.white)

        PointMark(
          x: .value("time", currentElement.time),
          y: .value("seaLevel", currentElement.sg))
          .symbolSize(CGSize(width: 6, height: 6))
          .foregroundStyle(.red)
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
    weatherDataModel.getTenDaysWeatherData(lat: location.latitude, lng: location.longitude)
  }

  private func getCurrentElement() {
    if
      let currentItem = seaLevel.first(where: { tideHour in

        Formatter.utc.date(from: tideHour.time) == Date()
          .startOfHour()
      })
    {
      currentElement = currentItem
    }
  }

  private func setTabBar() {
    if
      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let tabBar = windowScene.windows.first(where: { $0.isKeyWindow })?
        .rootViewController as? UITabBarController
    {
      tabBar.tabBar.backgroundColor = UIColor.clear
      tabBar.tabBar.backgroundImage = UIImage()
      tabBar.tabBar.shadowImage = UIImage()
      tabBarHeight = tabBar.tabBar.frame.size.height
    }
  }

  private func deSetTabBar() {
    if
      let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
      let tabBar = windowScene.windows.first(where: { $0.isKeyWindow })?
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
    case 4..<6: // Dawn
      return [Color.darkBlue, Color.lightBlue]
    case 6..<11: // Morning
      return [Color.pacificBlue, Color(red: 0.91, green: 0.98, blue: 1)]
    case 11..<15: // Afternoon
      return [Color.pacificBlue, Color(red: 0.84, green: 0.95, blue: 0.88)]
    case 15..<17: // Sunset
      return [Color(red: 0.33, green: 0.38, blue: 0.55), Color(red: 1, green: 0.83, blue: 0.67)]
    case 17..<19:
      return [Color(red: 0.17, green: 0.26, blue: 0.44), Color(red: 0.33, green: 0.38, blue: 0.55)]
    case 19..<21:
      return [Color(red: 0.17, green: 0.26, blue: 0.44), Color(red: 0.18, green: 0.19, blue: 0.31)]
    case 21..<24: // Evening
      return [Color(red: 0.05, green: 0.05, blue: 0.13), Color(red: 0.17, green: 0.26, blue: 0.44)]
    default:
      return [Color(red: 0.17, green: 0.26, blue: 0.44), Color.black]
    }
  }

}

// MARK: - TideView_Previews

struct TideView_Previews: PreviewProvider {
  static var previews: some View {
    let seaLevelModel = SeaLevelModel(networkRequest: AlamofireNetwork.shared)
    let tideData = seaLevelModel.decodeJSON()
    let location = Location(name: "小大福漁港", latitude: 22.3348440, longitude: 120.3776006)
    TideView(seaLevel: tideData.data, weatherData: [], location: location)
  }
}
