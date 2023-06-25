//
//  ChartView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/23.
//

import Charts
import SwiftUI

// MARK: - ChartView

struct ChartView: View {

  // MARK: Internal

  @State private var chartColor: Color = .pacificBlue.opacity(0.5)

  @MainActor
  private func generateSnapshot(viewSize: CGSize) {
    let renderer = ImageRenderer(content: snapshotView.frame(width: viewSize.width, alignment: .center))
    renderer.scale = UIScreen.main.scale

    if let image = renderer.uiImage {
      generatedImage = Image(uiImage: image)
    }
  }

  var data: [DivingEntry]
  var maxDepth = 0.0
  var temp = 0.0
  @State var generatedImage: Image?

  private var gradient: Gradient {
    var colors = [chartColor]

    colors.append(chartColor.opacity(0.5))

    return Gradient(colors: colors)
  }

  static var timeFormatter: DateFormatter = {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm:ss a"
    timeFormatter.locale = Locale.current
    return timeFormatter
  }()

  static var yearFormatter: DateFormatter = {
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "MMM dd, yyyy"
    yearFormatter.locale = Locale.current
    return yearFormatter
  }()

  var body: some View {
    GeometryReader { proxy in
      let viewSize = proxy.size
      List {
        chartListView
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          generateSnapshot(viewSize: viewSize)
        }
      }
    }
    .navigationBarTitle("Diving Log", displayMode: .large)
    .navigationBarItems(
      trailing:
      ShareLink(
        item: generatedImage ?? Image(systemName: ""),
        preview: SharePreview("Diving Log", image: generatedImage ?? Image(systemName: ""))))
  }

  var chartListView: some View {
    ZStack(alignment: .topLeading) {
      VStack(alignment: .leading) {
        titleFigureView
        HStack {
          Text("\(data[0].time, formatter: ChartView.timeFormatter)")
            .font(.system(size: 14))
          Spacer()
          if let lastDate = data.last?.time {
            Text("\(lastDate, formatter: ChartView.timeFormatter)")
              .font(.system(size: 14))
          }
        }
        chart
        if data.count < 2 {
          HStack {
            Spacer()
            Text("Not Enough Data for a Diagram")
              .foregroundColor(.secondary)
            Spacer()
          }
        }
      }
    }
  }

  var titleFigureView: some View {
    let duration = data.last?.time.timeIntervalSince(data.first?.time ?? Date())

    return VStack(alignment: .leading) {
      Text("\(data[0].time, formatter: ChartView.yearFormatter)")
        .font(.system(size: 30, design: .rounded))
        .bold()
        .foregroundColor(.pacificBlue)
        .padding(.bottom, 4)
      HStack {
        VStack(alignment: .leading) {
          Text("\(String(format: "%.2f", maxDepth)) m")
            .bold()
            .font(.system(size: 24, design: .rounded))
            .padding(.bottom, 2)
          Text("Max Depth")
            .font(.system(size: 16, design: .rounded))
            .foregroundColor(.secondary)
        }
        Spacer()
        VStack(alignment: .leading) {
          Text("\(duration?.durationFormatter() ?? "-")")
            .bold()
            .font(.system(size: 24, design: .rounded))
            .padding(.bottom, 2)
          Text("Duration")
            .font(.system(size: 16, design: .rounded))
            .foregroundColor(.secondary)
        }
        Spacer()
        VStack(alignment: .leading) {
          Text("\(String(format: "%.1f°C", temp))")
            .bold()
            .font(.system(size: 24, design: .rounded))
            .padding(.bottom, 2)
          Text("Water Temp")
            .font(.system(size: 16, design: .rounded))
            .foregroundColor(.secondary)
        }
      }
    }
    .padding(.bottom, 30)
  }

  var chart: some View {
    let minDepth = data.min(by: { -$0.depth < -$1.depth })?.depth ?? 0
    var minValue = 0.0

    switch minDepth {
    case 10..<15:
      minValue = -round(ceil(minDepth / 10) * 7.5)
    case 0...5:
      minValue = -round((minDepth / 10 + 1) * 5)
    default:
      minValue = -round(ceil(minDepth / 10) * 10)
    }

    if minDepth + minValue < 2 {
      minValue -= 2
    }

    return VStack {
      Chart(data) { divingEntry in

        AreaMark(
          x: .value("time", divingEntry.time),
          yStart: .value("minValue", minValue),
          yEnd: .value("depth", -divingEntry.depth))
          .foregroundStyle(gradient)
          .interpolationMethod(.monotone)

        LineMark(
          x: .value("time", divingEntry.time),
          y: .value("depth", -divingEntry.depth))
          .interpolationMethod(.monotone)
          .lineStyle(.init(lineWidth: 3))
          .foregroundStyle(Color.pacificBlue.opacity(0.7))
      }
      .chartYScale(domain: minValue...0)
      .chartYAxis {
        AxisMarks {
          AxisGridLine()
          let value = $0.as(Int.self)!
          AxisValueLabel {
            Text("\(-value)m")
          }
        }
      }
      .chartXAxis {
        AxisMarks(values: .automatic()) { _ in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(format: .dateTime.minute().second())
            .font(.system(size: 10))
        }
      }
      .frame(height: 200)
    }
  }

  var snapshotView: some View {
    ZStack {
      chartListView
    }
    .padding()
    .background(.white)
    .cornerRadius(30)
  }

}
