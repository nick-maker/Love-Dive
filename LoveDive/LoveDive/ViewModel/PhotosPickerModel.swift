//
//  PhotosPickerModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import PhotosUI
import SwiftUI

class PhotosPickerModel: ObservableObject {
  // Mark: Loaded Images
  @Published var loadedImages: [MediaFile] = []

  // Mark: Selected Photo
  @Published var selectedPhoto: PhotosPickerItem? {
    didSet {
      // Mark: If photo is selected, then processing the image
      if let selectedPhoto {
        processPhoto(photo: selectedPhoto)
      }
    }
  }

  func processPhoto(photo: PhotosPickerItem) {
    // Mark: Extracting image data
    photo.loadTransferable(type: Data.self) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let data):
          if let data, let image = UIImage(data: data) {
            self.loadedImages.append(.init(image: Image(uiImage: image), data: data))
          }
        case .failure(let failure):
          print(failure)
        }
      }
    }
  }

}
