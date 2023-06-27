//
//  LottieView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/27.
//

import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
  
  var lottieFile = "70733-simple-breathing-animation"
  var loopMode: LottieLoopMode = .loop
  
  func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
    let view = UIView(frame: .zero)
    
    let animationView = LottieAnimationView(name: lottieFile)
    animationView.contentMode = .scaleToFill
    animationView.loopMode = loopMode
    animationView.animationSpeed = 0.5
    animationView.play { (finished) in
    }
    
    animationView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(animationView)
    NSLayoutConstraint.activate([
      animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
      animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
    
    return view
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
  }
  
}
