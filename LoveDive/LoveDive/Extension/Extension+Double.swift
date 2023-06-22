//
//  Extension+Doubel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/22.
//

import Foundation

extension Double {

  func durationFormatter() -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute, .second]
    formatter.unitsStyle = .short

    let formattedString = formatter.string(from: TimeInterval(self))
    return formattedString ?? ""
  }

}
