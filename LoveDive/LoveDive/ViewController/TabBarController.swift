//
//  TabbarController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//

import UIKit

// MARK: - TabBarController

class TabBarController: UITabBarController {

  let healthKitManager = HealthKitManger()
  let cloudKitVM = CloudKitViewModel()

  override func viewDidLoad() {
    super.viewDidLoad()
//    healthKitManager.delegate = self
//    healthKitManager.requestHealthKitPermissions()

    cloudKitVM.getiCloudStatus()
    cloudKitVM.requestPermission()
  }
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
