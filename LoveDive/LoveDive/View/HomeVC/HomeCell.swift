//
//  CollectionViewCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import MapKit
import UIKit

class HomeCell: ShadowCollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()

    contentView.backgroundColor = .dynamicColor2
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(HomeCell.self)"

  let locationLabel = UILabel()

  let mapSnapshot: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    image.clipsToBounds = true
    image.contentMode = .scaleAspectFill
    return image
  }()

  var favoriteButton: UIButton = {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .small)
    let emptyHeartImage = UIImage(systemName: "heart", withConfiguration: config)
    let filledHeartImage = UIImage(systemName: "heart.fill", withConfiguration: config)
    button.setImage(emptyHeartImage, for: .normal)
    button.setImage(filledHeartImage, for: .selected)
    button.tintColor = .lightGray
    return button
  }()

  func setupUI() {
    // Setup location label
    locationLabel.translatesAutoresizingMaskIntoConstraints = false
    locationLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)

    contentView.addSubview(mapSnapshot)
    contentView.addSubview(locationLabel)
    contentView.addSubview(favoriteButton)
    contentView.layer.cornerRadius = 20

    // Setup constraints
    NSLayoutConstraint.activate([
      favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      mapSnapshot.topAnchor.constraint(equalTo: contentView.topAnchor),
      mapSnapshot.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      mapSnapshot.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
      mapSnapshot.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.75),

      locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      locationLabel.topAnchor.constraint(equalTo: mapSnapshot.bottomAnchor, constant: 16),
      locationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
    ])
  }

  func snapshot(lat: Double, lng: Double) {
    let key = "\(lat)," + "\(lng) cache" as NSString

    if let cachedImage = cache.object(forKey: key) {
      mapSnapshot.image = cachedImage
      return
    }

    let option = MKMapSnapshotter.Options()
    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    option.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
//    option.size = mapSnapshot.bounds.size
    option.scale = UIScreen.main.scale
    option.mapType = .mutedStandard

    let snapshot = MKMapSnapshotter(options: option)
    snapshot.start(with: .global()) { [weak self] snapshot, error in
      guard let self else { return }
      guard error == nil, let snapshot else { return }

      DispatchQueue.main.async {
        UIGraphicsBeginImageContextWithOptions(snapshot.image.size, true, snapshot.image.scale)
        snapshot.image.draw(at: .zero)

        let point = snapshot.point(for: coordinate)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let annotationView = MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
//        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.tintColor = UIColor.pacificBlue
        annotationView.drawHierarchy(
          in: CGRect(x: point.x, y: point.y, width: annotationView.bounds.width, height: annotationView.bounds.height),
          afterScreenUpdates: true)

        if let drawnImage = UIGraphicsGetImageFromCurrentImageContext() {
          drawnImage.withTintColor(.pacificBlue)
          self.cache.setObject(drawnImage, forKey: key)
          self.mapSnapshot.image = drawnImage
        }
      }
    }
  }

  // MARK: Private

  private var location: (lat: Double, lng: Double)?

  private let cache = NSCache<NSString, UIImage>()

}
