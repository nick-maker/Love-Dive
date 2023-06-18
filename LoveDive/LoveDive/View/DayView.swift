//
//  DayView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import UIKit

class LargeCircleView: UIView {

  // MARK: Lifecycle

  init(color: UIColor) {
    super.init(frame: .zero)

    backgroundColor = color
    layer.cornerRadius = 10 // Adjust this for the size of your circle
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override var intrinsicContentSize: CGSize {
    CGSize(width: 20, height: 20) // Adjust this for the size of your circle
  }
}
