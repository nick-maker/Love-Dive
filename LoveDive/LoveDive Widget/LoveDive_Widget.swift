//
//  LoveDive_Widget.swift
//  LoveDive Widget
//
//  Created by Nick Liu on 2023/6/29.
//

import Charts
import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: TimelineProvider {

  // MARK: Internal

  let defaults = UserDefaults(suiteName: "group.shared.LoveDive")

  func placeholder(in _: Context) -> PersonalBestEntry {
    PersonalBestEntry(date: Date(), divingLog: getPersonalBest())
  }

  func getSnapshot(in _: Context, completion: @escaping (PersonalBestEntry) -> Void) {
    let entry = PersonalBestEntry(date: Date(), divingLog: getPersonalBest())
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
    var entries: [PersonalBestEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = PersonalBestEntry(date: entryDate, divingLog: getPersonalBest())
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }

  func getPersonalBest() -> DivingLog? {
    if
      let defaults,
      let data = defaults.data(forKey: saveKey)
    {
      do {
        return try! JSONDecoder().decode(DivingLog.self, from: data)
      }
    }
    return nil
  }

  // MARK: Private

  private let saveKey = "personalBest"

}

// MARK: - PersonalBestEntry

struct PersonalBestEntry: TimelineEntry {
  let date: Date
  let divingLog: DivingLog?

}

// MARK: - WidgetView

struct WidgetView: View {

  @Environment(\.widgetFamily) var family: WidgetFamily
  
  var entry: Provider.Entry

  var body: some View {
    switch family {
    case .systemSmall:
      WidgetEntrySmallView(entry: entry)
        .widgetBackground(Color.clear)
    case .systemMedium:
      WidgetEntryMediumView(entry: entry)
        .widgetBackground(Color.clear)
    default:
      EmptyView()
    }
  }
}

// MARK: - WidgetEntrySmallView

struct WidgetEntrySmallView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack {
      Image(systemName: "trophy.circle")
        .foregroundColor(.pacificBlue)
        .font(.system(size: 40))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
      VStack(alignment: .leading) {
        Text("Personal Best")
          .font(.system(.title3, design: .rounded, weight: .regular))
          .bold()
          .foregroundColor(.pacificBlue)
        Text(String(format: "%.2f m", entry.divingLog?.maxDepth ?? 0))
          .font(.system(.title, design: .rounded, weight: .regular))
          .bold()
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
    .padding(14)
  }

}

// MARK: - WidgetEntryMediumView

struct WidgetEntryMediumView: View {

  // MARK: Internal

  var entry: Provider.Entry

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        VStack(alignment: .leading) {
          Text("Personal Best")
            .font(.system(.title3, design: .rounded, weight: .regular))
            .bold()
            .foregroundColor(.pacificBlue)
          Text(String(format: "%.2f m", entry.divingLog?.maxDepth ?? 0))
            .font(.system(.title3, design: .rounded, weight: .regular))
            .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 14)
        .padding(.leading, 16)

        VStack {
          Image(systemName: "trophy.circle")
            .foregroundColor(.pacificBlue)
            .font(.system(size: 30))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .frame(width: 60)
        }
        .padding(14)
      }
      if let divingLog = entry.divingLog {
        Chart(divingLog.session) { divingEntry in
          AreaMark(
            x: .value("time", divingEntry.start),
            yStart: .value("minValue", -divingEntry.depth),
            yEnd: .value("depth", -divingLog.maxDepth - 15))
            .foregroundStyle(WidgetEntryMediumView.gradient)
            .interpolationMethod(.monotone)

          LineMark(
            x: .value("time", divingEntry.start),
            y: .value("depth", -divingEntry.depth))
            .interpolationMethod(.monotone)
            .lineStyle(.init(lineWidth: 2))
            .foregroundStyle(Color.pacificBlue.gradient)
        }
        .chartXAxis { }
        .chartYAxis {
          AxisMarks(values: .automatic(desiredCount: 3)) {
            AxisGridLine()
            let value = $0.as(Int.self)!
            AxisValueLabel {
              Text("\(-value)")
            }
          }
        }
        .chartYScale(domain: -divingLog.maxDepth - 15...0)
        .padding(.leading, 18)
        .padding(.trailing, 12)
        .padding(.bottom, 14)
        .frame(height: 90)
      }
    }

  }

  // MARK: Private

  static private var gradient: Gradient {
    var colors = [Color.pacificBlue.opacity(0.5)]

    colors.append(Color.pacificBlue.opacity(0))

    return Gradient(colors: colors)
  }

}

