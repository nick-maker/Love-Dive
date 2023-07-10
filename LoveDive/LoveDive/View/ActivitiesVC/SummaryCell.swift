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

    descriptionLabel.font = UIFont.systemFont(ofSize: 12)
    descriptionLabel.textColor = UIColor.darkGray

    figureLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)

    NSLayoutConstraint.activate([
      descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      figureLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      figureLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 2),
      figureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      figureLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

    ])
  }

}
