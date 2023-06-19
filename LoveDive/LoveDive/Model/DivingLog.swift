//
//  DivingDataLevel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import Foundation

// MARK: - DivingLog

struct DivingLog {
  let date: Date
  var session: [DivingEntry]

  var maxDepth: Double {
    var maxDepth = 0.0
    for entry in session {
      if entry.depth > maxDepth {
        maxDepth = entry.depth
      }
    }
    return maxDepth
  }
}

// MARK: - DivingEntry

struct DivingEntry {
  let time: Date
  let depth: Double
}

struct Temperature {
    let start : Date
    let end : Date
    let temp: Double

}
