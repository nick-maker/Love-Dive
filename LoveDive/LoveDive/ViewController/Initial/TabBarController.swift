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
      UserDefaults.standard.set(encodedDivingSite, forKey: "allLocation")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
//    healthKitManager.delegate = self
//    healthKitManager.requestHealthKitPermissions()
//    DispatchQueue.main.async {
//    HealthKitManager.shared.requestHealthKitPermissions()
//    }
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

//  private let healthKitManager = HealthKitManger()
  //  let cloudKitVM = CloudKitViewModel()
  private let divingSiteManager = DivingSiteManager()
//  var divingLogs: [DivingLog] = []
//  var temps: [Temperature] = []

}

// MARK: - TabBarReselectHandling

protocol TabBarReselectHandling {
  func handleReselect()
}

// MARK: HealthManagerDelegate

// extension TabBarController: HealthManagerDelegate {
//  func getDepthData(didGet divingData: [DivingLog]) {
////    let group = DispatchGroup()
////    group.enter()
//    divingLogs = divingData
//    DispatchQueue.global().async {
//      if let encodedDepthData = try? JSONEncoder().encode(divingData) {
//        UserDefaults.standard.set(encodedDepthData, forKey: "divingData")
//      }
//    }
////    group.leave()
//  }
//
//  func getTempData(didGet tempData: [Temperature]) {
//    DispatchQueue.global().async {
//      if let encodedTempData = try? JSONEncoder().encode(tempData) {
//        UserDefaults.standard.set(encodedTempData, forKey: "tempData")
//      }
//    }
////    temps = tempData
//  }
// }
