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
  var filteredDivingLogs: [DivingLog] = []
  let calendarView = UICalendarView()
  var isSelected = false
  var selectedDateComponents: DateComponents?
  let descriptionText = ["Duration", "Active Energy", "Distance", "Dive Count"]

  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
    collectionView.register(SummaryCell.self, forCellWithReuseIdentifier: SummaryCell.reuseIdentifier)
    collectionView.register(DiveCell.self, forCellWithReuseIdentifier: DiveCell.reuseIdentifier)
    return collectionView
  }()

  var currentDateComponents: DateComponents? {
    didSet {
      filterDivingLogs(forMonth: currentDateComponents?.date ?? Date())
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.sizeToFit() //fix initially not large title
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    //    view.backgroundColor = UIColor.lightBlue
    navigationItem.title = "Activities"
    navigationController?.navigationBar.prefersLargeTitles = true
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
      let monthComponent = calendar.component(.month, from: $0.date)
      let yearComponent = calendar.component(.year, from: $0.date)
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
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
//    collectionView.contentInsetAdjustmentBehavior = .never
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
      let dayComponent = calendar.component(.day, from: $0.date)
      let monthComponent = calendar.component(.month, from: $0.date)
      let yearComponent = calendar.component(.year, from: $0.date)
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
      cell.descriptionLabel.text = descriptionText[indexPath.row]
      //      cell.figureLabel.text = ""
      return cell
    default:
      guard
        let
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: DiveCell.reuseIdentifier, for: indexPath) as? DiveCell
      else { fatalError("Cannot Down casting") }
      let divingLog = filteredDivingLogs[indexPath.row]
      cell.waterDepthLabel.text = String(format: "%.2f m", divingLog.maxDepth)
      cell.waterTempLabel.text = String(format: "%.1f°C", temps[indexPath.row].temp)
      return cell
    }
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 2 {
      let detailActViewController = DetailActViewController()
      detailActViewController.divingLog = filteredDivingLogs[indexPath.row]
      navigationController?.pushViewController(detailActViewController, animated: true)
    }
  }

}

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
    layout.register(SectionDecorationView.self, forDecorationViewOfKind: "SectionBackground")
    collectionView.setCollectionViewLayout(layout, animated: true)
  }
}
