//
//  PersonalBestModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/18.
//

import SwiftUI

class PersonalBestModel: NSObject, ObservableObject {

  // MARK: Lifecycle

  override init() {
    if
      let defaults,
      let data = defaults.data(forKey: saveKey)
    {
      do {
        personalBest = try JSONDecoder().decode(DivingLog.self, from: data)
      } catch {
        personalBest = nil
      }
    }
  }

  // MARK: Internal

  let defaults = UserDefaults(suiteName: "group.shared.LoveDive")

  var personalBest: DivingLog?

  func save(_ divingLog: DivingLog) {
//    UserDefaults.standard.removeObject(forKey: saveKey)
    if
      let encodedData = try? JSONEncoder().encode(divingLog),
      let defaults
    {
      defaults.set(encodedData, forKey: saveKey)
    }
  }

  // MARK: Private

  private let saveKey = "personalBest"

}
