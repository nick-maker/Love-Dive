//
//  CloudkitManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/19.
//

import Foundation
import CloudKit

class CloudKitViewModel {

  @Published var isSignedInToiCloud: Bool = false
  @Published var error: String = ""

  func getiCloudStatus() {
    CKContainer.default().accountStatus { [weak self] status, error in
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

  enum CloudKitError: LocalizedError {
    case iCloudAccountNotFound
    case iCloudAccountNotDetermined
    case iCloudAccountRestricted
    case iCloudAccountUnknown

  }

}
