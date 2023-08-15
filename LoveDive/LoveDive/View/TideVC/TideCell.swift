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

  func config(air: String, water: String, wind: String, wave: String) {
    airTemptText.text = air
    waterTemptText.text = water
    windSpeedText.text = wind
    waveHeightText.text = wave
  }

  // MARK: Private

  private let airTemptImage = UIImage(systemName: "cloud.sun")
  private let airTemptText = UILabel()
  private let waterTemptImage = UIImage(systemName: "thermometer.and.liquid.waves")
  private let waterTemptText = UILabel()
  private let waveHeightImage = UIImage(systemName: "water.waves")
  private let waveHeightText = UILabel()
  private let windSpeedImage = UIImage(systemName: "wind")
  private let windSpeedText = UILabel()

  private let stackView = UIStackView()
  private let constant = 16.0

  private func setupUI() {
    // Setup location label
    locationLabel.translatesAutoresizingMaskIntoConstraints = false
    locationLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)

    contentView.addSubview(locationLabel)
    contentView.layer.cornerRadius = 20
    let config = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .small)
    // Create image views
    let airTemptImageView = UIImageView(image: airTemptImage?.applyingSymbolConfiguration(config))
    let waterTemptImageView = UIImageView(image: waterTemptImage?.applyingSymbolConfiguration(config))
    let waveHeightImageView = UIImageView(image: waveHeightImage?.applyingSymbolConfiguration(config))
    let windSpeedImageView = UIImageView(image: windSpeedImage?.applyingSymbolConfiguration(config))

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
      locationLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: constant),

      stackView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: constant),
      stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: constant),
      stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -constant),

      favoriteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: constant),
      favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -constant),
    ])
  }

  private func createStackView(imageView: UIImageView, label: UILabel) -> UIStackView {
    let innerStackView = UIStackView()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textColor = .secondaryLabel
    innerStackView.axis = .vertical
    innerStackView.alignment = .center
    innerStackView.spacing = 2
    innerStackView.addArrangedSubview(imageView)
    innerStackView.addArrangedSubview(label)
    return innerStackView
  }

}
