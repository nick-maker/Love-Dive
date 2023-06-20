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

  var isSignedInToiCloud = false
  var permissionStatus = false
  var error = ""
  var username = ""
  var emailAddress = ""

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
    CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, _ in
      DispatchQueue.main.async {
        if status == .granted {
          self.permissionStatus = true
//          self.fetchiCloudUserRecordID()
        }
      }
    }
  }

//  func fetchiCloudUserRecordID() {
//    CKContainer.default().fetchUserRecordID { [weak self] returnedID, error in
//      if let error {
//        print("Error fetching user record ID: \(error)")
//        return
//      }
//      if let id = returnedID {
//        self?.discoveriCloudUser(id: id)
//      }
//    }
//  }

//  func discoveriCloudUser(id: CKRecord.ID) {
//    CKContainer.default().discoverUserIdentity(withUserRecordID: id) { [weak self] returnedID, _ in
//      DispatchQueue.main.async {
//        if let emailAddress = returnedID?.lookupInfo?.emailAddress {
//          self?.emailAddress = emailAddress
//          self?.saveUser(userEmail: emailAddress) { success in
//            if success {
//              print("User successfully saved")
//            } else {
//              print("Error saving user")
//            }
//          }
//        }
//      }
//    }
//  }
//
//  func saveUser(userEmail: String, completion: @escaping (Bool) -> Void) {
//    searchForFriends(with: userEmail) { records in
//      if let records = records, !records.isEmpty {
//        print("User with email \(userEmail) already exists.")
//        completion(false)
//        return
//      }
//
//      let userRecord = CKRecord(recordType: "User")
//      userRecord.setValue(userEmail, forKey: "userEmail")
//
//      CKContainer.default().publicCloudDatabase.save(userRecord) { _, error in
//        if let error {
//          print("Error saving user: \(error)")
//          completion(false)
//          return
//        }
//        completion(true)
//      }
//    }
//  }

//  func searchForFriends(with email: String, completion: @escaping ([CKRecord]?) -> Void) {
//    let predicate = NSPredicate(format: "userEmail = %@", email)
//    let query = CKQuery(recordType: "User", predicate: predicate)
//
//    CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { records, error in
//      if let error {
//        print("Error searching for friends: \(error)")
//        completion(nil)
//        return
//      }
//      completion(records)
//    }
//  }

}
