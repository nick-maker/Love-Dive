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

  static var timeFormatter: DateFormatter = {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm:ss a"
    timeFormatter.locale = Locale.current
    return timeFormatter
  }()

  static var yearFormatter: DateFormatter = {
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "YYYY/MM/DD"
    yearFormatter.locale = Locale.current
    return yearFormatter
  }()

  @StateObject var photosModel: PhotosPickerModel = .init()
  @State var data: [DivingEntry]
  @State private var selectedElement: DivingEntry?
  @State var viewSize = CGSize()
  @State var generatedImage: Image?
  @State var showingPlaceholder = false
  @State private var plotWidth: CGFloat = 0.0
  @Namespace var namespace
  @State var show = false
  @State var savedImage: Image?
  @State var offset = CGSize()

  var chartColor: Color = .pacificBlue.opacity(0.5)
  var maxDepth = 0.0
  var temp = 0.0
  var imagePath: String?

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        ScrollView {
          content
        }
        .opacity(show ? 0 : 1)
        if show {
          VStack {
            PictureDetailView(namespace: namespace, show: $show, savedImage: $savedImage, viewSize: $viewSize)
          }
        }
      }
      .onChange(of: selectedElement, perform: { _ in
        generateHapticFeedback(for: HapticFeedback.selection)
      })
      .onAppear {
        viewSize = proxy.size
        showingEditSheet = false
        if checkIfImageExist() {
          showingPlaceholder = true // Show placeholder initially
          chartAnimation()
        } else {
          chartAnimation()
        }
      }
    }
    .navigationBarTitle("Diving Log", displayMode: .large)
    .navigationBarItems(
      trailing:
      HStack {
        PhotosPicker(selection: $photosModel.selectedPhoto, matching: .any(of: [.images])) {
          Image(systemName: "plus")
        }
        .onChange(of: photosModel.selectedPhoto) { newValue in
          if let newValue {
            photosModel.processPhoto(photo: newValue)
            photosModel.allImages.removeAll()
            photosModel.mainView = nil
          }
        }
        .onChange(of: photosModel.imageData) { _ in
          showingEditSheet = true
          loadFilter()
        }
        .onChange(of: photosModel.value, perform: { _ in
          photosModel.updateEffect()
        })
        .sheet(isPresented: $showingEditSheet) {
          editPhotoView
            .padding()
        }
        ShareLink(
          item: generatedImage ?? Image(uiImage: UIImage()),
          preview:
          SharePreview(
            "Diving Log",
            image: generatedImage ??
              Image(uiImage: UIImage()))) // fix the share icon only show after generatedImage is not nil
      }
      .opacity(show ? 0 : 1)
    )
    .accentColor(Color.pacificBlue)
  }

  var chartListView: some View {
    VStack(alignment: .leading) {
      titleFigureView
        .padding(.horizontal)
      HStack {
        Text("\(data[0].start, formatter: ChartView.timeFormatter)")
          .font(.system(size: 14))
        Spacer()
        if let lastDate = data.last?.start {
          Text("\(lastDate, formatter: ChartView.timeFormatter)")
            .font(.system(size: 14))
        }
      }
      .padding(.horizontal)
      chart
        .padding(.leading)
      if data.count < 2 {
        HStack {
          Spacer()
          Text("Not Enough Data for a Diagram")
            .foregroundColor(.secondary)
          Spacer()
        }
      }
    }
    .padding(.top)
    .padding(.horizontal)
  }

  var titleFigureView: some View {
    let duration = data.last?.start.timeIntervalSince(data.first?.start ?? Date())
    let selectDuration = selectedElement?.start.timeIntervalSince(data.first?.start ?? Date())

    return VStack(alignment: .leading) {
      HStack {
        Text("\(data[0].start, formatter: ChartView.yearFormatter)")
          .font(.system(size: 30, design: .rounded))
          .bold()
          .foregroundColor(.pacificBlue)
        Spacer()
        HStack(spacing: 2) {
          Image(systemName: "thermometer.and.liquid.waves")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.pacificBlue.opacity(0.8))
          Text("\(String(format: "%.1f°C", temp))")
            .bold()
            .font(.system(size: 12, design: .rounded))
            .foregroundColor(.secondary)
        }
      }
      .padding(.bottom, 4)
      HStack(spacing: 30) {
        VStack(alignment: .leading) {
          Text(
            (selectedElement != nil)
              ? "\(String(format: "%.2f", selectedElement?.depth ?? 0)) m"
              : "\(String(format: "%.2f", maxDepth)) m")
            .bold()
            .font(.system(size: 26, design: .rounded))
            .padding(.bottom, 1)
          Text((selectedElement != nil) ? "Depth" : "Max Depth")
            .font(.system(size: 16, design: .rounded))
            .foregroundColor(.secondary)
        }
        VStack(alignment: .leading) {
          Text(
            (selectedElement != nil)
              ? "\(selectDuration?.durationFormatter() ?? "-")"
              : "\(duration?.durationFormatter() ?? "-")")
            .bold()
            .font(.system(size: 26, design: .rounded))
            .padding(.bottom, 1)
          Text("Duration")
            .font(.system(size: 16, design: .rounded))
            .foregroundColor(.secondary)
        }
        Spacer()
      }
    }
    .padding(.bottom, 30)
  }

  var editPhotoView: some View {
    VStack {
      if let mainView = photosModel.mainView {
        ZStack {
          Color.clear
            .frame(height: viewSize.height * 0.65)
          Image(uiImage: mainView.image)
            .resizable()
            .frame(maxWidth: .infinity)
            .aspectRatio(contentMode: .fit)
            .clipped()
            .cornerRadius(20)
        }
        .frame(alignment: .top)
        .cornerRadius(20)
        .padding(.vertical)

        Slider(value: $photosModel.value)
          .padding()
          .opacity(mainView.isEditable ? 1 : 0)
          .disabled(mainView.isEditable ? false : true)

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(photosModel.allImages) { filtered in
              ZStack {
                Color.paleGray.opacity(0.2)
                  .frame(width: 100, height: 130, alignment: .bottom)
                VStack(spacing: 0) {
                  Image(uiImage: filtered.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .onTapGesture {
                      photosModel.value = 1
                      photosModel.mainView = filtered
                    }
                  Text(filtered.filterName)
                    .frame(width: 100, height: 30)
                    .fontWeight(.light)
                    .font(.footnote)
                }
              }
              .cornerRadius(10)
            }
          }
        }
        .frame(alignment: .bottom)

        Button {
          showingEditSheet = false
          if let filePath = data.first?.start.description {
            photosModel.saveImageToDocumentsDirectory(image: mainView.image, filePath: filePath)
            showingPlaceholder = true
            loadImage()
            generateSnapshot(viewSize: viewSize)
          }
        } label: {
          Text("Confirm")
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 100)
            .background {
              Capsule()
                .fill(Color.pacificBlue)
            }
        }
        .padding(.top, 20)
        .frame(alignment: .bottom)
      }
    }
    .padding()
    .accentColor(.pacificBlue)
    .onDisappear {
      // Reset the sheet presentation state when the sheet is dismissed
      showingEditSheet = false
    }
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
          x: .value("time", divingEntry.start),
          yStart: .value("minValue", minValue),
          yEnd: .value("depth", divingEntry.animate ? -divingEntry.depth : minValue))
          .foregroundStyle(gradient)
          .interpolationMethod(.monotone)

        LineMark(
          x: .value("time", divingEntry.start),
          y: .value("depth", divingEntry.animate ? -divingEntry.depth : minValue))
          .interpolationMethod(.monotone)
          .lineStyle(.init(lineWidth: 3))
          .foregroundStyle(Color.pacificBlue.gradient)

        if let selectedElement, selectedElement.start == divingEntry.start {
          BarMark(
            x: .value("time", selectedElement.start),
            yStart: .value("depth", -selectedElement.depth),
            yEnd: .value("endPoint", 0),
            width: .fixed(2.5))
            .clipShape(Rectangle())
            .foregroundStyle(gradient)

          PointMark(
            x: .value("time", selectedElement.start),
            y: .value("depth", -selectedElement.depth))
            .symbolSize(CGSize(width: 12, height: 12))
            .foregroundStyle(Color.pacificBlue)

          PointMark(
            x: .value("time", selectedElement.start),
            y: .value("depth", -selectedElement.depth))
            .symbolSize(CGSize(width: 5, height: 5))
            .foregroundStyle(.white)
        }
      }
      .chartOverlay { proxy in
        GeometryReader { _ in
          Rectangle().fill(.clear).contentShape(Rectangle())
            .gesture(
              DragGesture()
                .onChanged { value in
                  let location = value.location
                  if let time: Date = proxy.value(atX: location.x) {
                    let calendar = Calendar.current
                    let timeComponents = calendar.dateComponents([.minute, .second], from: time)
                    if
                      let selectItem = data.first(where: { divingEntry in
                        let divingEntryComponents = calendar.dateComponents([.minute, .second], from: divingEntry.start)
                        return divingEntryComponents == timeComponents
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
      .chartXAxis {
        AxisMarks(values: .automatic()) { _ in
          AxisGridLine()
          AxisTick()
          AxisValueLabel(format: .dateTime.minute().second())
            .font(.system(size: 10))
        }
      }
      .chartYAxis {
        AxisMarks {
          AxisGridLine()
          let value = $0.as(Int.self)!
          AxisValueLabel {
            Text("\(-value)m")
          }
        }
      }
      .chartYScale(domain: minValue...0)
      .frame(height: 200)
    }
  }

  var pictureView: some View {
    PictureView(namespace: namespace, show: $show, savedImage: $savedImage)
    .onChange(of: photosModel.hasSavedImage) { _ in
      imageKey = UUID() // Invalidate and refresh the view
    }
    .id(imageKey) // Assign the UUID to the view ID
    //    .tabViewStyle(.page)
  }

  var snapshotView: some View {
    VStack {
      if savedImage != nil {
        VStack {
          Spacer()
        }
        .frame(width: 340, height: 240)
        .background(
          savedImage?
            .resizable()
            .aspectRatio(contentMode: .fill)
        )
        .mask {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
        }
        chartListView
      } else {
        chartListView
      }
    }
    .padding(.vertical, 25)
    .background()
    .cornerRadius(20)
  }

  // MARK: Private

  @State private var showingEditSheet = false
  @State private var imageKey = UUID()

  private var gradient: Gradient {
    var colors = [chartColor]

    colors.append(chartColor.opacity(0.5))

    return Gradient(colors: colors)
  }

  @ViewBuilder
  private var content: some View {
    if showingPlaceholder {
      VStack {
        ZStack {
          RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.clear)
            .frame(width: 340, height: 240)
          if !show {
          ShimmerView() //not because of this matchedgeometryeffect shimmer
          pictureView
          }
        }
        .onTapGesture {
          withAnimation(.easeInOut) {
            show.toggle()
          }
        }
        .padding(.top)
        chartListView
      }
    } else {
      chartListView
    }
  }

  @MainActor
  private func generateSnapshot(viewSize: CGSize) {
    let renderer = ImageRenderer(content: snapshotView.frame(width: viewSize.width, alignment: .center))
    renderer.scale = UIScreen.main.scale

    if let image = renderer.uiImage {
      let image = Image(uiImage: image)
      generatedImage = image
    }
  }

  private func loadFilter() {
    photosModel.loadFilter()
  }

  private func checkIfImageExist() -> Bool {
    guard let filePath = data.first?.start.description else { return false }
    return photosModel.imageExistFromFileManager(filePath: filePath)
  }

  @MainActor
  private func loadImage() {
    let filePath = data.first?.start.description
    if let filePath {
      if let savedImage = photosModel.getImageFromFileManager(filePath: filePath) {
        self.savedImage = savedImage
      }
    }
  }

  @MainActor
  private func chartAnimation() {
    let group = DispatchGroup()
    for index in data.indices {
      group.enter()
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.01) {
        withAnimation(.interactiveSpring(response: 0.7, dampingFraction: 0.6, blendDuration: 0.8)) {
          data[index].animate = true
        }
        group.leave()
      }
    }
    group.notify(queue: .main) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
        loadImage()
        generateSnapshot(viewSize: viewSize)
      }
    }
  }

}

