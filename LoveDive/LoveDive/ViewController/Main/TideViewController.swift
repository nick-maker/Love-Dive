//
//  ViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/14.
//

import MapKit
import SwiftUI
import UIKit

// MARK: - TideViewController

class TideViewController: UIViewController, MKMapViewDelegate {

  // MARK: Internal

  var mapView = MKMapView()
  let containerView = UIView()
  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(TideCell.self, forCellWithReuseIdentifier: TideCell.reuseIdentifier)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    return collectionView
  }() // Must be initialized with a non-nil layout parameter

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.tabBarController?.tabBar.backgroundColor = .systemBackground
    locationManager.errorPresentationTarget = self
//    divingSiteManager.delegate = self
    networkManager.currentDelegate = self

    setupMapView()
    getCurrentLocation()
    getDivingSite()
//    divingSiteManager.decodeDivingGeoJSON()
    setupCollectionView()
    configureCompositionalLayout()
  }

  private let saveKey = "Favorites"

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    updateFavorites()
  }

  func updateFavorites() {
    let favorites = Set(UserDefaults.standard.stringArray(forKey: saveKey) ?? [])
    self.favorites.favorites = favorites
    collectionView.reloadData()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    containerDownOffset = 140
    containerUp = containerView.center
    containerDown = CGPoint(x: containerView.center.x ,y: containerView.center.y + containerDownOffset)
  }

  func getDivingSite() {
    if
      let locationData = UserDefaults.standard.object(forKey: "AllLocation") as? Data,
      let locations = try? JSONDecoder().decode([Location].self, from: locationData)
    {
      self.locations = locations
      createAnnotation(locations: locations)
    }
  }

  func setupMapView() {
    mapView.showsCompass = true
    mapView.delegate = self
    mapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapView)

    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9),
    ])
  }

  func getCurrentLocation() {
    locationManager.getUserLocation { [weak self] location in
      guard let self else { return }
      DispatchQueue.main.async {
        let center = location.coordinate
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
      }
    }
  }

  func createAnnotation(locations: [Location]) {
    for location in locations {
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
      annotation.title = location.name
      mapView.addAnnotation(annotation)
      annotations.append(annotation)
      //      networkManager.getCurrentWeatherData(lat: annotation.coordinate.latitude, lng: annotation.coordinate.longitude, forAnnotation: annotation)
    }
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
    let visibleMapRect = mapView.visibleMapRect
    let visibleRegion = MKCoordinateRegion(visibleMapRect)

    currentRegion = visibleRegion.span
    let _: [String: Any] = [
      "southWestLat": visibleRegion.center.latitude - visibleRegion.span.latitudeDelta / 2,
      "northEastLat": visibleRegion.center.latitude + visibleRegion.span.latitudeDelta / 2,
      "southWestLng": visibleRegion.center.longitude - visibleRegion.span.longitudeDelta / 2,
      "northEastLng": visibleRegion.center.longitude + visibleRegion.span.longitudeDelta / 2,
    ]
    let visibleAnnotations = mapView.annotations(in: mapView.visibleMapRect)
    annotations = visibleAnnotations.compactMap { $0 as? MKPointAnnotation }
    visibleLocations = locations.filter { location in
      for annotation in annotations {
        if location.id == "\(annotation.coordinate.latitude.description)," + "\(annotation.coordinate.longitude.description)" {
          return true
        }
      }
      return false
    }

    updateWeatherDataForVisibleAnnotations()
    // Reload the collection view data
    DispatchQueue.main.async {
      self.collectionView.reloadData()
      guard let selectedLocation = self.selectedAnnotation?.coordinate else { return }
      guard
        let index = self.visibleLocations
          .firstIndex(where: { $0.id == "\(selectedLocation.latitude.description)," + "\(selectedLocation.longitude.description)"
          })
      else {
        return
      }
      let indexPath = IndexPath(item: index, section: 0)

      self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
  }

  // MARK: Private

//  private let divingSiteManager = DivingSiteManager()
  private let networkManager = NetworkManager()
  private let seaLevelModel = SeaLevelModel()
  private let locationManager = LocationManager()
  private var weatherData = [WeatherHour]()
  private var locations = [Location]()
  private var visibleLocations = [Location]()
  private var annotations: [MKPointAnnotation] = []
  private var selectedAnnotation: MKPointAnnotation?
  private var containerOriginalCenter = CGPoint.zero
  private var containerDownOffset = CGFloat()
  private var containerUp = CGPoint.zero
  private var containerDown = CGPoint.zero
  private var currentRegion = MKCoordinateSpan()
  private var favorites = Favorites()

//  private var currentPage: Int? = nil
  private var lastScaleFactor = CGFloat() // to determine if the scroll has ended

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension TideViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func configureCompositionalLayout() {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)

    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .absolute(130))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = NSDirectionalEdgeInsets(top: 50, leading: 10, bottom: 0, trailing: 0)
    section.orthogonalScrollingBehavior = .groupPagingCentered

    section.visibleItemsInvalidationHandler = { [weak self] items, offset, environment in
      guard let self else { return }

      let pageWidth: CGFloat = environment.container.contentSize.width * 0.75

      let centerOffsetX = offset.x + environment.container.contentSize.width / 2.0
      let currentPage = Int(centerOffsetX / pageWidth)

      // PLay with some animation and scrollOffest
      items.forEach { item in
        let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
        let minScale: CGFloat = 0.8
        let maxScale: CGFloat = 1.0
        let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)
        item.transform = CGAffineTransform(scaleX: scale, y: scale)

        if scale == 0.8, self.lastScaleFactor > 0.999 {
          // Scrolling has reached a stable state with the target item centered
          // Perform scrolling completion actions here
          let indexPath = IndexPath(row: currentPage, section: 0)
          guard let cell = self.collectionView.cellForItem(at: indexPath) as? TideCell else { return }

          // Get the corresponding annotation title
          let annotationTitle = cell.locationLabel.text

          // Find the annotation that matches the title
          guard let annotation = self.mapView.annotations.first(where: { $0.title == annotationTitle }) else { return }
          let region = MKCoordinateRegion(
            center: annotation.coordinate,
            span: self.currentRegion)
//          self.mapView.setRegion(region, animated: true) //might cause jiggling
          self.mapView.selectAnnotation(annotation, animated: true)
        }
        self.lastScaleFactor = scale
      }
    }
    collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
  }

  func setupCollectionView() {
    let handleView = UIView()
    let handleTriggerView = UIView()
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    handleTriggerView.addGestureRecognizer(panGesture)
    handleView.backgroundColor = UIColor { traits in
      if traits.userInterfaceStyle == .dark {
        return UIColor(red: 0.2, green: 0.24, blue: 0.27, alpha: 0.5) // Dark mode color
      } else {
        return UIColor.paleGray // Light mode color
      }
    }
    handleView.isUserInteractionEnabled = false
    handleView.translatesAutoresizingMaskIntoConstraints = false
    handleTriggerView.translatesAutoresizingMaskIntoConstraints = false

    handleView.layer.cornerRadius = 2.5

    view.addSubview(containerView)
    containerView.addSubview(collectionView)
    containerView.layer.cornerRadius = 20
    containerView.backgroundColor = .systemBackground

    containerView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.translatesAutoresizingMaskIntoConstraints = false

    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .clear

    NSLayoutConstraint.activate([
      containerView.heightAnchor.constraint(equalToConstant: 220),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20),

      collectionView.heightAnchor.constraint(equalToConstant: 200),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
    ])

    handleTriggerView.addSubview(handleView)
    containerView.addSubview(handleTriggerView)

    NSLayoutConstraint.activate([
      handleView.topAnchor.constraint(equalTo: handleTriggerView.topAnchor),
      handleView.centerXAnchor.constraint(equalTo: handleTriggerView.centerXAnchor),
      handleView.widthAnchor.constraint(equalToConstant: 48),
      handleView.heightAnchor.constraint(equalToConstant: 5),

      handleTriggerView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
      handleTriggerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
      handleTriggerView.widthAnchor.constraint(equalToConstant: 60),
      handleTriggerView.heightAnchor.constraint(equalToConstant: 60),

    ])
  }

  @objc
  func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    let velocity = sender.velocity(in: view)
    let translation = sender.translation(in: view)

    if sender.state == .began {
      containerOriginalCenter = containerView.center
    } else if sender.state == .changed {
      let cappedTranslationY = max(-3, min(100, translation.y))
      containerView.center = CGPoint(x: containerOriginalCenter.x, y: containerOriginalCenter.y + cappedTranslationY)
    } else if sender.state == .ended {
      if velocity.y > 0 {
        UIView.animate(withDuration: 0.25) {
          self.containerView.center = self.containerDown
        }
      } else {
        UIView.animate(withDuration: 0.25) {
          self.containerView.center = self.containerUp
        }
      }
    }
  }

  // Collection view data source methods
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    visibleLocations.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let cell = collectionView
        .dequeueReusableCell(withReuseIdentifier: TideCell.reuseIdentifier, for: indexPath) as? TideCell
    else { fatalError("Cannot Down casting") }

    let location = visibleLocations[indexPath.row]

    cell.favoriteButton.isSelected = favorites.contains(location)
    cell.favoriteButton.tintColor = favorites.contains(location) ? .systemRed : .lightGray
    cell.locationLabel.text = location.name
    if let weather = location.weather?.first {
      cell.airTemptText.text = weather.airTemperature.average
      cell.waterTemptText.text = weather.waterTemperature.average
      cell.windSpeedText.text = weather.windSpeed.average
      cell.waveHeightText.text = weather.waveHeight.average
    } else {
      cell.airTemptText.text = "-"
      cell.waterTemptText.text = "-"
      cell.windSpeedText.text = "-"
      cell.waveHeightText.text = "-"
    }
    cell.favoriteButton.removeTarget(self, action: nil, for: .allEvents)
    cell.favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    return cell
  }

  @objc
  func toggleFavorite(sender: UIButton) {
    let point = sender.convert(CGPoint.zero, to: collectionView)
    guard let indexPath = collectionView.indexPathForItem(at: point) else {
      return
    }
    let divingSite = visibleLocations[indexPath.row]
    if !sender.isSelected {
      favorites.add(divingSite)
    } else {
      favorites.remove(divingSite)
    }
    sender.isSelected = !sender.isSelected
    collectionView.reloadItems(at: [indexPath])
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let location = visibleLocations[indexPath.row]
    let tideView = TideView(seaLevel: seaLevelModel.seaLevel, weatherData: [], location: location)
    let hostingController = UIHostingController(rootView: tideView)
    navigationController?.navigationBar.tintColor = .white
    navigationController?.pushViewController(hostingController, animated: true)
  }

  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
    CGSize(width: 120, height: 100)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.y = 0
  }

}

