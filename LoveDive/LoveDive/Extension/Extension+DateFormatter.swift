//
//  Extension+DateFormatter.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/8/14.
//

import Foundation

extension Formatter {

  static let timeFormatter: DateFormatter = {
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "hh:mm:ss a"
    timeFormatter.locale = Locale.current
    return timeFormatter
  }()

  static let yearFormatter: DateFormatter = {
    let yearFormatter = DateFormatter()
    yearFormatter.dateFormat = "yyyy/MM/dd"
    yearFormatter.locale = Locale.current
    return yearFormatter
  }()

  static let titleFormatter: DateFormatter = {
    let titleFormatter = DateFormatter()
    titleFormatter.dateFormat = "MMM dd"
    titleFormatter.locale = Locale.current
    return titleFormatter
  }()

  static let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd, ha"
    dateFormatter.locale = Locale.current
    return dateFormatter
  }()

  static let utc = ISO8601DateFormatter()

}
