//
//  ActivitiesViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import HealthKit
import HorizonCalendar
import UIKit

class ActivitiesViewController: UIViewController {

  // MARK: Internal

  var divingLogs: [DivingLog] = []
  var tempDivingLogsByDate: [Date: (maxDepth: Double?, temperature: Double?, entries: [DivingEntry])] = [:]
  var queryCount = 0
  var filteredDivingLogs: [DivingLog] = [] // Keep filtered diving logs
  var currentDateComponents: DateComponents? {
    didSet {
      filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
    }
  }
  let healthStore = HKHealthStore()
  let tableView = UITableView()
  let calendarView = UICalendarView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.lightBlue
    setupCalendar()
    setupTableView()
    requestHealthKitPermissions()
    filterDivingLogs(forMonth: Date())
  }

  // MARK: Private

  private func setupCalendar() {

    calendarView.layer.cornerRadius = 20
    calendarView.calendar = .current
    calendarView.fontDesign = .rounded
    calendarView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
    calendarView.backgroundColor = .systemBackground
    calendarView.delegate = self
    let dateSelection = UICalendarSelectionSingleDate(delegate: self)
    calendarView.selectionBehavior = dateSelection
    view.addSubview(calendarView)

    calendarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
      calendarView.heightAnchor.constraint(equalToConstant: 350)
    ])

  }

  private func setupTableView() {
    tableView.register(DiveCell.self, forCellReuseIdentifier: DiveCell.reuseIdentifier)
    tableView.dataSource = self
    tableView.delegate = self
    tableView.backgroundColor = .clear
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 12),
      tableView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ])
  }

  private func requestHealthKitPermissions() {
    // Specify the data types you want to access
    guard
      let depthType = HKObjectType.quantityType(forIdentifier: .underwaterDepth),
      let temperatureType = HKObjectType.quantityType(forIdentifier: .waterTemperature) else
    {
      return
    }

    let readDataTypes: Set<HKObjectType> = [depthType, temperatureType]

    // Request access
    healthStore.requestAuthorization(toShare: nil, read: readDataTypes) { success, _ in
      if success {
        // Permissions granted
        self.queryHealthKitData(for: depthType)
        self.queryHealthKitData(for: temperatureType)
      } else {
        // Handle the error or permissions not granted
      }
    }
  }

  private func queryHealthKitData(for quantityType: HKQuantityType) {
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

    let query = HKSampleQuery(
      sampleType: quantityType,
      predicate: nil,
      limit: HKObjectQueryNoLimit,
      sortDescriptors: [sortDescriptor]) { _, results, _ in

        if let quantitySamples = results as? [HKQuantitySample] {
          for sample in quantitySamples {
            let startDate = Calendar.current.startOfDay(for: sample.startDate) // Get only the date part
            let time = sample.startDate

            var log = self.tempDivingLogsByDate[startDate] ?? (maxDepth: nil, temperature: nil, entries: [])

            switch quantityType {
            case HKObjectType.quantityType(forIdentifier: .underwaterDepth):
              let depthValue = sample.quantity.doubleValue(for: HKUnit.meter())
              log.entries.append(DivingEntry(time: time, depth: depthValue))
              log.maxDepth = max(log.maxDepth ?? 0, depthValue)

            case HKObjectType.quantityType(forIdentifier: .waterTemperature):
              let temperatureValue = sample.quantity.doubleValue(for: HKUnit.degreeCelsius())
              log.temperature = max(log.temperature ?? 0, temperatureValue)

            default:
              break
            }

            self.tempDivingLogsByDate[startDate] = log
          }
        }

        self.queryCount += 1
        if self.queryCount == 2 {
          self.combineTempLogsIntoDivingLogs()
          DispatchQueue.main.async {
            self.tableView.reloadData()
          }
        }
      }

    healthStore.execute(query)
  }

  private func combineTempLogsIntoDivingLogs() {
    var divingLogs: [DivingLog] = []

    for (date, log) in tempDivingLogsByDate {
      divingLogs.append(DivingLog(date: date, maxDepth: log.maxDepth ?? 0, temperature: log.temperature ?? 0, entries: log.entries))
    }
    self.divingLogs = divingLogs
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

}

extension ActivitiesViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

  func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
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

  func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
      print("Selected Date:", dateComponents)
  }


  func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
      return true
  }

  func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
    currentDateComponents = calendarView.visibleDateComponents

  }

}

extension ActivitiesViewController: UITableViewDelegate, UITableViewDataSource {

  internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    filteredDivingLogs.count
  }

  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let
            cell = tableView.dequeueReusableCell(withIdentifier: DiveCell.reuseIdentifier, for: indexPath) as? DiveCell
    else { fatalError("Cannot Down casting") }
    let divingLog = filteredDivingLogs[indexPath.row]
    cell.waterDepthLabel.text = String(format: "%.2f m", divingLog.maxDepth)
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let detailActViewController = DetailActViewController()
    detailActViewController.divingLog = filteredDivingLogs[indexPath.row]
    navigationController?.pushViewController(detailActViewController, animated: true)
  }

}