// MARK: - ChartView_Previews

struct ChartView_Previews: PreviewProvider {
  static var previews: some View {
    ChartView(data: [
      DivingEntry(
        id: "CF4CF548-F700-4661-93BD-0409F768255D",
        start: Date(timeIntervalSince1970: 1641876992),
        depth: 3.163539853270894, animate: false),
      DivingEntry(
        id: "788196D1-EF47-4B50-98BE-D738E1D3C51A",
        start: Date(timeIntervalSince1970: 1641876995),
        depth: 4.850410152151905, animate: false),
      DivingEntry(
        id: "B0976BD3-13D3-4034-9F5A-675CF0BE53A7",
        start: Date(timeIntervalSince1970: 1641876998),
        depth: 6.67847192904102, animate: false),
      DivingEntry(
        id: "A56ECAD6-A4F1-476C-A900-3D059E3CD78A",
        start: Date(timeIntervalSince1970: 1641877000),
        depth: 8.540038785210685, animate: false),
      DivingEntry(
        id: "988AB2C1-0C6F-4990-B24E-78B2C8FA4950",
        start: Date(timeIntervalSince1970: 1641877003),
        depth: 10.406927951597517, animate: false),
      DivingEntry(
        id: "D6B1FE3C-8C5A-49C3-A650-1402D8F15FCD",
        start: Date(timeIntervalSince1970: 1641877006),
        depth: 12.534566080449434, animate: false),
      DivingEntry(
        id: "45E1849A-3D96-4DEB-9C97-9F89B0B5881A",
        start: Date(timeIntervalSince1970: 1641877008),
        depth: 14.450256056855576, animate: false),
      DivingEntry(
        id: "E06E167F-5210-4E31-A7D2-C4F4A843BAC1",
        start: Date(timeIntervalSince1970: 1641877011),
        depth: 16.2924923555383, animate: false),
      DivingEntry(
        id: "DEB35F8C-5BFD-4B9A-8DB0-371302402C59",
        start: Date(timeIntervalSince1970: 1641877014),
        depth: 18.01839750570824, animate: false),
      DivingEntry(
        id: "3259AE18-B2DF-406F-B240-5FBFF98A22B5",
        start: Date(timeIntervalSince1970: 1641877016),
        depth: 19.708213456933578, animate: false),
      DivingEntry(
        id: "9B01D403-0B9F-4792-A82F-E5ADC65E14C9",
        start: Date(timeIntervalSince1970: 1641877019),
        depth: 21.434338272529505, animate: false),
      DivingEntry(
        id: "898E7330-F9BD-4AD3-B37E-3F2E786D58B1",
        start: Date(timeIntervalSince1970: 1641877022),
        depth: 23.196964159743764, animate: false),
      DivingEntry(
        id: "7607A448-DB28-42A6-98ED-C10DAF74A7F1",
        start: Date(timeIntervalSince1970: 1641877024),
        depth: 24.932299668687715, animate: false),
      DivingEntry(
        id: "D06F457A-8B31-45F4-8A1D-594DC25538A5",
        start: Date(timeIntervalSince1970: 1641877027),
        depth: 26.655901382793477, animate: false),
      DivingEntry(
        id: "8900E782-4FCD-4915-9C88-B1B29F892D37",
        start: Date(timeIntervalSince1970: 1641877030),
        depth: 28.32607253293636, animate: false),
      DivingEntry(
        id: "6275A3E2-C732-406E-A6E5-D2D3DF05CA9C",
        start: Date(timeIntervalSince1970: 1641877032),
        depth: 29.216263620843836, animate: false),
      DivingEntry(
        id: "4CCDC992-553A-4EA0-B6B5-B1D04FD242C4",
        start: Date(timeIntervalSince1970: 1641877035),
        depth: 28.557694470097182, animate: false),
      DivingEntry(
        id: "EE4380E7-38A1-40BF-93DC-32F654E612B4",
        start: Date(timeIntervalSince1970: 1641877038),
        depth: 27.584906131109545, animate: false),
      DivingEntry(
        id: "679B5BBC-A164-4234-8C0B-B301C099C500",
        start: Date(timeIntervalSince1970: 1641877040),
        depth: 25.728303103385468, animate: false),
      DivingEntry(
        id: "8F7D3DD3-CD60-4292-8919-8ACF8ADA8BB4",
        start: Date(timeIntervalSince1970: 1641877043),
        depth: 22.756031580703368, animate: false),
      DivingEntry(
        id: "E7D73801-755F-4493-9FDD-C16F4CF44219",
        start: Date(timeIntervalSince1970: 1641877046),
        depth: 19.795069776550953, animate: false),
      DivingEntry(
        id: "E1FC5D28-FC7D-4B7F-861A-A4997226C887",
        start: Date(timeIntervalSince1970: 1641877048),
        depth: 16.9247016551664, animate: false),
      DivingEntry(
        id: "2CD286A3-64DB-49F8-BD74-6C10ED58B22D",
        start: Date(timeIntervalSince1970: 1641877051),
        depth: 14.190754916046448, animate: false),
      DivingEntry(
        id: "BD2CF1FC-8421-4278-9F44-F2618A029EBC",
        start: Date(timeIntervalSince1970: 1641877054),
        depth: 11.898897050362025, animate: false),
      DivingEntry(
        id: "97D2CAF9-DFDE-4718-B4BD-6106C48196E0",
        start: Date(timeIntervalSince1970: 1641877056),
        depth: 9.687148419717582, animate: false),
      DivingEntry(
        id: "D473EDBE-70BC-4A1C-912A-9821B4CE0364",
        start: Date(timeIntervalSince1970: 1641877059),
        depth: 7.321031436414454, animate: false),
      DivingEntry(
        id: "8F7F7B13-A160-4D95-ACF7-03F784B135AC",
        start: Date(timeIntervalSince1970: 1641877062),
        depth: 4.702942954959675, animate: false),
      DivingEntry(
        id: "EC621261-1865-4607-BBC9-7B1399AFCFDC",
        start: Date(timeIntervalSince1970: 1641877064),
        depth: 2.1503216349938676, animate: false),
    ], showingPlaceholder: true, show: false, savedImage: Image("S__31916048"))
  }
}
