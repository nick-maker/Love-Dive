//
//  HomeViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/9.
//

import MapKit
import SwiftUI
import UIKit

// MARK: - HomeViewController

class HomeViewController: UIViewController {

  // MARK: Internal

  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
    collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
    collectionView.register(DiveCell.self, forCellWithReuseIdentifier: DiveCell.reuseIdentifier)
    collectionView.register(
      SectionHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: SectionHeader.reuseIdentifier)
    return collectionView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    healthKitManager.delegate = self
    setupNavigation()
    setupCollectionView()
    configureCompositionalLayout()
    getDivingSite()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateFavorites()
  }

  func updateFavorites() {
    let favorites = Set(UserDefaults.standard.stringArray(forKey: saveKey) ?? [])
    self.favorites.favorites = favorites
    favoriteLocations = allLocations.filter(self.favorites.contains(_:))
    collectionView.reloadData()
  }

  func setupNavigation() {
    navigationItem.title = "Home"
    navigationController?.navigationBar.tintColor = .pacificBlue
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar.prefersLargeTitles = true
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

  func getDivingSite() {
    if
      let locationData = UserDefaults.standard.object(forKey: "allLocation") as? Data,
      let locations = try? JSONDecoder().decode([Location].self, from: locationData)
    {
      allLocations = locations
      favoriteLocations = locations.filter(favorites.contains(_:))
    }
  }

  // MARK: Private
  private let healthKitManager = HealthKitManger()
  private var divingLogs: [DivingLog] = []
  private var temps: [Temperature] = []
  private let seaLevelModel = SeaLevelModel()
  private var favorites = Favorites()
  private let divingSiteManager = DivingSiteManager()
  private var allLocations: [Location] = []
  private var favoriteLocations: [Location] = []
  private let saveKey = "Favorites"

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  // MARK: Internal

  func numberOfSections(in _: UICollectionView) -> Int {
    2
  }

  func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return favoriteLocations.isEmpty ? 1 : favoriteLocations.count
    case 1:
      return 5
    default:
      return 0
    }
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch indexPath.section {
    case 0:
      if favoriteLocations.isEmpty {
        guard
          let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: EmptyCell.reuseIdentifier, for: indexPath) as? EmptyCell
        else { fatalError("Cannot Down casting") }
        cell.onExploreButtonTapped = { [weak self] in
          self?.tabBarController?.selectedIndex = 1
        }
        return cell
      } else {
        guard
          let
          cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeCell.reuseIdentifier,
            for: indexPath) as? HomeCell
        else { fatalError("Cannot Down casting") }
        let location = favoriteLocations[indexPath.row]
        cell.locationLabel.text = location.name
        cell.snapshot(lat: location.latitude, lng: location.longitude)
        cell.favoriteButton.isSelected = favorites.contains(location)
        cell.favoriteButton.tintColor = favorites.contains(location) ? .systemRed : .lightGray
        cell.favoriteButton.removeTarget(self, action: nil, for: .allEvents)
        cell.favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
        return cell
      }
    default:
      guard
        let
        cell = collectionView.dequeueReusableCell(
          withReuseIdentifier: DiveCell.reuseIdentifier,
          for: indexPath) as? DiveCell
      else { fatalError("Cannot Down casting") }

      return cell
    }
  }

  @objc
  func toggleFavorite(sender: UIButton) {
    let point = sender.convert(CGPoint.zero, to: collectionView)
    guard let indexPath = collectionView.indexPathForItem(at: point) else {
      return
    }
    let divingSite = favoriteLocations[indexPath.row]
    if !sender.isSelected {
      favorites.add(divingSite)
      sender.tintColor = .systemRed
    } else {
      favorites.remove(divingSite)
      sender.tintColor = .lightGray
      presentToast(title: "\(divingSite.name) is removed from favorites")
    }
    sender.isSelected = !sender.isSelected
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
      if indexPath.section == 0 {
        headerView.label.text = "Favorites"
        headerView.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
      } else if indexPath.section == 1 {
        headerView.label.text = "Personal Best Dives"
        headerView.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        headerView.captionLabel.text = "LAST 5 BEST ACTIVITIES"
        headerView.captionLabel.textColor = .secondaryLabel
        headerView.captionLabel.font = UIFont.systemFont(ofSize: 12)
      }
      return headerView
    default:
      return UICollectionReusableView()
    }
  }

  func configureCompositionalLayout() {
    let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
      switch sectionIndex {
      case 0:
        return AppLayouts.homeSection()
      case 1:
        return AppLayouts.homeDiveSection()
      default:
        return AppLayouts.homeSection()
      }
    }
    collectionView.setCollectionViewLayout(layout, animated: true)
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath.section == 0 && !favoriteLocations.isEmpty {
      let location = favoriteLocations[indexPath.row]
      let tideView = TideView(seaLevel: seaLevelModel.seaLevel, weatherData: [], location: location)
      let hostingController = UIHostingController(rootView: tideView)
      navigationController?.navigationBar.tintColor = .white
      navigationController?.pushViewController(hostingController, animated: true)
    }
  }

  // MARK: Private

  private func presentToast(title: String) {
    let toast = ToastViewController(title: title)
    present(toast, animated: true)
    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
      toast.dismiss(animated: true)
    }
  }
}

extension HomeViewController: HealthManagerDelegate {
  func getDepthData(didGet divingData: [DivingLog]) {
    divingLogs = divingData
  }

  func getTempData(didGet tempData: [Temperature]) {
    temps = tempData
  }
}
