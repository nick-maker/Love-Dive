//
//  File.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import UIKit

class RoundedNavigationController: UINavigationController {

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationBar.prefersLargeTitles = true
    if let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.rounded) {
      let font = UIFont(descriptor: descriptor, size: 34)
      self.navigationBar.largeTitleTextAttributes = [.font: font]
    }
  }
}
