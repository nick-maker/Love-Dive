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
    return collectionView
  }() // Must be initialized with a non-nil layout parameter

  let regionRadius: CLLocationDistance = 100

  let divingSiteModel = DivingSiteModel()
  let networkManager = NetworkManager()
  let locationManager = LocationManager()
  var weatherData = [WeatherHour]()
  var locations = [Location]()
  var containerOriginalCenter = CGPointZero
  var containerDownOffset = CGFloat()
  var containerUp = CGPointZero
  var containerDown = CGPointZero

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.errorPresentationTarget = self
    setupMapView()
    setupCollectionView()
    configureCompositionalLayout()
    DispatchQueue.global().async {
      self.divingSiteModel.decodeDivingGeoJSON()
    }
    networkManager.delegate = self
    getCurrentLocation()


  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    containerDownOffset = 100
    containerUp = containerView.center
    print(containerView.center)
    containerDown = CGPoint(x: containerView.center.x ,y: containerView.center.y + containerDownOffset)
  }

  func getCurrentLocation() {
    locationManager.getUserLocation { [weak self] location in
      DispatchQueue.main.async {
        guard let self = self else {
          return
        }
        self.mapView.setRegion(MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)), animated: true)
        self.mapView.showsUserLocation = true
      }
    }
  }

  func setupMapView() {
    mapView = MKMapView()
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

  func addAnnotation() {
    for location in locations {
      DispatchQueue.main.async {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        annotation.title = location.name
        self.mapView.addAnnotation(annotation)
        self.collectionView.reloadData()
      }
    }
  }

  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius * 5.0,
      longitudinalMeters: regionRadius * 5.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }

  func mapView(_ mapView: MKMapView, regionDidChangeAnimated _: Bool) {
    let visibleMapRect = mapView.visibleMapRect
    let visibleRegion = MKCoordinateRegion(visibleMapRect)
    let parameters: [String: Any] = [
      "southWestLat": visibleRegion.center.latitude - visibleRegion.span.latitudeDelta / 2,
      "northEastLat": visibleRegion.center.latitude + visibleRegion.span.latitudeDelta / 2,
      "southWestLng": visibleRegion.center.longitude - visibleRegion.span.longitudeDelta / 2,
      "northEastLng": visibleRegion.center.longitude + visibleRegion.span.longitudeDelta / 2,
    ]
    collectionView.reloadData()
  }

}

// MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension TideViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func configureCompositionalLayout() {
    let layout = UICollectionViewCompositionalLayout(section: AppLayouts.weatherSection())
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
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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

  @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
    let velocity = sender.velocity(in: view)
    let translation = sender.translation(in: view)

    if sender.state == .began {
      containerOriginalCenter = containerView.center
      print("Gesture began\(containerOriginalCenter)")
    } else if sender.state == .changed {
      let cappedTranslationY = max(-3, min(100, translation.y))
      containerView.center = CGPoint(x: containerOriginalCenter.x, y: containerOriginalCenter.y + cappedTranslationY)
      print("Gesture is changing")
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
    mapView.annotations(in: mapView.visibleMapRect).count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let cell = collectionView
        .dequeueReusableCell(withReuseIdentifier: TideCell.reuseIdentifier, for: indexPath) as? TideCell
    else { fatalError("Cannot Downcasting") }
    let visibleAnnotationsArray = Array(mapView.annotations(in: mapView.visibleMapRect))
    if indexPath.row < visibleAnnotationsArray.count {
      guard let annotation = visibleAnnotationsArray[indexPath.row] as? MKPointAnnotation else {
        return cell
      }
      cell.locationLabel.text = annotation.title
    }

    if indexPath.row < weatherData.count {
      cell.airTemptText.text = weatherData[indexPath.row].airTemperature.average
      cell.waterTemptText.text = weatherData[indexPath.row].waterTemperature.average
      cell.windSpeedText.text = weatherData[indexPath.row].windSpeed.average
      cell.waveHeightText.text = weatherData[indexPath.row].waveHeight.average
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

}

// MARK: WeatherDelegate

extension TideViewController: WeatherDelegate {

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    guard let annotation = view.annotation else {
      return
    }

    let zoomRegion = MKCoordinateRegion(
      center: annotation.coordinate,
      latitudinalMeters: regionRadius, // Adjust these values for your desired zoom level
      longitudinalMeters: regionRadius)

    mapView.setRegion(zoomRegion, animated: true)
    // Find the index of the selected annotation in the visible annotations array
    let visibleAnnotationsArray = Array(mapView.annotations(in: mapView.visibleMapRect))
    guard
      let index = visibleAnnotationsArray.firstIndex(where: {
        guard let pointAnnotation = $0 as? MKPointAnnotation else { return false }
        networkManager.getData(lat: pointAnnotation.coordinate.latitude, lng: pointAnnotation.coordinate.longitude)
        return pointAnnotation.title == annotation.title
      }) else
    {
      return
    }
    // Scroll the collection view to the corresponding item
    let indexPath = IndexPath(item: index, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  func manager(didGet weatherData: [WeatherHour]) {
    self.weatherData = weatherData
    DispatchQueue.main.async {
      self.collectionView.reloadData()
    }
  }

}
