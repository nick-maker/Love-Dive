//
//  SectionHeader.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/22.
//

import UIKit

class SectionHeader: UICollectionReusableView {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    label.translatesAutoresizingMaskIntoConstraints = false
    addSubview(label)
    label.font = UIFont.systemFont(ofSize: 12)
    label.textColor = UIColor.lightGray

    NSLayoutConstraint.activate([
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
      label.topAnchor.constraint(equalTo: topAnchor),
      label.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(SectionHeader.self)"

  var text: String? {
    didSet {
      label.text = text
    }
  }

  // MARK: Private

  private let label = UILabel()

}
