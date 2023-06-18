//
//  DayLabel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/17.
//

import HorizonCalendar
import UIKit

// MARK: - DayLabel

struct DayLabel: CalendarItemViewRepresentable {

  /// Properties that are set once when we initialize the view.
  struct InvariantViewProperties: Hashable {
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
  }

  /// Properties that will vary depending on the particular date being displayed.
  struct Content: Equatable {
    let day: Day
    let hasDivingData: Bool
  }

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
  {
    let label = CircleLabel()

    label.backgroundColor = invariantViewProperties.backgroundColor
    label.font = invariantViewProperties.font
    label.textColor = invariantViewProperties.textColor

    label.textAlignment = .center
    return label
  }

  static func setContent(_ content: Content, on view: UILabel) {
    view.text = "\(content.day.day)"
    if content.hasDivingData {
      view.backgroundColor = UIColor.pacificBlue
    } else {
      view.backgroundColor = UIColor.clear
    }
  }

}

// MARK: - CircleLabel

class CircleLabel: UILabel {

  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = bounds.height / 2
    clipsToBounds = true
  }

}
