//
//  ActivitiesViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import SwiftUI
import UIKit

// MARK: - ActivitiesViewController

class ActivitiesViewController: UIViewController, DiveCellDelegate {

  // MARK: Internal

  var divingLogs: [DivingLog] = []
  var temps: [Temperature] = []
  var averageTemp = 0.0
  var filteredDuration = 0.0
  var filteredMaxDepth = 0.0

  let healthKitManager = HealthKitManger()
  let calendarView = UICalendarView()
  var isSelected = false
  var selectedDateComponents: DateComponents?

  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
    collectionView.register(
      SectionHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: SectionHeader.reuseIdentifier)
    collectionView.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.reuseIdentifier)
    collectionView.register(DiveCell.self, forCellWithReuseIdentifier: DiveCell.reuseIdentifier)
    return collectionView
  }()

  var filteredDivingLogs: [DivingLog] = [] {
    didSet {
      filteredMaxDepth = filteredDivingLogs.max(by: { $0.maxDepth < $1.maxDepth })?.maxDepth ?? 0.0
      filteredDuration = filteredDivingLogs.reduce(0.0) { $0 + $1.duration }
    }
  }

  var filteredTemps: [Temperature] = [] {
    didSet {
      let sum = filteredTemps.reduce(0.0) { $0 + $1.temp }
      averageTemp = sum / Double(filteredTemps.count)
    }
  }

  var currentDateComponents: DateComponents? {
    didSet {
      filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.sizeToFit() // fix initially not large title
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.title = "Activities"
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar.prefersLargeTitles = true
    healthKitManager.delegate = self
    healthKitManager.requestHealthKitPermissions()
    setupCollectionView()
    configureCompositionalLayout()
    filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
  }

  func filterDivingLogs(forMonth month: Date) {
    let calendar = Calendar.current
    let targetMonth = calendar.component(.month, from: month)
    let targetYear = calendar.component(.year, from: month)

    // Filter divingLogs for the selected month and year.
    filteredDivingLogs = divingLogs.filter {
      let monthComponent = calendar.component(.month, from: $0.startTime)
      let yearComponent = calendar.component(.year, from: $0.startTime)
      return monthComponent == targetMonth && yearComponent == targetYear
    }

    filteredTemps = temps.filter {
      let monthComponent = calendar.component(.month, from: $0.start)
      let yearComponent = calendar.component(.year, from: $0.start)
      return monthComponent == targetMonth && yearComponent == targetYear
    }

    // Reload the collectionView with filteredDivingLogs.
    DispatchQueue.main.async {
      let sectionsToReload: IndexSet = [1, 2]
      self.collectionView.reloadSections(sectionsToReload)
    }
  }

  func setupCollectionView() {
    view.addSubview(collectionView)
    collectionView.backgroundColor = nil
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }

  // MARK: Private

  private func filterDivingLogs(forDay day: Date) {
    let calendar = Calendar.current
    let targetDay = calendar.component(.day, from: day)
    let targetMonth = calendar.component(.month, from: day)
    let targetYear = calendar.component(.year, from: day)

    filteredDivingLogs = divingLogs.filter {
      let dayComponent = calendar.component(.day, from: $0.startTime)
      let monthComponent = calendar.component(.month, from: $0.startTime)
      let yearComponent = calendar.component(.year, from: $0.startTime)
      return dayComponent == targetDay && monthComponent == targetMonth && yearComponent == targetYear
    }

    filteredTemps = temps.filter {
      let dayComponent = calendar.component(.day, from: $0.start)
      let monthComponent = calendar.component(.month, from: $0.start)
      let yearComponent = calendar.component(.year, from: $0.start)
      return dayComponent == targetDay && monthComponent == targetMonth && yearComponent == targetYear
    }

    DispatchQueue.main.async {
      let sectionsToReload: IndexSet = [1, 2]
      self.collectionView.reloadSections(sectionsToReload)
    }
  }

}

// MARK: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate

extension ActivitiesViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {

