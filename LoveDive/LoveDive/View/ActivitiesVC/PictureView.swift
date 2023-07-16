//
//  PictureView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/16.
//

import SwiftUI

struct PictureView: View {

  var namespace: Namespace.ID
  @Binding var show: Bool
  @Binding var savedImage: Image?

  var body: some View {

    VStack {
      Spacer()
    }
    .frame(width: 340, height: 240)
    .background(
      savedImage?
        .resizable()
        .aspectRatio(contentMode: .fill)
        .matchedGeometryEffect(id: "image", in: namespace))

    .mask {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: namespace)
    }
  }
}

struct PictureView_Previews: PreviewProvider {

  @Namespace static var namespace

  static var previews: some View {
    PictureView(namespace: namespace, show: .constant(true), savedImage: .constant(Image("S__31916048")))
  }
}
