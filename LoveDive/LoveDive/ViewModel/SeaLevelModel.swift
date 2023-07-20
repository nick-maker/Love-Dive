//
//  SeaLevelViewModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/7.
//

import Alamofire
import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

class SeaLevelModel: ObservableObject {

  @Published var seaLevel: [SeaLevel] = []

  let UTCFormatter = ISO8601DateFormatter()
  let calendar = Calendar.current
  let currentTime = Date()
  let tenDaysSeaLevel = Firestore.firestore().collection("tenDaysSeaLevel")

  func getTenDaysSeaLevel(lat: Double, lng: Double) {
    let key = "seaLevel\(lat),\(lng)"
    if
      let cachedData = UserDefaults.standard.object(forKey: key) as? Data,
      let tideCache = try? JSONDecoder().decode(TideCache.self, from: cachedData),
      currentTime.timeIntervalSince(UTCFormatter.date(from: tideCache.timestamp) ?? Date()) < 3600 * 24,
      !tideCache.seaLevel.isEmpty
    {
      seaLevel = tideCache.seaLevel
    } else {
      Task {
        do {
          try await getFromFirebase(lat: lat, lng: lng, key: key)
        }
        catch {
          self.getFromAPI(lat: lat, lng: lng, key: key)
        }
      }
    }
  }

  func seaLevelDocument(lat: Double, lng: Double) -> DocumentReference {
    let key = "seaLevel\(lat),\(lng)"
    let startTime = calendar.startOfDay(for: currentTime)
    return tenDaysSeaLevel.document(key).collection(startTime.description).document(key)
  }

  func getFromFirebase(lat: Double, lng: Double, key: String) async throws {
    let data = try await seaLevelDocument(lat: lat, lng: lng).getDocument(as: TideData.self)
    DispatchQueue.main.async {
      self.seaLevel = data.data
    }
    saveToUserDefault(value: data, key: key)
  }

  func getFromAPI(lat: Double, lng: Double, key: String) {
    let params: [String: Any] = [
      "lat": lat,
      "lng": lng,
    ]

    let headers: HTTPHeaders = [
      "Authorization": Config.weatherAPIKey,
    ]

    AF.request("https://api.stormglass.io/v2/tide/sea-level/point", method: .get, parameters: params, headers: headers)
      .validate()
      .responseDecodable(of: TideData.self) { response in
        switch response.result {
        case .success(let value):
          if !value.data.isEmpty {
            self.seaLevel = value.data
            self.saveToUserDefault(value: value, key: key)
            Task {
              do {
                try await self.saveToFirebase(lat: lat, lng: lng, data: value)
              }
            }
          }
        case .failure(let error):
          print("Error: \(error)")
        }
      }
  }

  func saveToUserDefault(value: TideData, key: String) {
    let tideCache = TideCache(timestamp: (value.data.first?.time)!, seaLevel: value.data)
    if let encodedCacheData = try? JSONEncoder().encode(tideCache) {
      // Save the encoded Data to UserDefaults
      UserDefaults.standard.set(encodedCacheData, forKey: key)
    }
  }

  func saveToFirebase(lat: Double, lng: Double, data: TideData) async throws {
    try seaLevelDocument(lat: lat, lng: lng).setData(from: data)
  }

  // MARK: - For preview
  func decodeJSON() -> TideData {
    guard let url = Bundle.main.url(forResource: "SeaLevel", withExtension: "json") else {
      return TideData(data: [])
    }
    do {
      let data = try Data(contentsOf: url)
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(TideData.self, from: data)
      return decodedData
    } catch {
      return TideData(data: [])
    }
  }
}
