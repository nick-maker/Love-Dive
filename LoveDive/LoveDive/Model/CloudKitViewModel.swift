//
//  CloudkitManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//

import CloudKit
import Foundation

// MARK: - CloudKitError

enum CloudKitError: LocalizedError {
  case iCloudAccountNotFound
  case iCloudAccountNotDetermined
  case iCloudAccountRestricted
  case iCloudAccountUnknown

}

// MARK: - CloudKitViewModel

class CloudKitViewModel {

  // MARK: Internal

  var isSignedInToiCloud = false
  var permissionStatus = false
  var error = ""
  var username = ""

  func getiCloudStatus() {
        CKContainer.default().accountStatus { [weak self] status, _ in
      switch status {
      case .available:
        self?.isSignedInToiCloud = true
      case .noAccount:
        self?.error = CloudKitError.iCloudAccountNotFound.localizedDescription
      case .couldNotDetermine:
        self?.error = CloudKitError.iCloudAccountNotDetermined.localizedDescription
      case .restricted:
        self?.error = CloudKitError.iCloudAccountRestricted.localizedDescription
      default:
        self?.error = CloudKitError.iCloudAccountUnknown.localizedDescription
      }
    }
  }

    func requestPermission() {
      CKContainer.default().requestApplicationPermission([.userDiscoverability]) { status, error in
        DispatchQueue.main.async {
          if status == .granted {
            self.permissionStatus = true
          }
        }
      }
    }

  func fetchiCloudUserRecordID() {
        CKContainer.default().fetchUserRecordID { [weak self] returnedID, error in
      if let error {
        print("Error fetching user record ID: \(error)")
        return
      }
      if let id = returnedID {
        print("THE USER's ID IS \(id)")
        self?.discoveriCloudUser(id: id)
      }
    }
  }

  func discoveriCloudUser(id: CKRecord.ID) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedID, _ in
      DispatchQueue.main.async {
        if let name = returnedID?.nameComponents?.givenName {
          self?.username = name
          print("THE USER's USERNAME IS \(self?.username)")
          self?.saveUser(username: name) { bool in
            bool
          }
        }
      }
    }
  }

  func saveUser(username: String, completion: @escaping (Bool) -> Void) {
    let userRecord = CKRecord(recordType: "User")
    userRecord.setValue(username, forKey: "username")

    CKContainer.default().publicCloudDatabase.save(userRecord) { _, error in
      if let error {
        print("Error saving user: \(error)")
        completion(false)
        return
      }
      completion(true)
    }
  }

  func searchForFriends(withName name: String, completion: @escaping ([CKRecord]?) -> Void) {
    let predicate = NSPredicate(format: "username = %@", name)
    let query = CKQuery(recordType: "User", predicate: predicate)

    CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
      if let error {
        print("Error searching for friends: \(error)")
        completion(nil)
        return
      }
      completion(records)
    }
  }

}
