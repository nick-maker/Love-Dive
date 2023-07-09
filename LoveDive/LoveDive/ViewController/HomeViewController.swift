//
//  HomeViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/9.
//

import UIKit

class HomeViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigation()
  }

  func setupNavigation() {
    navigationItem.title = "Home"
    navigationController?.navigationBar.tintColor = .pacificBlue
    navigationItem.backButtonTitle = ""
    navigationController?.navigationBar.prefersLargeTitles = true
  }



}