// MARK: - LoveDive_Widget

struct LoveDive_Widget: Widget {

  let kind = "LoveDive_Widget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      WidgetView(entry: entry)
    }
    .configurationDisplayName("Personal Best Record")
    .supportedFamilies([.systemSmall, .systemMedium])
    .description("Show your personal best dive log.")
    .contentMarginsDisabled()
  }
}

// MARK: - Widget_Previews

struct Widget_Previews: PreviewProvider {

  static let divingLog = DivingLog(
    startTime: Date(timeIntervalSinceReferenceDate: 695100992.8668844),
    session: [
      DivingEntry(
        id: "7F8D8074-E1FA-458E-831E-96B4FA0FCA25",
        start: Date(timeIntervalSinceReferenceDate: 695100992.8668844),
        depth: 3.163539853270894,
        animate: false),
      DivingEntry(
        id: "A1BE4851-64AB-41EA-9B01-3855AF5D7938",
        start: Date(timeIntervalSinceReferenceDate: 695100995.491345),
        depth: 4.850410152151905,
        animate: false),
      DivingEntry(
        id: "123CA0BE-6856-4871-8B76-9E98AB494970",
        start: Date(timeIntervalSinceReferenceDate: 695100998.1587197),
        depth: 6.67847192904102,
        animate: false),
      DivingEntry(
        id: "BD16604C-BE3F-4956-BB1D-B54A91DA8CD8",
        start: Date(timeIntervalSinceReferenceDate: 695101000.8259571),
        depth: 8.540038785210685,
        animate: false),
      DivingEntry(
        id: "1C1CD89B-AAA0-49B8-A6FD-81E4E8D861C2",
        start: Date(timeIntervalSinceReferenceDate: 695101003.4932758),
        depth: 10.406927951597517,
        animate: false),
      DivingEntry(
        id: "606B7ED1-1184-494A-AD48-2529EF007C25",
        start: Date(timeIntervalSinceReferenceDate: 695101006.160494),
        depth: 12.534566080449434,
        animate: false),
      DivingEntry(
        id: "8934F96D-856C-445B-9AC5-2A25E3829659",
        start: Date(timeIntervalSinceReferenceDate: 695101008.8278686),
        depth: 14.450256056855576,
        animate: false),
      DivingEntry(
        id: "A7C68F98-B663-4E82-BAD1-941A40B55CB2",
        start: Date(timeIntervalSinceReferenceDate: 695101011.4951121),
        depth: 16.2924923555383,
        animate: false),
      DivingEntry(
        id: "5A587C25-EECF-44E8-B084-CBEAA88AB403",
        start: Date(timeIntervalSinceReferenceDate: 695101014.1623694),
        depth: 18.01839750570824,
        animate: false),
      DivingEntry(
        id: "19DA422A-A531-4D6D-86C5-200E7063E32E",
        start: Date(timeIntervalSinceReferenceDate: 695101016.8296472),
        depth: 19.708213456933578,
        animate: false),
      DivingEntry(
        id: "2D3702B7-5B2E-462E-B6F7-8D9676251BC1",
        start: Date(timeIntervalSinceReferenceDate: 695101019.4968431),
        depth: 21.434338272529505,
        animate: false),
      DivingEntry(
        id: "612FC6DE-32E3-4904-B338-8E02E5FC8444",
        start: Date(timeIntervalSinceReferenceDate: 695101022.1640297),
        depth: 23.196964159743764,
        animate: false),
      DivingEntry(
        id: "59298707-02D4-4C2B-8D2D-24455909B587",
        start: Date(timeIntervalSinceReferenceDate: 695101024.8311665),
        depth: 24.932299668687715,
        animate: false),
      DivingEntry(
        id: "68FA22C6-CFFA-4C3A-9E3D-D48A2AA9FC36",
        start: Date(timeIntervalSinceReferenceDate: 695101027.498261),
        depth: 26.655901382793477,
        animate: false),
      DivingEntry(
        id: "907326E0-DCE1-4AB4-848D-F090474B78AC",
        start: Date(timeIntervalSinceReferenceDate: 695101030.16535),
        depth: 28.32607253293636,
        animate: false),
      DivingEntry(
        id: "7DE16422-3EB0-411C-84CB-6F25B80EBD1D",
        start: Date(timeIntervalSinceReferenceDate: 695101032.8323481),
        depth: 29.216263620843836,
        animate: false),
      DivingEntry(
        id: "1C421A16-95DC-4C8C-BCF5-D94FA539CDCB",
        start: Date(timeIntervalSinceReferenceDate: 695101035.4993156),
        depth: 28.557694470097182,
        animate: false),
      DivingEntry(
        id: "69100FB0-5467-429C-8C8C-200A513BD4B9",
        start: Date(timeIntervalSinceReferenceDate: 695101038.1662941),
        depth: 27.584906131109545,
        animate: false),
      DivingEntry(
        id: "2B55DF61-AF41-4DF6-99B6-DAFA0BFA90E6",
        start: Date(timeIntervalSinceReferenceDate: 695101040.8332355),
        depth: 25.728303103385468,
        animate: false),
      DivingEntry(
        id: "7069C984-7694-409E-9CFF-601F47F68E1E",
        start: Date(timeIntervalSinceReferenceDate: 695101043.5003121),
        depth: 22.756031580703368,
        animate: false),
      DivingEntry(
        id: "0615C487-788F-4F5F-95D6-50F981F2A3C2",
        start: Date(timeIntervalSinceReferenceDate: 695101046.1674345),
        depth: 19.795069776550953,
        animate: false),
      DivingEntry(
        id: "4A0C219F-6A32-48CC-B3F0-2600DE696BCF",
        start: Date(timeIntervalSinceReferenceDate: 695101048.8345488),
        depth: 16.9247016551664,
        animate: false),
      DivingEntry(
        id: "4D9CC878-21AB-46C5-BD8E-892C97E8BE3B",
        start: Date(timeIntervalSinceReferenceDate: 695101051.5017447),
        depth: 14.190754916046448,
        animate: false),
      DivingEntry(
        id: "4D782690-B505-4AC0-B333-6BF32E3367CE",
        start: Date(timeIntervalSinceReferenceDate: 695101054.1688408),
        depth: 11.898897050362025,
        animate: false),
      DivingEntry(
        id: "799F0F88-AFE3-4AA7-966F-F9171EEF81DB",
        start: Date(timeIntervalSinceReferenceDate: 695101056.8359429),
        depth: 9.687148419717582,
        animate: false),
      DivingEntry(
        id: "EA73C336-9282-4184-B6A9-69C50E901D36",
        start: Date(timeIntervalSinceReferenceDate: 695101059.5030366),
        depth: 7.321031436414454,
        animate: false),
      DivingEntry(
        id: "FB0CCD98-6ACA-4B4E-97A7-E8C7BA8EBDE2",
        start: Date(timeIntervalSinceReferenceDate: 695101062.17012),
        depth: 4.702942954959675,
        animate: false),
      DivingEntry(
        id: "388A6324-C937-4318-8616-B8BEB209AF29",
        start: Date(timeIntervalSinceReferenceDate: 695101064.8371692),
        depth: 2.1503216349938676,
        animate: false),
    ])

  static var previews: some View {
    WidgetView(entry: PersonalBestEntry(date: Date(), divingLog: divingLog))
      .previewContext(WidgetPreviewContext(family: .systemMedium))
  }

}
