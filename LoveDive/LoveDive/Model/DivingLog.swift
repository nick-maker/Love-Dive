//
//  DivingDataLevel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import Foundation

struct DivingLog {
  let date: Date
  let maxDepth: Double
  let temperature: Double
  var entries: [DivingEntry]
}

struct DivingEntry {
  let time: Date
  let depth: Double
}
