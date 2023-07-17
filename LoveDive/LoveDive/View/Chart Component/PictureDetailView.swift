//
//  PictureDetailView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/16.
//

import SwiftUI

// MARK: - PictureDetailView

struct PictureDetailView: View {

  var namespace: Namespace.ID
  @Binding var show: Bool
  @Binding var isExpanded: Bool
  var savedImage: Image
  @Binding var viewSize: CGSize

  var body: some View {
    ScrollView {
      VStack {
        cover
      }
      .padding(.top, viewSize.width / 4)
      .onTapGesture {
        withAnimation(.easeInOut) {
          show.toggle()
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8).delay(0.15)) {
          isExpanded.toggle()
        }
      }
    }
    .background(.background)
  }

  var cover: some View {
    VStack {
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .aspectRatio(1, contentMode: .fill)
    .background(
      savedImage
        .resizable()
        .aspectRatio(contentMode: .fill)
        .matchedGeometryEffect(id: "image", in: namespace))
    .mask {
      RoundedRectangle(cornerRadius: 0, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: namespace)
    }
  }

}

// MARK: - PictureDetailView_Previews

struct PictureDetailView_Previews: PreviewProvider {

  @Namespace static var namespace

  static var previews: some View {
    PictureDetailView(
      namespace: namespace,
      show: .constant(true),
      isExpanded: .constant(true),
      savedImage: Image("S__31916048"),
      viewSize: .constant(CGSize()))
  }
}
