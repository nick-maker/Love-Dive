//
//  PictureView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/16.
//

import SwiftUI

// MARK: - PictureView

struct PictureView: View {

  var namespace: Namespace.ID
  @Binding var show: Bool
  var savedImage: Image

  var body: some View {
    VStack {
      Spacer()
    }
    .aspectRatio(1, contentMode: .fill)
    .frame(width: 340, height: 240)
    .background(
      savedImage
        .resizable()
        .aspectRatio(contentMode: .fill)
        .matchedGeometryEffect(id: "image", in: namespace))

    .mask {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: namespace)
    }
  }

}

// MARK: - PictureView_Previews

struct PictureView_Previews: PreviewProvider {

  @Namespace static var namespace

  static var previews: some View {
    PictureView(namespace: namespace, show: .constant(true), savedImage: Image("S__31916048"))
  }
}
