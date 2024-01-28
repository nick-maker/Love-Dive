//
//  CalendarCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/21.
//

import UIKit

class CalendarCell: UICollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupCalendar()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(CalendarCell.self)"

  let calendarView = UICalendarView()

  // MARK: Private

  private func setupCalendar() {
    calendarView.layer.cornerRadius = 20
    calendarView.calendar = .current
    calendarView.fontDesign = .rounded
    calendarView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    calendarView.backgroundColor = .systemBackground

    let fromDateComponents = DateComponents(calendar: .current, year: 2022, month: 9, day: 7)
    let toDateComponents = DateComponents(calendar: .current, year: 2099, month: 9, day: 29)
    guard let fromDate = fromDateComponents.date, let toDate = toDateComponents.date else {
      return
    }
    let calendarViewDateRange = DateInterval(start: fromDate, end: toDate)
    calendarView.availableDateRange = calendarViewDateRange
    contentView.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      calendarView.topAnchor.constraint(equalTo: contentView.topAnchor),
      calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

}
