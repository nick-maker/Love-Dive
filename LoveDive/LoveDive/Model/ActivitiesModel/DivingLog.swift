//
//  DivingDataLevel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import Foundation

// MARK: - DivingLog

struct DivingLog: Codable {

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
    guard let endTime = session.last?.start else {
      return 0.0
    }
    let duration = endTime.timeIntervalSince(startTime)
    return duration
  }

}

// MARK: - DivingEntry

struct DivingEntry: Codable, Identifiable, Equatable {

  var id = UUID().uuidString // to conform identifiable
  let start: Date
  let depth: Double
  var animate: Bool

}

// MARK: - Temperature

struct Temperature: Codable {
  let start: Date
  let end: Date
  let temp: Double

}
