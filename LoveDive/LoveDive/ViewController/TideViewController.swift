//
//  ViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/14.
//

import MapKit
import UIKit

// MARK: - TideViewController

class TideViewController: UIViewController, MKMapViewDelegate {

  var mapView = MKMapView()
  let containerView = UIView()
  lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.register(TideCell.self, forCellWithReuseIdentifier: TideCell.reuseIdentifier)
    collectionView.showsVerticalScrollIndicator = false
    return collectionView
  }() // Must be initialized with a non-nil layout parameter

  let divingSiteModel = DivingSiteModel()
  let networkManager = NetworkManager()
  let locationManager = LocationManager()
  var weatherData = [WeatherHour]()
  var locations = [Location]()
  var annotations: [MKPointAnnotation] = []
  var containerOriginalCenter = CGPointZero
  var containerDownOffset = CGFloat()
  var containerUp = CGPointZero
  var containerDown = CGPointZero

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.errorPresentationTarget = self
    divingSiteModel.delegate = self
    networkManager.delegate = self

    setupMapView()
    getCurrentLocation()
    divingSiteModel.decodeDivingGeoJSON()
    setupCollectionView()
    configureCompositionalLayout()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    containerDownOffset = 100
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
      DispatchQueue.main.async {
        guard let self else {
          return
        }
        self.mapView.setRegion(
          MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)),
          animated: true)
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
      networkManager.getWeatherData(lat: annotation.coordinate.latitude, lng: annotation.coordinate.longitude, forAnnotation: annotation)
    }
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
    let visibleMapRect = mapView.visibleMapRect
    let visibleRegion = MKCoordinateRegion(visibleMapRect)
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
  }

}

extension TideViewController: DivingSiteDelegate {

  func getDivingSite(didDecode divingSite: [Location]) {
    locations = divingSite
    createAnnotation(locations: locations)
  }

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension TideViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func configureCompositionalLayout() {
    let layout = UICollectionViewCompositionalLayout(section: AppLayouts.weatherSection())
    let configuration = UICollectionViewCompositionalLayoutConfiguration()
    configuration.scrollDirection = .horizontal
    collectionView.setCollectionViewLayout(layout, animated: true)
  }

  func setupCollectionView() {
    let handleView = UIView()
    let handleTriggerView = UIView()
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
    handleTriggerView.addGestureRecognizer(panGesture)
    handleView.backgroundColor = .paleGray
    handleView.isUserInteractionEnabled = false
    handleView.translatesAutoresizingMaskIntoConstraints = false
    handleTriggerView.translatesAutoresizingMaskIntoConstraints = false

    handleView.layer.cornerRadius = 2.5

    view.addSubview(containerView)
    containerView.addSubview(collectionView)
    containerView.layer.cornerRadius = 20
    containerView.backgroundColor = .white

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

      collectionView.heightAnchor.constraint(equalToConstant: 180),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
        UIView.animate(withDuration: 0.5) {
          self.containerView.center = self.containerDown
        }
      } else {
        UIView.animate(withDuration: 0.5) {
          self.containerView.center = self.containerUp
        }
      }
    }
  }

  // Collection view data source methods
  func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
    return annotations.count
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
      cell.airTemptText.text = "N/A"
      cell.waterTemptText.text = "N/A"
      cell.windSpeedText.text = "N/A"
      cell.waveHeightText.text = "N/A"
    }

    return cell
  }

  func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) {
    let detailViewController = DetailTideViewController()
    navigationController?.pushViewController(detailViewController, animated: true)
  }

  func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
    CGSize(width: 120, height: 100)
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    scrollView.contentOffset.y = 0
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let centerPoint = CGPoint(x: self.collectionView.center.x + scrollView.contentOffset.x,
                              y: self.collectionView.center.y + scrollView.contentOffset.y)

    // Use the center point to determine the index path of the cell that's currently in the center
    guard let indexPath = self.collectionView.indexPathForItem(at: centerPoint),
          let cell = self.collectionView.cellForItem(at: indexPath) as? TideCell else { return }

    // Get the corresponding annotation title
    let annotationTitle = cell.locationLabel.text

    // Find the annotation that matches the title
    guard let annotation = mapView.annotations.first(where: { $0.title == annotationTitle }) else { return }

    // Center the map on the annotation's coordinate
    let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 8000, longitudinalMeters: 8000)
    mapView.setRegion(region, animated: true)
    mapView.selectAnnotation(annotation, animated: true)
  }

}

// MARK: WeatherDelegate

extension TideViewController: WeatherDelegate {

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation as? MKPointAnnotation else {
      return
    }

    guard let index = annotations.firstIndex(where: { $0 === annotation }) else {
      return
    }

    let indexPath = IndexPath(item: index, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  func manager(didGet weatherData: [WeatherHour], forAnnotation annotation: MKAnnotation) {
    guard let annotationIndex = annotations.firstIndex(where: { $0 === annotation }) else {
      return
    }
    locations[annotationIndex].weather = weatherData
    
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }

  func updateWeatherDataForVisibleAnnotations() {
    
    let visibleMapRect = mapView.visibleMapRect
    let visibleAnnotations = mapView.annotations(in: visibleMapRect)
    
    for annotation in visibleAnnotations {
      if let pointAnnotation = annotation as? MKPointAnnotation {
        let key = "\(pointAnnotation.coordinate.latitude),\(pointAnnotation.coordinate.longitude)"
        networkManager.getWeatherData(lat: pointAnnotation.coordinate.latitude, lng: pointAnnotation.coordinate.longitude, forAnnotation: pointAnnotation)
      }
    }
  }

}
