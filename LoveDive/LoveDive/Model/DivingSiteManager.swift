//
//  DivingSiteModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/27.
//

import Foundation

// MARK: - DivingSiteManager

class DivingSiteManager {

  var locations: [Location] = []
  weak var delegate: DivingSiteDelegate?

  func decodeDivingGeoJSON() {
    guard let geoJSONURL = Bundle.main.url(forResource: "TaiwanDivingSite", withExtension: "geojson") else {
      print("Failed to load GeoJSON file")
      return
    }

    do {
      let data = try Data(contentsOf: geoJSONURL)
      let geoJSON = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
      guard let features = geoJSON["features"] as? [[String: Any]] else { return }

      for feature in features {
        guard
          let geometry = feature["geometry"] as? [String: Any],
          let properties = feature["properties"] as? [String: Any],
          let coordinates = geometry["coordinates"] as? [Double],
          let name = properties["name"] as? String
        else {
          continue
        }
        let longitude = coordinates[0]
        let latitude = coordinates[1]
        let location = Location(name: name, latitude: latitude, longitude: longitude, weather: nil)
        locations.append(location)
      }
      delegate?.getDivingSite(didDecode: locations)
    } catch {
      print("Failed to parse GeoJSON file: \(error)")
    }
  }
}

// MARK: - DivingSiteDelegate

protocol DivingSiteDelegate: AnyObject {

  func getDivingSite(didDecode divingSite: [Location])

}
