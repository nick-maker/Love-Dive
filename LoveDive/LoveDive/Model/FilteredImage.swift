//
//  FilteredImage.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/1.
//

import SwiftUI
import CoreImage

struct FilteredImage: Identifiable, Equatable {

  var id = UUID().uuidString
  var image: UIImage
  var filter: CIFilter?
  var isEditable: Bool

  var filterName: String {
      guard let filter = filter else { return "Original" }

      switch filter.name {
      case "CIPhotoEffectChrome":
          return "Chrome"
      case "CIPhotoEffectFade":
          return "Fade"
      case "CIPhotoEffectInstant":
          return "Instant"
      case "CIPhotoEffectMono":
          return "Mono"
      case "CIPhotoEffectNoir":
          return "Noir"
      default:
          return filter.name
      }
    }
}
