//
//  CollectionViewCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import UIKit

class TideCell: ShadowCollectionViewCell {

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
    contentView.addSubview(favoriteButton)

    // Setup constraints
    NSLayoutConstraint.activate([
      locationLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),

      stackView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
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
