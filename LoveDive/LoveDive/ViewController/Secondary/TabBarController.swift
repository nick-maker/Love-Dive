//
//  TabbarController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//

import UIKit

// MARK: - TabBarController

class TabBarController: UITabBarController, UITabBarControllerDelegate, DivingSiteDelegate {

  // MARK: Internal

  func getDivingSite(didDecode divingSite: [Location]) {
    if let encodedDivingSite = try? JSONEncoder().encode(divingSite) {
      UserDefaults.standard.set(encodedDivingSite, forKey: "AllLocation")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//    healthKitManager.delegate = self
//    healthKitManager.requestHealthKitPermissions()
//    cloudKitVM.getiCloudStatus()
//    cloudKitVM.requestPermission()
    delegate = self
    divingSiteManager.delegate = self
    divingSiteManager.decodeDivingGeoJSON()
  }

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
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

//  let healthKitManager = HealthKitManger()
//  let cloudKitVM = CloudKitViewModel()
  private let divingSiteManager = DivingSiteManager()

}

// MARK: - TabBarReselectHandling

protocol TabBarReselectHandling {
  func handleReselect()
}

// MARK: HealthManagerDelegate

// extension TabBarController: HealthManagerDelegate {
//
//  func getDepthData(didGet divingData: [DivingLog]) {
//    guard let navigationControllers = viewControllers as? [UINavigationController] else { return }
//    let thirdNavController = navigationControllers[2]
//    guard let activitiesViewController = thirdNavController.viewControllers.first as? ActivitiesViewController else { return }
//    activitiesViewController.setupCollectionView()
//    activitiesViewController.divingLogs = divingData
//    activitiesViewController.filterDivingLogs(forMonth: Date())
//  }
//
//  func getTempData(didGet tempData: [Temperature]) {
//    guard let navigationControllers = viewControllers as? [UINavigationController] else { return }
//    let thirdNavController = navigationControllers[2]
//    guard let activitiesViewController = thirdNavController.viewControllers.first as? ActivitiesViewController else { return }
//    activitiesViewController.temps = tempData
//  }
//
// }