//
//  LocationManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/28.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {

  let manager = CLLocationManager()

  var completion: ((CLLocation) -> Void)?

  func getUserLocation(completion: @escaping ((CLLocation) -> Void)) {
    self.completion = completion
    manager.requestWhenInUseAuthorization()
    manager.delegate = self
    manager.startUpdatingLocation()

  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }

    completion?(location)
    manager.stopUpdatingLocation()
  }


}
