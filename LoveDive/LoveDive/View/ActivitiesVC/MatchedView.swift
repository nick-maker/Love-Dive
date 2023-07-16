//
//  SwiftUIView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/15.
//

import SwiftUI

// MARK: - MatchedView

struct MatchedView: View {

  // MARK: Internal

  @Namespace var namespace
  @State var expandedImage: Image?
  @State var isExpanded = false
  @State var loadExpandedContent = false
  @State var viewSize = CGSize()

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Rectangle()
          .fill(.background)
          .cornerRadius(20)
          .opacity(loadExpandedContent ? 1 : 0)
          .ignoresSafeArea()
        HStack {
          Spacer()
          pictureView
          Spacer()
        }
      }
      .onAppear {
        viewSize = proxy.size
      }
    }
    .overlay {
      if let expandedImage, isExpanded {
        expandedView(image: expandedImage)
      }
    }
  }

  var pictureView: some View {
    VStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(.clear)
        .frame(width: 320, height: 240)
        .background(
          Image("S__31916048")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .matchedGeometryEffect(id: "image", in: namespace))
    }
    .mask {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: namespace)
    }
    .padding(.horizontal)
    .onTapGesture {
      withAnimation(.easeInOut(duration: 1.5)) {
        isExpanded = true
        expandedImage = Image("S__31916048")
      }
    }
  }

  // MARK: Private

  @ViewBuilder
  private func expandedView(image _: Image) -> some View {
    VStack {
      Spacer()
      RoundedRectangle(cornerRadius: 20)
        .fill(.clear)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          Image("S__31916048")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .matchedGeometryEffect(id: "image", in: namespace))
    }
    .mask {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .matchedGeometryEffect(id: "mask", in: namespace)
    }
    .onAppear {
      withAnimation(.easeInOut(duration: 0.7)) {
        loadExpandedContent = true
      }
    }
    .onTapGesture {
      withAnimation(.easeInOut(duration: 0.6)) {
        loadExpandedContent = false
      }
      withAnimation(.easeInOut(duration: 0.6).delay(0.05)) {
        isExpanded = false
      }
    }
  }
}

// MARK: - MatchedView_Previews

struct MatchedView_Previews: PreviewProvider {
  static var previews: some View {
    MatchedView()
  }
}
