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
      label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
      label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
      label.topAnchor.constraint(equalTo: topAnchor),

      captionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
      captionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
      captionLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
      captionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
    ])
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(BestSectionHeader.self)"

  var label = {
    var label = UILabel()
    label.text = "Personal Best Dives"
    label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
    return label
  }()

  func config(text: String) {
    captionLabel.text = text
  }

  // MARK: Private

  private let captionLabel = {
    var caption = UILabel()
    caption.textColor = .secondaryLabel
    caption.font = UIFont.systemFont(ofSize: 12)
    return caption
  }()

  private let constant = 20.0
}
