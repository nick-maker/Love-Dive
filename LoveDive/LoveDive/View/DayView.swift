//
//  DayView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import UIKit

class LargeCircleView: UIView {
  init(color: UIColor) {
    super.init(frame: .zero)

    self.backgroundColor = color
    self.layer.cornerRadius = 10 // Adjust this for the size of your circle
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: 20, height: 20) // Adjust this for the size of your circle
  }
}
