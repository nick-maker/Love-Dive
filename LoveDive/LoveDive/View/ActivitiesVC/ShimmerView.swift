//
//  ShimmerView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/15.
//

import SwiftUI

// MARK: - ShimmerView

struct ShimmerView: View {

  @State var show = false
  @Environment(\.colorScheme) var colorScheme

  var center = UIScreen.main.bounds.width / 2 + 110

  var body: some View {
    ZStack {
      RoundedRectangle(cornerRadius: 20)
        .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.black.opacity(0.09))
        .frame(width: 340, height: 240)
        .aspectRatio(0.75, contentMode: .fill)

      RoundedRectangle(cornerRadius: 20)
        .fill(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.4))
        .frame(width: 340, height: 240)
        .aspectRatio(0.75, contentMode: .fill)
        .mask(
          LinearGradient(
            gradient: Gradient(colors: [Color.clear, colorScheme == .dark ? Color.black.opacity(0.5) : Color.white, Color.clear]),
            startPoint: .top,
            endPoint: .bottom)
            .rotationEffect(.degrees(90))
            .offset(x: show ? center : -center))
    }
    .onAppear {
      withAnimation(Animation.default.speed(0.3).delay(0).repeatCount(5)) {
        show.toggle()
      }
    }
  }
}

// MARK: - ShimmerView_Previews

struct ShimmerView_Previews: PreviewProvider {
  static var previews: some View {
    ShimmerView()
  }
}
