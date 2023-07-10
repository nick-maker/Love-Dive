//
//  HomeViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/9.
//

import MapKit
import UIKit

// MARK: - HomeViewController

class HomeViewController: UIViewController {

  // MARK: Internal

  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(HomeCell.self, forCellWithReuseIdentifier: HomeCell.reuseIdentifier)
    collectionView.register(EmptyCell.self, forCellWithReuseIdentifier: EmptyCell.reuseIdentifier)
    collectionView.register(
      SectionHeader.self,
      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
      withReuseIdentifier: SectionHeader.reuseIdentifier)
    return collectionView
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
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
      let locationData = UserDefaults.standard.object(forKey: "AllLocation") as? Data,
      let locations = try? JSONDecoder().decode([Location].self, from: locationData)
    {
      allLocations = locations
      favoriteLocations = locations.filter(favorites.contains(_:))
    }
  }

  // MARK: Private

  private var favorites = Favorites()
  private let divingSiteManager = DivingSiteManager()
  private var allLocations: [Location] = []
  private var favoriteLocations: [Location] = []
  private let saveKey = "Favorites"

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func numberOfSections(in _: UICollectionView) -> Int {
    2
  }

  func collectionView(_: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    switch section {
    case 0:
      return favoriteLocations.isEmpty ? 1 : favoriteLocations.count
    case 1:
      return 0
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
        cell.locationLabel.text = favoriteLocations[indexPath.row].name
        cell.snapshot(lat: favoriteLocations[indexPath.row].latitude, lng: favoriteLocations[indexPath.row].longitude)
        return cell
      }
    case 1:
      guard
        let
          cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HomeCell.reuseIdentifier,
            for: indexPath) as? HomeCell
      else { fatalError("Cannot Down casting") }
      return cell
    default:
      guard
        let
          cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCell.reuseIdentifier, for: indexPath) as? HomeCell
      else { fatalError("Cannot Down casting") }
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
      if indexPath.section == 0 {
        headerView.text = "Favorites"
        headerView.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
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
        return AppLayouts.homeSection()
      default:
        return AppLayouts.homeSection()
      }
    }
    collectionView.setCollectionViewLayout(layout, animated: true)
  }

}
