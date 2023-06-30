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
  @Published var selectedPhoto: PhotosPickerItem?
  //  {
  //    didSet {
  //      // Mark: If photo is selected, then processing the image
  //      if let selectedPhoto {
  //        processPhoto(photo: selectedPhoto)
  //      }
  //    }
  //  }

  //  func processPhoto(photo: PhotosPickerItem) {
  //    // Mark: Extracting image data
  //    photo.loadTransferable(type: Data.self) { result in
  //      DispatchQueue.main.async {
  //        switch result {
  //        case .success(let data):
  //          if let data, let image = UIImage(data: data) {
  //            self.loadedImages.append(.init(image: Image(uiImage: image), data: data))
  //          }
  //        case .failure(let failure):
  //          print(failure)
  //        }
  //      }
  //    }
  //  }

  func processPhoto(photo: PhotosPickerItem, divingDate: Date) {
    // Mark: Extracting image data
    photo.loadTransferable(type: Data.self) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let data):
          if let data, let image = UIImage(data: data) {
            self.saveImageToDocumentsDirectory(image: image, filePath: divingDate.description)
            let mediaFile = MediaFile(image: Image(uiImage: image), data: data)
            self.loadedImages.append(mediaFile)
          }
        case .failure(let failure):
          print(failure)
        }
      }
    }
  }

  func saveImageToDocumentsDirectory(image: UIImage, filePath: String) {
    guard let data = image.jpegData(compressionQuality: 0.8) else {
      return
    }

    let fileURL = FileManager.documentDirectoryURL.appendingPathComponent(filePath)

    do {
      try data.write(to: fileURL)
      print("Success saving images.")

    } catch {
      print("Error saving image: \(error)")

    }
  }

  func getImageFromFileManager(filePath: String) -> Image? {

    let fileURL = FileManager.documentDirectoryURL.appendingPathComponent(filePath)
    let path = fileURL.path
    guard FileManager.default.fileExists(atPath: path) else {
      print("Error: Image file not found at \(path)")
      return nil
    }

    if let uiImage = UIImage(contentsOfFile: path) {
      return Image(uiImage: uiImage)
    } else {
      print("Error: Failed to create UIImage from file at \(path)")
      return nil
    }
  }

}
