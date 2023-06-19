//
//  ActivitiesViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

// import HealthKit
import UIKit

// MARK: - ActivitiesViewController

class ActivitiesViewController: UIViewController {

  // MARK: Internal

  var divingLogs: [DivingLog] = []
  var temps: [Temperature] = []
  var filteredDivingLogs: [DivingLog] = [] // Keep filtered diving logs
//  let healthStore = HKHealthStore()
  lazy var tableView = UITableView()
  let calendarView = UICalendarView()
  var isSelected = false
  var selectedDateComponents: DateComponents?

  var currentDateComponents: DateComponents? {
    didSet {
      filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.lightBlue
    setupCalendar()
    filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
    setupTableView()
  }

  func filterDivingLogs(forMonth month: Date) {
    let calendar = Calendar.current
    let targetMonth = calendar.component(.month, from: month)
    let targetYear = calendar.component(.year, from: month)

    // Filter divingLogs for the selected month and year.
    filteredDivingLogs = divingLogs.filter {
      let monthComponent = calendar.component(.month, from: $0.date)
      let yearComponent = calendar.component(.year, from: $0.date)
      return monthComponent == targetMonth && yearComponent == targetYear
    }

    // Reload the tableView with filteredDivingLogs.
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }

  func setupTableView() {
    tableView.register(DiveCell.self, forCellReuseIdentifier: DiveCell.reuseIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .lightBlue
    tableView.separatorStyle = .none
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 12),
      tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  // MARK: Private

  private func filterDivingLogs(forDay day: Date) {
    let calendar = Calendar.current
    let targetDay = calendar.component(.day, from: day)
    let targetMonth = calendar.component(.month, from: day)
    let targetYear = calendar.component(.year, from: day)

    // Filter divingLogs for the selected month and year.
    filteredDivingLogs = divingLogs.filter {
      let dayComponent = calendar.component(.day, from: $0.date)
      let monthComponent = calendar.component(.month, from: $0.date)
      let yearComponent = calendar.component(.year, from: $0.date)
      return dayComponent == targetDay && monthComponent == targetMonth && yearComponent == targetYear
    }

    // Reload the tableView with filteredDivingLogs.
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
  }

  private func setupCalendar() {
    calendarView.layer.cornerRadius = 20
    calendarView.calendar = .current
    calendarView.fontDesign = .rounded
    calendarView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    calendarView.backgroundColor = .systemBackground
    calendarView.delegate = self
    let dateSelection = UICalendarSelectionSingleDate(delegate: self)
    calendarView.selectionBehavior = dateSelection
    view.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      calendarView.heightAnchor.constraint(equalToConstant: 400),
    ])
  }

}

// MARK: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate

extension ActivitiesViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

  func calendarView(_: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
    let calendar = Calendar.current

    let hasDivingData = divingLogs.contains {
      let logDateComponents = calendar.dateComponents([.year, .month, .day], from: $0.date)
      return logDateComponents.year == dateComponents.year &&
        logDateComponents.month == dateComponents.month &&
        logDateComponents.day == dateComponents.day
    }

    if hasDivingData {
      return .customView {
        let barView = UIView()
        barView.backgroundColor = .pacificBlue
        barView.frame = CGRect(x: 0, y: 0, width: 30, height: 5)
        barView.layer.cornerRadius = 2.5
        return barView
      }
    } else {
      return nil
    }
  }

  func dateSelection(_: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
    if dateComponents == nil {
      isSelected = false
      filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
    } else {
      isSelected = true
      filterDivingLogs(forDay: dateComponents?.date ?? Date())
    }
  }

  func dateSelection(_: UICalendarSelectionSingleDate, canSelectDate _: DateComponents?) -> Bool {
    true
  }

  func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom _: DateComponents) {
    currentDateComponents = calendarView.visibleDateComponents
  }

}

// MARK: UITableViewDelegate, UITableViewDataSource

extension ActivitiesViewController: UITableViewDelegate, UITableViewDataSource {

  internal func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    filteredDivingLogs.count
  }

  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let
      cell = tableView.dequeueReusableCell(withIdentifier: DiveCell.reuseIdentifier, for: indexPath) as? DiveCell
    else { fatalError("Cannot Down casting") }
    let divingLog = filteredDivingLogs[indexPath.row]
    cell.selectionStyle = .none
    cell.waterDepthLabel.text = String(format: "%.2f m", divingLog.maxDepth)
    cell.waterTempLabel.text = String(format: "%.1f°C", temps[indexPath.row].temp)
    return cell
  }

  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let detailActViewController = DetailActViewController()
    detailActViewController.divingLog = filteredDivingLogs[indexPath.row]
    navigationController?.pushViewController(detailActViewController, animated: true)
  }

}
