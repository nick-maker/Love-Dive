//
//  FavSectionHeader.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/11.
//

import UIKit

class FavSectionHeader: UICollectionReusableView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    label.translatesAutoresizingMaskIntoConstraints = false

    addSubview(label)

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
      label.topAnchor.constraint(equalTo: topAnchor),
      label.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(FavSectionHeader.self)"

  let label = UILabel()

  // MARK: Private

  private let constant = 20.0
}
