//
//  DiveCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/18.
//

import UIKit

class DiveCell: UICollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(DiveCell.self)"

  var waterDepthLabel = UILabel()
  var waterTempLabel = UILabel()

  // MARK: Private

  private func setupUI() {
    contentView.layer.cornerRadius = 20
    contentView.backgroundColor = .lightGray.withAlphaComponent(0.2)

    contentView.addSubview(waterDepthLabel)
    contentView.addSubview(waterTempLabel)
    waterDepthLabel.translatesAutoresizingMaskIntoConstraints = false
    waterTempLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      waterDepthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      waterDepthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      waterDepthLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

      waterTempLabel.leadingAnchor.constraint(equalTo: waterDepthLabel.leadingAnchor),
      waterTempLabel.topAnchor.constraint(equalTo: waterDepthLabel.topAnchor, constant: -15),
    ])
  }
}
