//
//  LoveDive_WidgetBundle.swift
//  LoveDive Widget
//
//  Created by Nick Liu on 2023/6/29.
//

import SwiftUI
import WidgetKit

@main
struct LoveDive_WidgetBundle: WidgetBundle {
  var body: some Widget {
    LoveDive_WidgetLiveActivity()
    LoveDive_Widget()
  }
}
