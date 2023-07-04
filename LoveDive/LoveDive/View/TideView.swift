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

  @State var tideData: [SeaLevel]
  @State var viewSize: CGFloat = 0.0
  @State private var selectedElement: TideHour?
  let dateFormatter = ISO8601DateFormatter()
  var chartColor: Color = .pacificBlue.opacity(0.5)

  static var timeFormatter: DateFormatter = {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm:ss a"
    timeFormatter.locale = Locale.current
    return timeFormatter
  }()


  var body: some View {
    GeometryReader { proxy in
      VStack {
        Spacer()
        ScrollView(.horizontal, showsIndicators: false) {
          VStack {
            chart
          }
          .padding(.horizontal, -150)
          .frame(width: viewSize / 12 * CGFloat(tideData.count), height: 350)
          .onAppear {
            viewSize = proxy.size.width
            fetchWeatherData()
          }
        }
      }
      .ignoresSafeArea()
    }
  }

  var chart: some View {

    let minHeight = tideData.min(by: { $0.sg < $1.sg })?.sg ?? 0
    let maxHeight = tideData.max(by: { $1.sg > $0.sg })?.sg ?? 0

    return Chart(tideData) { tideHour in

      AreaMark(
        x: .value("time", tideHour.time),
        yStart: .value("minValue", minHeight * 2.5),
        yEnd: .value("depth", tideHour.sg))
      .foregroundStyle(gradient)
      .interpolationMethod(.cardinal)

      LineMark(
        x: .value("time", tideHour.time),
        y: .value("waveHeight", tideHour.sg))
      .lineStyle(.init(lineWidth: 3.5))
      .foregroundStyle(Color.pacificBlue.gradient)
      .interpolationMethod(.cardinal)
    }
    .chartOverlay { proxy in
      GeometryReader { geometry in
        Rectangle().fill(.clear).contentShape(Rectangle())
          .gesture(
            DragGesture()
              .onChanged { value in
                //                let origin = geometry[proxy.plotAreaFrame].origin
                //                let location = CGPoint(
                //                  x: value.location.x - origin.x,
                //                  y: value.location.y - origin.y
                //                )
                //                // Get the x (date) and y (price) value from the location.
                //                if let (time, height) = proxy.value(at: location, as: (String, Double).self) {
                //                  print("\(time) and \(height)")
                //                  selectedElement = TideHour(time: time, type: "", height: height)
                //                }
                let location = value.location
                if let time: String = proxy.value(atX: location.x) {
                  let timeDate = dateFormatter.date(from: time)!
                  let calendar = Calendar.current
                  let hour = calendar.component(.hour, from: timeDate)
                 
                  print(hour)
                }
              }
              .onEnded { value in

              }
          )
      }
    }
    .chartBackground { proxy in
      ZStack(alignment: .topLeading) {
        GeometryReader { geo in
          if let selectedElement = selectedElement {
            let dateInterval = Calendar.current.dateInterval(of: .minute, for: dateFormatter.date(from: selectedElement.time)!)!
            let startPositionX1 = proxy.position(forX: dateInterval.start) ?? 0
            let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
            let lineHeight = geo[proxy.plotAreaFrame].maxY
            let boxWidth: CGFloat = 250
            let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
            Rectangle()
              .fill(.red)
              .frame(width: 2, height: lineHeight)
              .position(x: 250, y: lineHeight / 2)

            VStack(alignment: .center) {
              Text("\(selectedElement.time)")
                .font(.callout)
                .foregroundStyle(.secondary)
            }
            .frame(width: boxWidth, alignment: .leading)
            .background {
              ZStack {
                RoundedRectangle(cornerRadius: 8)
                  .fill(.background)
                RoundedRectangle(cornerRadius: 8)
                  .fill(.quaternary.opacity(0.7))
              }
//              .padding(.horizontal, -8)
//              .padding(.vertical, -4)
            }
//            .offset(x: boxOffset)
          }
        }
      }
    }
    .chartYAxis { }
    .chartYScale(domain: minHeight * 2...maxHeight * 1.2)

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
      tideData = networkManager.decodeJSON().data
    }
  }

  //  private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> TideHour? {
  //      let relativeXPosition = location.x - geometry[proxy.plotAreaFrame].origin.x
  //    print(relativeXPosition)
  //      if let date = proxy.value(atX: relativeXPosition) as Date? {
  //          print("date is \(date)")
  //          var minDistance: TimeInterval = .infinity
  //          var index: Int? = nil
  //        for dataIndex in tideData.indices {
  //          if let tideDate = dateFormatter.date(from: tideData[dataIndex].time) {
  //            let nthTideDataDistance = tideDate.distance(to: date)
  //            if abs(nthTideDataDistance) < minDistance {
  //              minDistance = abs(nthTideDataDistance)
  //              index = dataIndex
  //            }
  //          }
  //        }
  //          if let index {
  //              return tideData[index]
  //          }
  //      }
  //    print("didn't find index")
  //      return nil
  //  }

}

// MARK: - TideView_Previews

struct TideView_Previews: PreviewProvider {
  static var previews: some View {
    let networkManager = NetworkManager()
    let weatherData = networkManager.decodeJSON()

    TideView(tideData: weatherData.data)
  }
}


