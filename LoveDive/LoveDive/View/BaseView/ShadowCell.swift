//
//  ShadowCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/2.
//

import UIKit

class ShadowCollectionViewCell: UICollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)

    // Apply rounded corners to contentView
    contentView.layer.cornerRadius = cornerRadius
    contentView.layer.masksToBounds = true

    // Set masks to bounds to false to avoid the shadow
    // from being clipped to the corner radius
    layer.cornerRadius = cornerRadius
    layer.masksToBounds = false

    // Apply a shadow
    layer.shadowRadius = 8.0
    layer.shadowOpacity = 0.10
    layer.shadowColor = UIColor.darkGray.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 1)
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var cornerRadius: CGFloat = 20.0

  override func layoutSubviews() {
    super.layoutSubviews()

    // Improve scrolling performance with an explicit shadowPath
    layer.shadowPath = UIBezierPath(
      roundedRect: bounds,
      cornerRadius: cornerRadius).cgPath
  }
}
