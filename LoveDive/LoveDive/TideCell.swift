//
//  CollectionViewCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import UIKit

class TideCell: UICollectionViewCell {

  static let reuseIdentifier = "\(TideCell.self)"

  var weatherLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    contentView.backgroundColor = UIColor.lightBlue
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupUI() {

    weatherLabel.translatesAutoresizingMaskIntoConstraints = false
    weatherLabel.textColor = UIColor.pacificBlue
    contentView.addSubview(weatherLabel)

    NSLayoutConstraint.activate([
      weatherLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      weatherLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
    ])
  }

}
