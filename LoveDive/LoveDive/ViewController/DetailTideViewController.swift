//
//  DetailViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/16.
//

import UIKit

class DetailTideViewController: UIViewController, UICalendarViewDelegate {

  let calendarView = UICalendarView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    setupUI()
    calendarView.delegate = self

  }

  func setupUI() {

    calendarView.calendar = .current
    calendarView.fontDesign = .rounded
    calendarView.locale = .current
//    calendarView.visibleDateComponents.month = 2
    view.addSubview(calendarView)
    calendarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      calendarView.topAnchor.constraint(equalTo: view.topAnchor),
      calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

    ])


  }

  func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
    let currentDateComponents = calendarView.visibleDateComponents
    print(currentDateComponents)
  }

}
