//
//  DivingDataLevel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import Foundation

// MARK: - DivingLog

struct DivingLog {

  let startTime: Date
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

  var duration: Double {
    guard let endTime = session.last?.time else {
      return 0.0
    }
    let duration = endTime.timeIntervalSince(startTime)
    return duration
  }

}

// MARK: - DivingEntry

struct DivingEntry: Identifiable {

  var id = UUID().uuidString // to conform identifiable
  let time: Date
  let depth: Double

}

// MARK: - Temperature

struct Temperature {
  let start: Date
  let end: Date
  let temp: Double

}
