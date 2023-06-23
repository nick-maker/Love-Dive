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
  var dateLabel = UILabel()
  var arrowImage = UIImageView()

  // MARK: Private

  private func setupUI() {
    contentView.layer.cornerRadius = 20
    contentView.backgroundColor = .paleGray.withAlphaComponent(0.5)

    [waterDepthLabel, dateLabel, arrowImage].forEach { contentView.addSubview($0) }
    [waterDepthLabel, dateLabel, arrowImage].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    waterDepthLabel.font = UIFont.systemFont(ofSize: 18)
    dateLabel.font = UIFont.systemFont(ofSize: 12)
    dateLabel.textColor = UIColor.lightGray
    arrowImage.image = UIImage(systemName: "chevron.right")

    NSLayoutConstraint.activate([
      waterDepthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      waterDepthLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      waterDepthLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      dateLabel.topAnchor.constraint(equalTo: waterDepthLabel.bottomAnchor, constant: 2),
      dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

      arrowImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      arrowImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    ])
  }
}
