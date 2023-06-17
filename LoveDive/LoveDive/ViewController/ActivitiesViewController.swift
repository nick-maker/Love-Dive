//
//  ActivitiesViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import UIKit
import HorizonCalendar

class ActivitiesViewController: UIViewController {
  
  var divingDataLevels: [Date: DivingDataLevel] = [
    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -1, to: Date())!): .low,
    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -2, to: Date())!): .medium,
    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -3, to: Date())!): .high,
    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -4, to: Date())!): .low,
    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -5, to: Date())!): .medium,
    Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -6, to: Date())!): .high
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    setupCalendar()

  }

  private func setupCalendar() {
    let calendarView = CalendarView(initialContent: makeContent())
    view.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
    ])

    calendarView.scroll(
      toDayContaining: .now,
      scrollPosition: .firstFullyVisiblePosition,
      animated: false)
  }

  private func makeContent() -> CalendarViewContent {
    let calendar = Calendar.current
    // Get the start and end dates for the current month
    let startDate = calendar.date(from: DateComponents(year: 2000, month: 01, day: 01))!
    let endDate = calendar.date(from: DateComponents(year: 2100, month: 01, day: 01))!

    return CalendarViewContent(
      calendar: calendar,
      visibleDateRange: startDate...endDate,
      monthsLayout: .horizontal(options: HorizontalMonthsLayoutOptions()))

    .dayItemProvider { day in
      let calendar = Calendar.current
      var dateComponents = DateComponents()
      dateComponents.year = day.components.year
      dateComponents.month = day.components.month
      dateComponents.day = day.components.day
      guard let date = calendar.date(from: dateComponents) else { fatalError("Cannot convert day to date") }

      let hasDivingData = self.divingDataLevels[date] != nil
      return DayLabel.calendarItemModel(
        invariantViewProperties: .init(
          font: UIFont.systemFont(ofSize: 18),
          textColor: .black,
          backgroundColor: .pacificBlue),
        content: .init(day: day, hasDivingData: hasDivingData))
    }
    .verticalDayMargin(8)
    .horizontalDayMargin(8)

  }

}
