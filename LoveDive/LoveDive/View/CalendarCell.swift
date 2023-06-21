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
    calendarView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
    calendarView.backgroundColor = .systemBackground

    contentView.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
      calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
      calendarView.topAnchor.constraint(equalTo: contentView.topAnchor),
      calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
    ])
  }

}
