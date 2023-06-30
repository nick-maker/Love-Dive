//
//  MediaFile.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import SwiftUI

struct MediaFile: Identifiable, Equatable {

  var id = UUID().uuidString
  var image: Image
  var data: Data
//  var filePath: String?

}
