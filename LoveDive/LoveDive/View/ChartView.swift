//
//  ChartView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/23.
//

import Charts
import PhotosUI
import SwiftUI

// MARK: - ChartView

struct ChartView: View {

  // MARK: Internal
  @StateObject var photosModel: PhotosPickerModel = .init()
  @State private var chartColor: Color = .pacificBlue.opacity(0.5)
  @State var selectedItems: [PhotosPickerItem] = []
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
  @State var viewSize = CGSize()
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
      List {
        chartListView
      }
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          viewSize = proxy.size
          generateSnapshot(viewSize: viewSize)
        }
      }
    }
    .navigationBarTitle("Diving Log", displayMode: .large)
    .navigationBarItems(
      trailing:
      HStack {
        PhotosPicker(selection: $photosModel.selectedPhoto, matching: .any(of: [.images])) {
          Image(systemName: "plus")
        }.onChange(of: photosModel.loadedImages) { _ in
          generateSnapshot(viewSize: viewSize)
        }
        ShareLink(
          item: generatedImage ?? Image(systemName: ""),
          preview: SharePreview("Diving Log", image: generatedImage ?? Image(systemName: "")))
      })
    .accentColor(Color.pacificBlue)
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
        pictureView
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

  var pictureView: some View {
    HStack {
      if !photosModel.loadedImages.isEmpty {
          ForEach(photosModel.loadedImages) { mediafile in
            mediafile.image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .padding()
          }
      }
    }
  }

  var snapshotView: some View {
    ZStack {
      chartListView
    }
    .padding()
    .background(.white)
    .cornerRadius(20)
  }

  struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
      ChartView(data: [
        DivingEntry(
          id: "CF4CF548-F700-4661-93BD-0409F768255D",
          time: Date(timeIntervalSince1970: 1641876992),
          depth: 3.163539853270894),
        DivingEntry(
          id: "788196D1-EF47-4B50-98BE-D738E1D3C51A",
          time: Date(timeIntervalSince1970: 1641876995),
          depth: 4.850410152151905),
        DivingEntry(
          id: "B0976BD3-13D3-4034-9F5A-675CF0BE53A7",
          time: Date(timeIntervalSince1970: 1641876998),
          depth: 6.67847192904102),
        DivingEntry(
          id: "A56ECAD6-A4F1-476C-A900-3D059E3CD78A",
          time: Date(timeIntervalSince1970: 1641877000),
          depth: 8.540038785210685),
        DivingEntry(
          id: "988AB2C1-0C6F-4990-B24E-78B2C8FA4950",
          time: Date(timeIntervalSince1970: 1641877003),
          depth: 10.406927951597517),
        DivingEntry(
          id: "D6B1FE3C-8C5A-49C3-A650-1402D8F15FCD",
          time: Date(timeIntervalSince1970: 1641877006),
          depth: 12.534566080449434),
        DivingEntry(
          id: "45E1849A-3D96-4DEB-9C97-9F89B0B5881A",
          time: Date(timeIntervalSince1970: 1641877008),
          depth: 14.450256056855576),
        DivingEntry(
          id: "E06E167F-5210-4E31-A7D2-C4F4A843BAC1",
          time: Date(timeIntervalSince1970: 1641877011),
          depth: 16.2924923555383),
        DivingEntry(
          id: "DEB35F8C-5BFD-4B9A-8DB0-371302402C59",
          time: Date(timeIntervalSince1970: 1641877014),
          depth: 18.01839750570824),
        DivingEntry(
          id: "3259AE18-B2DF-406F-B240-5FBFF98A22B5",
          time: Date(timeIntervalSince1970: 1641877016),
          depth: 19.708213456933578),
        DivingEntry(
          id: "9B01D403-0B9F-4792-A82F-E5ADC65E14C9",
          time: Date(timeIntervalSince1970: 1641877019),
          depth: 21.434338272529505),
        DivingEntry(
          id: "898E7330-F9BD-4AD3-B37E-3F2E786D58B1",
          time: Date(timeIntervalSince1970: 1641877022),
          depth: 23.196964159743764),
        DivingEntry(
          id: "7607A448-DB28-42A6-98ED-C10DAF74A7F1",
          time: Date(timeIntervalSince1970: 1641877024),
          depth: 24.932299668687715),
        DivingEntry(
          id: "D06F457A-8B31-45F4-8A1D-594DC25538A5",
          time: Date(timeIntervalSince1970: 1641877027),
          depth: 26.655901382793477),
        DivingEntry(
          id: "8900E782-4FCD-4915-9C88-B1B29F892D37",
          time: Date(timeIntervalSince1970: 1641877030),
          depth: 28.32607253293636),
        DivingEntry(
          id: "6275A3E2-C732-406E-A6E5-D2D3DF05CA9C",
          time: Date(timeIntervalSince1970: 1641877032),
          depth: 29.216263620843836),
        DivingEntry(
          id: "4CCDC992-553A-4EA0-B6B5-B1D04FD242C4",
          time: Date(timeIntervalSince1970: 1641877035),
          depth: 28.557694470097182),
        DivingEntry(
          id: "EE4380E7-38A1-40BF-93DC-32F654E612B4",
          time: Date(timeIntervalSince1970: 1641877038),
          depth: 27.584906131109545),
        DivingEntry(
          id: "679B5BBC-A164-4234-8C0B-B301C099C500",
          time: Date(timeIntervalSince1970: 1641877040),
          depth: 25.728303103385468),
        DivingEntry(
          id: "8F7D3DD3-CD60-4292-8919-8ACF8ADA8BB4",
          time: Date(timeIntervalSince1970: 1641877043),
          depth: 22.756031580703368),
        DivingEntry(
          id: "E7D73801-755F-4493-9FDD-C16F4CF44219",
          time: Date(timeIntervalSince1970: 1641877046),
          depth: 19.795069776550953),
        DivingEntry(
          id: "E1FC5D28-FC7D-4B7F-861A-A4997226C887",
          time: Date(timeIntervalSince1970: 1641877048),
          depth: 16.9247016551664),
        DivingEntry(
          id: "2CD286A3-64DB-49F8-BD74-6C10ED58B22D",
          time: Date(timeIntervalSince1970: 1641877051),
          depth: 14.190754916046448),
        DivingEntry(
          id: "BD2CF1FC-8421-4278-9F44-F2618A029EBC",
          time: Date(timeIntervalSince1970: 1641877054),
          depth: 11.898897050362025),
        DivingEntry(
          id: "97D2CAF9-DFDE-4718-B4BD-6106C48196E0",
          time: Date(timeIntervalSince1970: 1641877056),
          depth: 9.687148419717582),
        DivingEntry(
          id: "D473EDBE-70BC-4A1C-912A-9821B4CE0364",
          time: Date(timeIntervalSince1970: 1641877059),
          depth: 7.321031436414454),
        DivingEntry(
          id: "8F7F7B13-A160-4D95-ACF7-03F784B135AC",
          time: Date(timeIntervalSince1970: 1641877062),
          depth: 4.702942954959675),
        DivingEntry(
          id: "EC621261-1865-4607-BBC9-7B1399AFCFDC",
          time: Date(timeIntervalSince1970: 1641877064),
          depth: 2.1503216349938676),
      ])
    }
  }
}