// MARK: CurrentDelegate

extension TideViewController: CurrentDelegate {

  func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation as? MKPointAnnotation else {
      return
    }
    guard
      let index = visibleLocations
        .firstIndex(where: {
          $0.id == "\(annotation.coordinate.latitude.description)," + "\(annotation.coordinate.longitude.description)"
        }) else
    {
      return
    }
    selectedAnnotation = annotation
    let indexPath = IndexPath(item: index, section: 0)
    // if set true, would fire section.visibleItemsInvalidationHandler
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
//    networkManager.getCurrentWeatherData(
//      lat: annotation.coordinate.latitude,
//      lng: annotation.coordinate.longitude,
//      forAnnotation: annotation)
  }

  func manager(didGet weatherData: [WeatherHour], forKey: String) {
    guard let index = visibleLocations.firstIndex(where: { "currentWeather" + $0.id == forKey }) else {
      return
    }
    visibleLocations[index].weather = weatherData.filter { weatherHour in
      ISO8601DateFormatter().date(from: weatherHour.time) == Calendar.current.date(bySetting: .minute, value: 0, of: Date())
    }

    DispatchQueue.main.async {
      if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? TideCell {
        let location = self.visibleLocations[index]
        if let weather = location.weather?.first {
          cell.airTemptText.text = weather.airTemperature.average
          cell.waterTemptText.text = weather.waterTemperature.average
          cell.windSpeedText.text = weather.windSpeed.average
          cell.waveHeightText.text = weather.waveHeight.average
        } else {
          cell.airTemptText.text = "-"
          cell.waterTemptText.text = "-"
          cell.windSpeedText.text = "-"
          cell.waveHeightText.text = "-"
        }
      }
    }
  }

  func updateWeatherDataForVisibleAnnotations() {
    for location in visibleLocations {
      networkManager.getCurrentWeatherData(
        lat: location.latitude,
        lng: location.longitude)
    }
  }

}
