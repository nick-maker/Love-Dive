//
//  PictureDetailView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/16.
//

import SwiftUI

struct PictureDetailView: View {

  var namespace: Namespace.ID
  @Binding var show: Bool
  @Binding var savedImage: Image?
  @Binding var viewSize: CGSize

  var body: some View {
    ZStack {
      ScrollView {
        VStack {
          cover
        }
        .padding(.top, viewSize.width / 4)
      }
      .background(.background)
      .onTapGesture {
        withAnimation(.easeInOut) {
          show.toggle()
        }
      }
    }
  }

  var cover: some View {
    VStack {
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .aspectRatio(1, contentMode: .fill)
    .background(
      savedImage?
        .resizable()
        .aspectRatio(contentMode: .fill)
        .matchedGeometryEffect(id: "image", in: namespace))
  
    .mask {
      RoundedRectangle(cornerRadius: 0, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: namespace)
    }
  }
}

struct PictureDetailView_Previews: PreviewProvider {

  @Namespace static var namespace

  static var previews: some View {
    PictureDetailView(namespace: namespace, show: .constant(true), savedImage: .constant(Image("S__31916048")), viewSize: .constant(CGSize()))
  }
}
