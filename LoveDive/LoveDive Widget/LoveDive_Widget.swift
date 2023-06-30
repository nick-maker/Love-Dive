//
//  LoveDive_Widget.swift
//  LoveDive Widget
//
//  Created by Nick Liu on 2023/6/29.
//

import SwiftUI
import WidgetKit

// MARK: - Provider

struct Provider: TimelineProvider {
  func placeholder(in _: Context) -> SimpleEntry {
    SimpleEntry(date: Date())
  }

  func getSnapshot(in _: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date())
    completion(entry)
  }

  func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    var entries: [SimpleEntry] = []

    // Generate a timeline consisting of five entries an hour apart, starting from the current date.
    let currentDate = Date()
    for hourOffset in 0 ..< 5 {
      let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
      let entry = SimpleEntry(date: entryDate)
      entries.append(entry)
    }

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

// MARK: - SimpleEntry

struct SimpleEntry: TimelineEntry {
  let date: Date
}

// MARK: - LoveDive_WidgetEntryView

struct LoveDive_WidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    Text(entry.date, style: .time)
  }
}

// MARK: - LoveDive_Widget

struct LoveDive_Widget: Widget {
  let kind = "LoveDive_Widget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      LoveDive_WidgetEntryView(entry: entry)
    }
    .configurationDisplayName("My Widget")
    .description("This is an example widget.")
  }
}

// MARK: - LoveDive_Widget_Previews

struct LoveDive_Widget_Previews: PreviewProvider {
  static var previews: some View {
    LoveDive_WidgetEntryView(entry: SimpleEntry(date: Date()))
      .previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
