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

  let divingSiteManager = DivingSiteManager()
  let networkManager = NetworkManager()
  let locationManager = LocationManager()
  var weatherData = [WeatherHour]()
  var locations = [Location]()
  var annotations: [MKPointAnnotation] = []
  var selectedAnnotaion: MKPointAnnotation?
  var containerOriginalCenter = CGPoint.zero
  var containerDownOffset = CGFloat()
  var containerUp = CGPoint.zero
  var containerDown = CGPoint.zero
  var currentRegion = MKCoordinateSpan()

  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.tabBarController?.tabBar.backgroundColor = .systemBackground
    locationManager.errorPresentationTarget = self
    divingSiteManager.delegate = self
    networkManager.delegate = self

    setupMapView()
    getCurrentLocation()
    divingSiteManager.decodeDivingGeoJSON()
    setupCollectionView()
    configureCompositionalLayout()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    containerDownOffset = 140
    containerUp = containerView.center
    containerDown = CGPoint(x: containerView.center.x ,y: containerView.center.y + containerDownOffset)
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
    updateWeatherDataForVisibleAnnotations()
    // Reload the collection view data
    collectionView.reloadData()
    guard let index = annotations.firstIndex(where: { $0 === selectedAnnotaion }) else {
      return
    }
    let indexPath = IndexPath(item: index, section: 0)

    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
  }

  // MARK: Private

  private var currentPage: Int? = nil
  private var lastScaleFactor = CGFloat() // to determine if the scroll has ended

}

// MARK: DivingSiteDelegate

extension TideViewController: DivingSiteDelegate {

  func getDivingSite(didDecode divingSite: [Location]) {
    locations = divingSite
    createAnnotation(locations: locations)
  }

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
          self.mapView.setRegion(region, animated: true)
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
    annotations.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let cell = collectionView
        .dequeueReusableCell(withReuseIdentifier: TideCell.reuseIdentifier, for: indexPath) as? TideCell
    else { fatalError("Cannot Down casting") }

    let annotation = annotations[indexPath.row]
    cell.locationLabel.text = annotation.title

    let location = locations[indexPath.row]
    if let weather = location.weather?.first {
      cell.airTemptText.text = weather.airTemperature.average
      cell.waterTemptText.text = weather.waterTemperature.average
      cell.windSpeedText.text = weather.windSpeed.average
      cell.waveHeightText.text = weather.waveHeight.average
    } else {
      // Handle the case when there is no weather data available for the location
      // You can update the cell with placeholder values or handle it as per your requirement
      cell.airTemptText.text = "-"
      cell.waterTemptText.text = "-"
      cell.windSpeedText.text = "-"
      cell.waveHeightText.text = "-"
    }
    return cell
  }

  func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let tideView = TideView(seaLevel: networkManager.decodeJSON().data)
    let hostingController = UIHostingController(rootView: tideView)
    hostingController.title = annotations[indexPath.row].title
    navigationController?.navigationBar.tintColor = .pacificBlue
    navigationController?.tabBarController?.tabBar.backgroundColor = .clear

    navigationItem.backButtonTitle = ""
    navigationController?.tabBarController?.tabBar.backgroundImage = UIImage()
    navigationController?.tabBarController?.tabBar.shadowImage = UIImage()
    navigationController?.pushViewController(hostingController, animated: true)
  }

  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
    CGSize(width: 120, height: 100)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.y = 0
  }

}

// MARK: WeatherDelegate

extension TideViewController: WeatherDelegate {

  func mapView(_: MKMapView, didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation as? MKPointAnnotation else {
      return
    }

    guard let index = annotations.firstIndex(where: { $0 === annotation }) else {
      return
    }
    selectedAnnotaion = annotation
    let indexPath = IndexPath(item: index, section: 0)
    // if set true, would fire section.visibleItemsInvalidationHandler
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    networkManager.getCurrentWeatherData(
      lat: annotation.coordinate.latitude,
      lng: annotation.coordinate.longitude,
      forAnnotation: annotation)
  }

  func manager(didGet weatherData: [WeatherHour], forAnnotation annotation: MKAnnotation) {
    guard let annotationIndex = annotations.firstIndex(where: { $0 === annotation }) else {
      return
    }
    locations[annotationIndex].weather = weatherData.filter { weatherHour in
      ISO8601DateFormatter().date(from: weatherHour.time) == Calendar.current.date(bySetting: .minute, value: 0, of: Date())
    }

    DispatchQueue.main.async {
      if let cell = self.collectionView.cellForItem(at: IndexPath(row: annotationIndex, section: 0)) as? TideCell {
        let location = self.locations[annotationIndex]
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
    let visibleMapRect = mapView.visibleMapRect
    let visibleAnnotations = mapView.annotations(in: visibleMapRect)

    for annotation in visibleAnnotations {
      if let pointAnnotation = annotation as? MKPointAnnotation {
        networkManager.getCurrentWeatherData(
          lat: pointAnnotation.coordinate.latitude,
          lng: pointAnnotation.coordinate.longitude,
          forAnnotation: pointAnnotation)
      }
    }
  }

}
