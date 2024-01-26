//
//  Extension + View.swift
//  LoveDive
//
//  Created by Nick Liu on 2024/1/22.
//

import SwiftUI

extension View {
  func widgetBackground(_ backgroundView: some View) -> some View {
    if #available(iOS 17, *) {
      return containerBackground(for: .widget) {
        backgroundView
      }
    } else {
      return background(backgroundView)
    }
  }
}
