//
//  FileManager.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/1.
//

import Foundation

extension FileManager {
  public static var documentDirectoryURL: URL {
    `default`.urls(
      for: .documentDirectory,
      in:
      .userDomainMask)[0]
  }
}