  func calendarView(_: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
    let calendar = Calendar.current

    let hasDivingData = divingLogs.contains {
      let logDateComponents = calendar.dateComponents([.year, .month, .day], from: $0.startTime)
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

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension ActivitiesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func numberOfSections(in _: UICollectionView) -> Int {
    3
  }

  func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 4
    default:
      return filteredDivingLogs.count
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      guard
        let
        cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: CalendarCell.reuseIdentifier,
          for: indexPath) as? CalendarCell
      else { fatalError("Cannot Down casting") }
      cell.calendarView.delegate = self
      let dateSelection = UICalendarSelectionSingleDate(delegate: self)
      cell.calendarView.selectionBehavior = dateSelection
      return cell

    case 1:
      guard
        let
        cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: SummaryCell.reuseIdentifier,
          for: indexPath) as? SummaryCell
      else { fatalError("Cannot Down casting") }
      let descriptionText = ["Max Depth", "Average Water Temp", "Duration", "Dive Counts"]
      var figureText = [String]()

      if filteredMaxDepth == 0 {
        figureText = ["0 m", "-", "0 min", String(filteredDivingLogs.count)]
      } else {
        figureText = [
          String(format: "%.2f m", filteredMaxDepth),
          String(format: "%.1f°C", averageTemp),
          filteredDuration.durationFormatter(),
          String(filteredDivingLogs.count),
        ]
      }

      cell.descriptionLabel.text = descriptionText[indexPath.row]
      cell.figureLabel.text = figureText[indexPath.row]
      return cell
    default:
      guard
        let
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiveCell.reuseIdentifier, for: indexPath) as? DiveCell
      else { fatalError("Cannot Down casting") }
      let divingLog = filteredDivingLogs[indexPath.row]
      let text = "\(String(format: "%.2f m", divingLog.maxDepth)) Free Diving"
      let attributedText = NSMutableAttributedString(string: text)
      attributedText.addAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], range: NSRange(location: 0, length: 7))

      cell.waterDepthLabel.attributedText = attributedText
      cell.dateLabel.text = divingLog.startTime.formatted()
      cell.delegate = self
      return cell
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath)
    -> UICollectionReusableView
  {
    switch kind {
    case UICollectionView.elementKindSectionHeader:
      guard
        let headerView = collectionView.dequeueReusableSupplementaryView(
          ofKind: kind,
          withReuseIdentifier: SectionHeader.reuseIdentifier,
          for: indexPath) as? SectionHeader else
      {
        fatalError("Cannot downcast to SectionHeader")
      }
      if indexPath.section == 1 {
        switch filteredDivingLogs.count {
        case 0:
          headerView.text = "No Diving Activities".uppercased()
        case 1:
          headerView.text = "SUMMARY FOR 1 DIVE"
        default:
          headerView.text = "SUMMARY FOR \(filteredDivingLogs.count) DIVES"
        }
      }
      return headerView
    default:
      return UICollectionReusableView()
    }
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 2 {
      let selectedData = filteredDivingLogs[indexPath.row]
      let selectedTemp = filteredTemps[indexPath.row]
      let chartView = ChartView(data: selectedData.session, maxDepth: selectedData.maxDepth, temp: selectedTemp.temp)
      let hostingController = UIHostingController(rootView: chartView)
      hostingController.title = "Diving Log"
      navigationController?.navigationBar.tintColor = .pacificBlue
      navigationController?.pushViewController(hostingController, animated: true)
    }
  }

  func cellLongPressEnded(_ cell: DiveCell) {
    guard let indexPath = collectionView.indexPath(for: cell) else { return }
    collectionView(collectionView, didSelectItemAt: indexPath)
  }

}

// MARK: Compositional Layout

extension ActivitiesViewController {

  func configureCompositionalLayout() {
    let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
      switch sectionIndex {
      case 0:
        return AppLayouts.calendarSection()
      case 1:
        return AppLayouts.summarySection()
      default:
        return AppLayouts.diveListSection()
      }
    }
    collectionView.setCollectionViewLayout(layout, animated: true)
  }
}

// MARK: HealthManagerDelegate

extension ActivitiesViewController: HealthManagerDelegate {

  func getDepthData(didGet divingData: [DivingLog]) {
    divingLogs = divingData
  }

  func getTempData(didGet tempData: [Temperature]) {
    temps = tempData
  }

}

// MARK: TabBarReselectHandling

extension ActivitiesViewController: TabBarReselectHandling {

  func handleReselect() {
    if collectionView.numberOfItems(inSection: 0) > 0 {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
    }
//    
//    else {
//      collectionView.setContentOffset(CGPoint(x: 0, y: -143), animated: true)
//    }
  }

}
