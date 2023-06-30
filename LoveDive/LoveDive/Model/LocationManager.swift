//
//  LocationManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/28.
//

import CoreLocation
import Foundation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {

  // MARK: Internal

  let manager = CLLocationManager()

  var completion: ((CLLocation) -> Void)?

  weak var errorPresentationTarget: UIViewController?

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

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    let status = manager.authorizationStatus
    if status == .denied {
      displayLocationServicesDeniedAlert()
    }
  }

  func locationManager(_: CLLocationManager, didFailWithError _: Error) {
    // Handle any errors that `CLLocationManager` returns.
  }

  // MARK: Private

  private func displayLocationServicesDeniedAlert() {
    let message = String(localized: "Turn On Location Services to Allow Love Dive to Determine Your Location")
    let alertController = UIAlertController(
      title: String(localized: "Location Services Are Off"),
      message: message,
      preferredStyle: .alert)
    let settingsButtonTitle = String(localized: "Setting")
    let openSettingsAction = UIAlertAction(title: settingsButtonTitle, style: .default) { _ in
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        // Take the user to the Settings app to change permissions.
        UIApplication.shared.open(settingsURL, options: [:]) { _ in
          // Add any additional code to run after this method completes here.
        }
      }
    }

    let cancelButtonTitle = String(localized: "Cancel")
    let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
      // Add any additional button-handling code here.
    }

    alertController.addAction(cancelAction)
    alertController.addAction(openSettingsAction)
    errorPresentationTarget?.present(alertController, animated: true, completion: nil)
  }
}
