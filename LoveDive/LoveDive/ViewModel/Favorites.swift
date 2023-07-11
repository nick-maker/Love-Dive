//
//  File.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/10.
//

import Combine
import Foundation

// MARK: - Favorites

class Favorites: ObservableObject {

  // MARK: Lifecycle

  init() {
    favorites = Set(UserDefaults.standard.stringArray(forKey: saveKey) ?? [])
  }

  // MARK: Internal

  @Published var favorites: Set<String>

  func contains(_ divingSite: Location) -> Bool {
    favorites.contains(divingSite.id)
  }

  func add(_ divingSite: Location) {
    objectWillChange.send()
    favorites.insert(divingSite.id)
    save()
  }

  func remove(_ divingSite: Location) {
    objectWillChange.send()
    favorites.remove(divingSite.id)
    save()
  }

  func save() {
    UserDefaults.standard.set(Array(favorites), forKey: saveKey)
  }

  // MARK: Private

  private let saveKey = "favorites"

}
