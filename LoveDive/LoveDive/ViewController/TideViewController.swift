//
//  ViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/14.
//

import Alamofire
import MapKit
import UIKit

// MARK: - TideViewController

class TideViewController: UIViewController, MKMapViewDelegate {

  var mapView = MKMapView()
  var diveSites: [[String: Any]] = []
  lazy var collectionView = UICollectionView() // Must be initialized with a non-nil layout parameter

  var locations = [Location]()

  let regionRadius: CLLocationDistance = 1000

  let networkManager = NetworkManager()
  var weatherData = [WeatherHour]()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
    setupCollectionView()
    setupUI()
    decodeDivingGeoJSON()
    networkManager.delegate = self
  }


  func decodeDivingGeoJSON() {
    guard let geoJSONURL = Bundle.main.url(forResource: "TaiwanDivingSite", withExtension: "geojson") else {
      print("Failed to load GeoJSON file")
      return
    }

    do {
      let data = try Data(contentsOf: geoJSONURL)
      let geoJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
      guard let features = geoJSON["features"] as? [[String: Any]] else { return }

      for feature in features {
        guard
          let geometry = feature["geometry"] as? [String: Any],
          let properties = feature["properties"] as? [String: Any],
          let coordinates = geometry["coordinates"] as? [Double],
          let name = properties["name"] as? String
        else {
          continue
        }

        let longitude = coordinates[0]
        let latitude = coordinates[1]
        let location = Location(name: name, latitude: latitude, longitude: longitude)
        locations.append(location)
      }

    } catch {
      print("Failed to parse GeoJSON file: \(error)")
    }
    for location in locations {
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
      annotation.title = location.name
      mapView.addAnnotation(annotation)
    }

    collectionView.reloadData()
  }

  func setupMapView() {
    mapView = MKMapView()
    mapView.delegate = self
    mapView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(mapView)

    NSLayoutConstraint.activate([
      mapView.topAnchor.constraint(equalTo: view.topAnchor),
      mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.75),
    ])
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

  func setupCollectionView() {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Create a group
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .absolute(100))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    // Create a section
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .groupPagingCentered
//    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

    // Create a layout
    let layout = UICollectionViewCompositionalLayout(section: section)
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(TideCell.self, forCellWithReuseIdentifier: TideCell.reuseIdentifier)
  }

  func setupUI() {
    view.addSubview(collectionView)

    NSLayoutConstraint.activate([
      collectionView.heightAnchor.constraint(equalToConstant: 100),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
    ])
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
