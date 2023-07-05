//
//  PhotosPickerModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//
// swiftlint:disable next no_direct_standard_out_logs
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

class PhotosPickerModel: ObservableObject {
  // Mark: Loaded Images
  @Published var loadedImages: [MediaFile] = []

  @Published var imageData = Data(count: 0)
  // Mark: Selected Photo
  @Published var selectedPhoto: PhotosPickerItem?

  @Published var allImages: [FilteredImage] = []

  @Published var mainView: FilteredImage?

  @Published var value: CGFloat = 1.0

  @Published var hasSavedImage = false

  let filters: [CIFilter] = [
    CIFilter.photoEffectChrome(),
    CIFilter.photoEffectFade(),
    CIFilter.photoEffectInstant(),
    CIFilter.photoEffectMono(),
    CIFilter.photoEffectNoir(),
  ]

  let serialQueue = DispatchQueue(label: "com.yourdomain.appname.filterQueue")

  func cgImagePropertyOrientation(from image: UIImage) -> CGImagePropertyOrientation {
    switch image.imageOrientation {
    case .up: return .up
    case .down: return .down
    case .left: return .left
    case .right: return .right
    case .upMirrored: return .upMirrored
    case .downMirrored: return .downMirrored
    case .leftMirrored: return .leftMirrored
    case .rightMirrored: return .rightMirrored
    @unknown default:
      fatalError("Unknown image orientation")
    }
  }

  func ciImage(from image: UIImage) -> CIImage? {
    if let cgImage = image.cgImage {
      let ciImage = CIImage(cgImage: cgImage)
      return ciImage.oriented(cgImagePropertyOrientation(from: image))
    } else if let ciImage = image.ciImage {
      return ciImage.oriented(cgImagePropertyOrientation(from: image))
    } else {
      return nil
    }
  }

  func loadFilter() {
    let context = CIContext()

    guard
      let image = UIImage(data: imageData),
      let ciImage = ciImage(from: image),
      let cgimage = context.createCGImage(ciImage, from: ciImage.extent) else { return }

    let originalData = FilteredImage(image: UIImage(cgImage: cgimage), filter: nil, isEditable: false)
    DispatchQueue.main.async {
      self.allImages.append(originalData)
    }

    filters.forEach { filter in
      serialQueue.async {
        guard let ciImage = self.ciImage(from: image) else { return }
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        // retrieve image
        guard
          let newImage = filter.outputImage,
          let cgimage = context.createCGImage(newImage, from: newImage.extent) else { return }

        let isEditable = filter.inputKeys.count > 1
        let filteredData = FilteredImage(image: UIImage(cgImage: cgimage), filter: filter, isEditable: isEditable)
        DispatchQueue.main.async {
          self.allImages.append(filteredData)
          self.mainView = self.allImages.first
        }
      }
    }
  }

  func updateEffect() {
    guard
      var mainView,
      let filter = mainView.filter,
      let image = UIImage(data: imageData),
      ciImage(from: image) != nil else { return }

    DispatchQueue.global(qos: .userInteractive).async {
      let context = CIContext()

      if filter.inputKeys.contains("inputRadiusKey") {
        filter.setValue(self.value * 10, forKey: kCIInputRadiusKey)
      }

      if filter.inputKeys.contains("inputIntensityKey") {
        filter.setValue(self.value, forKey: kCIInputIntensityKey)
      }

      guard
        let newImage = filter.outputImage,
        let cgimage = context.createCGImage(newImage, from: newImage.extent) else { return }

      DispatchQueue.main.async {
        mainView.image = UIImage(cgImage: cgimage)
      }
    }
  }

  func processPhoto(photo: PhotosPickerItem) {
    // Mark: Extracting image data
    photo.loadTransferable(type: Data.self) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let data):
          if let data {
            self.imageData = data
            if let image = UIImage(data: data) {
              let mediaFile = MediaFile(image: Image(uiImage: image), data: data)
              self.loadedImages.append(mediaFile)
            }
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
      hasSavedImage = true

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
