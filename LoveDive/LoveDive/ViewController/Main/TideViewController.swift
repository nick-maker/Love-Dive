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
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    collectionView.register(TideCell.self, forCellWithReuseIdentifier: TideCell.reuseIdentifier)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.isPagingEnabled = true
    return collectionView
  }() // Must be initialized with a non-nil layout parameter

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.tabBarController?.tabBar.backgroundColor = .systemBackground
    locationManager.errorPresentationTarget = self
    networkManager.currentDelegate = self
    setupMapView()
    getCurrentLocation()
    getDivingSite()
    setupCollectionView()
  }

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
      let locationData = UserDefaults.standard.object(forKey: "allLocation") as? Data,
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
    }
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
    let visibleMapRect = mapView.visibleMapRect
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
    DispatchQueue.main.async {
      self.updateWeatherDataForVisibleAnnotations()
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

  private let saveKey = "favorites"

  private let networkManager = NetworkManager()
  private let seaLevelModel = SeaLevelModel(networkRequest: AlamofireNetwork.shared)
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
  private var favorites = Favorites()

  private var lastScaleFactor = CGFloat() // to determine if the scroll has ended
  private var currentPage = CGFloat.zero

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension TideViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

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
      cell.config(
        air: weather.airTemperature.average,
        water: weather.waterTemperature.average,
        wind: weather.windSpeed.average,
        wave: weather.waveHeight.average)
    } else {
      cell.config(air: "-", water: "-", wind: "-", wave: "-")
    }
    cell.favoriteButton.removeTarget(self, action: nil, for: .allEvents)
    cell.favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)
    return cell
  }

  @objc
  func toggleFavorite(sender: UIButton) {
    generateHapticFeedback(for: HapticFeedback.selection)
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
    generateHapticFeedback(for: HapticFeedback.selection)
    let location = visibleLocations[indexPath.row]
    let tideView = TideView(seaLevel: seaLevelModel.seaLevel, weatherData: [], location: location)
    let hostingController = UIHostingController(rootView: tideView)
    navigationController?.navigationBar.tintColor = .white
    navigationItem.backButtonTitle = ""
    navigationController?.pushViewController(hostingController, animated: true)
  }

  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
    CGSize(width: UIScreen.main.bounds.width * 0.75, height: 140)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int)
    -> CGFloat
  {
    UIScreen.main.bounds.width * 0.25
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int)
    -> UIEdgeInsets
  {
    UIEdgeInsets(top: 40, left: UIScreen.main.bounds.width * 0.25 / 2, bottom: 0, right: UIScreen.main.bounds.width * 0.25 / 2)
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    currentPage = scrollView.contentOffset.x / view.bounds.width
    let indexPath = IndexPath(row: Int(currentPage), section: 0)
    guard let cell = collectionView.cellForItem(at: indexPath) as? TideCell else { return }
    let annotationTitle = cell.locationLabel.text
    guard let annotation = mapView.annotations.first(where: { $0.title == annotationTitle }) else { return }
    mapView.selectAnnotation(annotation, animated: true)
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
          $0.id == "\(annotation.coordinate.latitude)," + "\(annotation.coordinate.longitude)"
        })
    else {
      return
    }
    selectedAnnotation = annotation
    let indexPath = IndexPath(item: index, section: 0)
    // if set true, would fire section.visibleItemsInvalidationHandler
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  func manager(didGet weatherData: [WeatherHour], forKey: String) {
    guard let index = visibleLocations.firstIndex(where: { "currentWeather" + $0.id == forKey }) else {
      return
    }
    visibleLocations[index].weather = weatherData.filter { weatherHour in
      Formatter.utc.date(from: weatherHour.time) == Calendar.current.date(bySetting: .minute, value: 0, of: Date())
    }

    DispatchQueue.main.async {
      if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? TideCell {
        let location = self.visibleLocations[index]
        if let weather = location.weather?.first {
          cell.config(
            air: weather.airTemperature.average,
            water: weather.waterTemperature.average,
            wind: weather.windSpeed.average,
            wave: weather.waveHeight.average)
        } else {
          cell.config(air: "-", water: "-", wind: "-", wave: "-")
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
