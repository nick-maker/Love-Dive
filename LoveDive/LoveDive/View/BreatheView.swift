//
//  Home.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import AVFoundation
import SwiftUI

// MARK: - BreatheView

struct BreatheView: View {

  // MARK: Internal

  @EnvironmentObject var breatheModel: BreatheModel
  @EnvironmentObject var audioModel: AudioModel

  var body: some View {
    VStack {
      GeometryReader { proxy in
        VStack(spacing: 15) {
          ZStack {
            Circle()
              .fill(.blue.opacity(0.03))
              .padding(-40)
            Circle()
              .trim(from: 0, to: breatheModel.progress)
              .stroke(Color.blue.opacity(0.03), lineWidth: 80)
              .blur(radius: 15)
            // Mark: Shadow
            Circle()
              .stroke(Color.pacificBlue, lineWidth: 5)
              .blur(radius: 15)
              .padding(-2)
            Circle()
              .fill(.white)
            if breatheModel.isStarted {
              LottieView()
                .scaleEffect(1.2)
            }
            Circle()
              .trim(from: 0, to: breatheModel.progress)
              .stroke(Color.pacificBlue.opacity(0.6), lineWidth: 7)

            // Mark: Knob
            GeometryReader { proxy in
              let size = proxy.size

              Circle()
                .fill(Color.pacificBlue.opacity(0.6))
                .frame(width: 30, height: 30)
                .overlay(content: {
                  Circle()
                    .fill(.white)
                    .padding(5)
                })
                .frame(width: size.width, height: size.height, alignment: .center)
                .offset(x: size.height / 2)
                .rotationEffect(.init(degrees: breatheModel.progress * 360))
            }
            Text(breatheModel.timerStringValue)
              .font(.system(size: 45, design: .rounded))
              .foregroundColor(breatheModel.isStarted ? .white : .darkBlue)
              .rotationEffect(.init(degrees: 90))
              .animation(.none, value: breatheModel.progress)
          }
          .padding(30)
          .frame(height: proxy.size.width)
          .rotationEffect(.init(degrees: -90))
          .animation(.easeInOut, value: breatheModel.progress)
          .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

          Button {
            if breatheModel.isStarted {
              breatheModel.stopTimer()
              audioModel.stopPlayer()
              UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            } else {
              breatheModel.addNewTimer = true
              isPresentingNewTimerView = true
            }
          } label: {
            Image(systemName: !breatheModel.isStarted ? "circle.and.line.horizontal" : "stop.fill")
              .font(.largeTitle)
              .foregroundColor(.pacificBlue.opacity(0.6))
              .frame(width: 80, height: 80)
              .background {
                Circle()
                  .fill(.blue.opacity(0.03))
              }
              .shadow(color: .pacificBlue, radius: 20, x: 0, y: 0)
          }
          .padding(.bottom, 20)
        }
        .onTapGesture {
          //          breatheModel.progress = 0.5
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
    .sheet(isPresented: $isPresentingNewTimerView) {
      NewTimerView()
        .environmentObject(breatheModel)
        .environmentObject(audioModel)
        .presentationDetents([.fraction(0.35)])
        .presentationCornerRadius(20)
    }
    .padding()
//    .background {
//      (Color.white)
//        .ignoresSafeArea()
//    }
//    .overlay(content: {
//      ZStack {
//        Color.black
//          .opacity(breatheModel.addNewTimer ? 0.25 : 0)
//          .onTapGesture {
//            breatheModel.minute = 0
//            breatheModel.seconds = 0
//            breatheModel.addNewTimer = false
//          }
//          .ignoresSafeArea()
//
    ////        NewTimerView()
    ////          .frame(maxHeight: .infinity, alignment: .bottom)
    ////          .offset(y: breatheModel.addNewTimer ? 0 : 500)
    ////        if breatheModel.addNewTimer {
    ////          NewTimerView()
    ////            .transition(.move(edge: .bottom))
    ////        }
//      }
//      .animation(.easeInOut, value: breatheModel.addNewTimer)
//    })
    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
      if breatheModel.isStarted {
        breatheModel.updateTimer()
      }
      if breatheModel.isFinished {
        audioModel.stopPlayer()
      }
    }
    .alert("Congratulations",isPresented: $breatheModel.isFinished) {
      Button("Start New", role: .cancel) {
        breatheModel.stopTimer()
        breatheModel.addNewTimer = true
      }
      Button("Close", role: .destructive) {
        breatheModel.stopTimer()
      }
    }
  }

  // Mark: New Timer Bottom Sheet
  @ViewBuilder
  func NewTimerView() -> some View {
    VStack {
      Text("Add New Timer")
        .font(.system(size: 20, design: .rounded))
        .bold()
        .foregroundColor(.pacificBlue)
        .padding(.top, 30)

      HStack {
        Picker("Minutes", selection: $breatheModel.minute) {
          ForEach(Array(stride(from: 0, to: 65, by: 5)), id: \.self) { minute in
            Text("\(minute) min").tag(minute)
          }
        }
        .pickerStyle(.inline)
        .frame(width: 150, height: 120)
        .font(.title3)
        .fontWeight(.semibold)

        Picker("Seconds", selection: $breatheModel.seconds) {
          ForEach(Array(stride(from: 0, to: 60, by: 15)), id: \.self) { second in
            Text("\(second) sec").tag(second)
          }
        }
        .pickerStyle(.inline)
        .frame(width: 150, height: 120)
        .font(.title3)
        .fontWeight(.semibold)
      }
      Button {
        breatheModel.startTimer()
        isPresentingNewTimerView = false
        audioModel.startPlayer(track: "Artlist Original - Tel Aviv Ambiences - Beach Ambience Waves Lapping Windy")
      } label: {
        Text("Start")
          .font(.title3)
          .fontWeight(.semibold)
          .foregroundColor(.white)
          .padding(.vertical)
          .padding(.horizontal, 100)
          .background {
            Capsule()
              .fill(Color.pacificBlue)
          }
      }
      .padding(.bottom, 20)
      .disabled(breatheModel.seconds == 0 && breatheModel.minute == 0)
      .opacity(breatheModel.seconds == 0 && breatheModel.minute == 0 ? 0.5 : 1)
    }
    .frame(maxWidth: .infinity)
    .background {
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(Color.white)
        .ignoresSafeArea()
    }
    .frame(maxHeight: .infinity, alignment: .bottom)
  }

  // Mark: reusable context menu options
//  @ViewBuilder
//  func contextMenuOptions(maxValue: Int, hint: String, onClick: @escaping (Int) -> Void) -> some View {
//    ForEach(0...maxValue, id: \.self) { value in
//      Button("\(value) \(hint)") {
//        onClick(value)
//      }
//    }
//  }

  // MARK: Private

  @State private var isPresentingNewTimerView = false

}

// MARK: - Breathe_Previews

struct Breathe_Previews: PreviewProvider {
  static var previews: some View {
    BreatheContentView()
      .environmentObject(BreatheModel())
      .environmentObject(AudioModel())
  }
}
