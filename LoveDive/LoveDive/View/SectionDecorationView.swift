//
//  SectionDecorationView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/21.
//

import UIKit

class SectionDecorationView: UICollectionReusableView {

  // MARK: Lifecycle

  // MARK: MAIN -

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUpViews()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  // MARK: FUNCTIONS -

  func setUpViews() {
    backgroundColor = .lightGray.withAlphaComponent(0.2)
    layer.cornerRadius = 20
  }

}
