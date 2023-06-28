//
//  CollectionViewCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import UIKit

class TideCell: UICollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    contentView.backgroundColor = UIColor.lightBlue
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(TideCell.self)"

  let locationLabel = UILabel()
  let airTemptImage = UIImage(systemName: "cloud.fill")
  let airTemptText = UILabel()
  let waterTemptImage = UIImage(systemName: "thermometer.and.liquid.waves")
  let waterTemptText = UILabel()
  let waveHeightImage = UIImage(systemName: "water.waves")
  let waveHeightText = UILabel()
  let windSpeedImage = UIImage(systemName: "wind")
  let windSpeedText = UILabel()

  let stackView = UIStackView()

  func setupUI() {
    // Setup location label
    locationLabel.translatesAutoresizingMaskIntoConstraints = false
    locationLabel.textColor = UIColor.pacificBlue
    contentView.addSubview(locationLabel)
    contentView.layer.cornerRadius = 20

    // Create image views
    let airTemptImageView = UIImageView(image: airTemptImage)
    let waterTemptImageView = UIImageView(image: waterTemptImage)
    let waveHeightImageView = UIImageView(image: waveHeightImage)
    let windSpeedImageView = UIImageView(image: windSpeedImage)

    // Configure stack view
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .horizontal
    stackView.distribution = .equalSpacing

    // Adding subviews to the stack view
    stackView.addArrangedSubview(createStackView(imageView: airTemptImageView, label: airTemptText))
    stackView.addArrangedSubview(createStackView(imageView: waterTemptImageView, label: waterTemptText))
    stackView.addArrangedSubview(createStackView(imageView: waveHeightImageView, label: waveHeightText))
    stackView.addArrangedSubview(createStackView(imageView: windSpeedImageView, label: windSpeedText))

    // Adding stack view to content view
    contentView.addSubview(stackView)

    // Setup constraints
    NSLayoutConstraint.activate([
      locationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),

      stackView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
    ])
  }

  func createStackView(imageView: UIImageView, label: UILabel) -> UIStackView {
    let innerStackView = UIStackView()
    innerStackView.axis = .vertical
    innerStackView.alignment = .center
    innerStackView.spacing = 2
    innerStackView.addArrangedSubview(imageView)
    innerStackView.addArrangedSubview(label)
    return innerStackView
  }

}
