//
//  SummaryReusableView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/21.
//

import UIKit

class SummaryCell: UICollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(SummaryCell.self)"

  var descriptionLabel = UILabel()
  var figureLabel = UILabel()

  func setupUI() {
    [descriptionLabel, figureLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
    [descriptionLabel, figureLabel].forEach { contentView.addSubview($0) }
    contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
    contentView.layer.cornerRadius = 20

    NSLayoutConstraint.activate([
      descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

      figureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      figureLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
      figureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      figureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

    ])
  }

}
