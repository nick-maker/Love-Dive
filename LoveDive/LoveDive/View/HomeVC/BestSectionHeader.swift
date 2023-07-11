//
//  SectionHeader.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/22.
//

import UIKit

class BestSectionHeader: UICollectionReusableView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    label.translatesAutoresizingMaskIntoConstraints = false
    captionLabel.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    addSubview(captionLabel)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      label.topAnchor.constraint(equalTo: topAnchor),

      captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      captionLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
      captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(BestSectionHeader.self)"

  let label = UILabel()
  let captionLabel = UILabel()

}
