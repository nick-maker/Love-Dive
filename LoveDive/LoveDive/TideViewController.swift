//
//  ViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/14.
//

import UIKit
import MapKit
import Alamofire

class TideViewController: UIViewController, MKMapViewDelegate {

  var mapView: MKMapView!
  var collectionView: UICollectionView!

  let locations = [
    (name: "Location1", latitude: 37.7749, longitude: -122.4194, weather: "Sunny"),
    (name: "Location2", latitude: 0, longitude: 32.4194, weather: "Rainy"),
    (name: "Location3", latitude: 60.7749, longitude: -12.4194, weather: "Cloudy"),
    (name: "Location4", latitude: 80.7749, longitude: 122.4194, weather: "Snowing"),
    // Add more locations...
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
    setupCollectionView()
    getData()
    
  }

  func getData() {
    let parameters = ["airTemperature", "swellDirection", "swellHeight", "swellPeriod", "waterTemperature", "waveDirection", "waveHeight", "windDirection", "windSpeed"]

    let params: [String: Any] = [
        "lat": 22.3348440,
        "lng": 120.3776006,
        "params": parameters.joined(separator: ","),
    ]

    let headers: HTTPHeaders = [
      "Authorization": Config.weatherAPI
    ]

    AF.request("https://api.stormglass.io/v2/weather/point", method: .get, parameters: params, headers: headers).responseJSON { response in
      switch response.result {
          case .success(let value):
              print("JSON: \(value)")
          case .failure(let error):
              print("Error: \(error)")
          }
    }

  }

  let regionRadius: CLLocationDistance = 1000
  func centerMapOnLocation(location: CLLocation) {
    let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                              latitudinalMeters: regionRadius * 10.0, longitudinalMeters: regionRadius * 10.0)
    mapView.setRegion(coordinateRegion, animated: true)
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
      mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
    ])

    // Set initial location
    let initialLocation = CLLocation(latitude: locations[0].latitude, longitude: locations[0].longitude)
    centerMapOnLocation(location: initialLocation)

    // Add annotations to the map
    var annotations = [MKPointAnnotation]()
    for location in locations {
      let annotation = MKPointAnnotation()
      annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
      annotation.title = location.weather
      annotations.append(annotation)
    }
    mapView.addAnnotations(annotations)
  }
}

extension TideViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  func setupCollectionView() {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)

    // Create a group
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

    // Create a section
    let section = NSCollectionLayoutSection(group: group)
    section.orthogonalScrollingBehavior = .continuous
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

    // Create a layout
    let layout = UICollectionViewCompositionalLayout(section: section)
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(TideCell.self, forCellWithReuseIdentifier: TideCell.reuseIdentifier)

    view.addSubview(collectionView)

    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  // Collection view data source methods
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return locations.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TideCell.reuseIdentifier, for: indexPath) as? TideCell else { fatalError("Cannot Downcasting")}
    cell.weatherLabel.text = locations[indexPath.row].weather
    return cell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let location = locations[indexPath.row]
    let selectedLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
    centerMapOnLocation(location: selectedLocation)
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 120, height: 100)
  }

}

