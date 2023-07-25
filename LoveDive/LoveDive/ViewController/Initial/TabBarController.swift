//
//  TabbarController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//

import UIKit

// MARK: - TabBarController

class TabBarController: UITabBarController, UITabBarControllerDelegate {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    delegate = self
    divingSiteManager.delegate = self
    divingSiteManager.decodeDivingGeoJSON()
  }

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    generateHapticFeedback(for: HapticFeedback.selection)
    if
      tabBarController.selectedViewController === viewController,
      let handler = viewController as? TabBarReselectHandling
    {
      handler.handleReselect()
    }

    guard let navigationController = viewController as? UINavigationController else { return true }
    guard
      navigationController.viewControllers.count <= 1,
      let handler = navigationController.viewControllers.first as? TabBarReselectHandling
    else { return true }
    handler.handleReselect()
    return true
  }

  // MARK: Private

  private let divingSiteManager = DivingSiteManager()

}

// MARK: - TabBarReselectHandling

protocol TabBarReselectHandling {
  func handleReselect()
}

// MARK: - TabBarController + DivingSiteDelegate

extension TabBarController: DivingSiteDelegate {

  func getDivingSite(didDecode divingSite: [Location]) {
    if let encodedDivingSite = try? JSONEncoder().encode(divingSite) {
      UserDefaults.standard.set(encodedDivingSite, forKey: "allLocation")
    }
  }

}
