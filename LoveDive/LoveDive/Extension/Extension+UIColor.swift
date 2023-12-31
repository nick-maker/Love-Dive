//
//  Extension.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/15.
//

import Foundation
import SwiftUI
import UIKit

extension UIColor {

  static var dynamicColor = UIColor { traits in
    if traits.userInterfaceStyle == .dark {
      return UIColor(red: 0.2, green: 0.24, blue: 0.27, alpha: 0.5) // Dark mode color
    } else {
      return UIColor.white // Light mode color
    }
  }

  static var dynamicColor2 = UIColor { traits in
    if traits.userInterfaceStyle == .dark {
      return UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
    } else {
      return UIColor.white // Light mode color
    }
  }

  static var dynamicColor3 = UIColor { traits in
    if traits.userInterfaceStyle == .dark {
      return UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
    } else {
      return UIColor.black // Light mode color
    }
  }

  static var tapColor = UIColor { traits in
    if traits.userInterfaceStyle == .dark {
      return UIColor.darkGray
    } else {
      return UIColor.paleGray.withAlphaComponent(0.7)
    }
  }

  static var pacificBlue: UIColor {
    UIColor(red: 0.094, green: 0.643, blue: 0.882, alpha: 1)
  }

  static var darkBlue: UIColor {
    UIColor(red: 0.02, green: 0.2, blue: 0.325, alpha: 1)
  }

  static var grayBlue: UIColor {
    UIColor(red: 0.678, green: 0.792, blue: 0.871, alpha: 1)
  }

  static var lightBlue: UIColor {
    UIColor(red: 0.89, green: 0.931, blue: 0.958, alpha: 1)
  }

  static var paleGray: UIColor {
    UIColor(red: 224 / 253, green: 224 / 253, blue: 224 / 253, alpha: 1)
  }

}

extension Color {
  static var pacificBlue: Color {
    Color(red: 0.094, green: 0.643, blue: 0.882)
  }

  static var darkBlue: Color {
    Color(red: 0.02, green: 0.2, blue: 0.325)
  }

  static var deepBlue: Color {
    Color(red: 0.2, green: 0.24, blue: 0.27)
  }

  static var paleGray: Color {
    Color(red: 224 / 253, green: 224 / 253, blue: 224 / 253)
  }

  static var lightBlue: Color {
    Color(red: 0.89, green: 0.931, blue: 0.958)
  }

}
