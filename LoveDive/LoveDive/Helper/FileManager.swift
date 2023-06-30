//
//  FileManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/1.
//

import Foundation

public extension FileManager {
  static var documentDirectoryURL: URL {
    return `default`.urls(for: .documentDirectory, in:
    .userDomainMask)[0]
  }
}
