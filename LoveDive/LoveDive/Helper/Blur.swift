//
//  Blur.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/6.
//

import SwiftUI

// MARK: - UIBackdropView

class UIBackdropView: UIView {
  override class var layerClass: AnyClass {
    NSClassFromString("CABackdropLayer") ?? CALayer.self
  }
}

// MARK: - Backdrop

struct Backdrop: UIViewRepresentable {

  func makeUIView(context _: Context) -> UIBackdropView {
    UIBackdropView()
  }

  func updateUIView(_: UIBackdropView, context _: Context) { }

}

// MARK: - Blur

struct Blur: View {

  var radius: CGFloat = 3
  var opaque = false

  var body: some View {
    Backdrop()
      .blur(radius: radius, opaque: opaque)
  }
}

// MARK: - Blur_Previews

struct Blur_Previews: PreviewProvider {
  static var previews: some View {
    Blur()
  }
}
