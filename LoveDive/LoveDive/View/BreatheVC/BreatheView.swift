//
//  Home.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import ActivityKit
import AVFoundation
import SwiftUI

// MARK: - BreatheView

struct BreatheView: View {

  // MARK: Internal
  @State private var activity: Activity<TimerAttributes>? = nil
  @EnvironmentObject var breatheModel: BreatheModel
  @EnvironmentObject var audioModel: AudioModel
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    VStack {
      GeometryReader { proxy in
        VStack(spacing: 25) {
          ZStack {
            if breatheModel.isStarted {
              LottieView()
            }
            Circle()
              .stroke(
                colorScheme == .dark ? Color.darkBlue : Color.pacificBlue.opacity(0.5),
                style: StrokeStyle(
                  lineWidth: 12,
                  lineCap: .round))
              .padding(10)

            Circle()
              .trim(from: 0, to: breatheModel.progress)
              .stroke(
                Color.pacificBlue.gradient,
                style: StrokeStyle(
                  lineWidth: 12,
                  lineCap: .round))
              .padding(10)

            Text(breatheModel.timerStringValue)
              .font(.system(size: 45, design: .rounded))
              .foregroundColor(breatheModel.isStarted ? .white : colorScheme == .dark ? Color.white : .black)
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
              stopActivity()
              audioModel.stopPlayer()
              UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            } else {
              breatheModel.addNewTimer = true
              isPresentingNewTimerView = true
            }
          } label: {
            Text(!breatheModel.isStarted ? "Start" : "Stop")
              .font(.title2)
              .fontDesign(.rounded)
              .bold()
              .foregroundColor(!breatheModel.isStarted ? .white : Color.pacificBlue)
              .frame(width: 80, height: 80)
              .background {
                Circle()
                  .fill(!breatheModel.isStarted ? Color.pacificBlue : Color.pacificBlue.opacity(0.3))
              }
          }
          .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
      }
    }
    .sheet(isPresented: $isPresentingNewTimerView) {
      if #available(iOS 16.4, *) {
        NewTimerView()
          .environmentObject(breatheModel)
          .environmentObject(audioModel)
          .presentationDetents([.fraction(0.35)])
          .presentationCornerRadius(20)
      } else {
        NewTimerView()
          .environmentObject(breatheModel)
          .environmentObject(audioModel)
          .presentationDetents([.fraction(0.35)])
      }
    }
    .padding()
    .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
      if breatheModel.isStarted {
        breatheModel.updateTimer()
        updateActivity()
      }
      if breatheModel.isFinished {
        audioModel.stopPlayer()
        stopActivity()
      }
    }
    .alert("Congratulations",isPresented: $breatheModel.isFinished) {
      Button("Start New", role: .cancel) {
        breatheModel.stopTimer()
        breatheModel.addNewTimer = true
        isPresentingNewTimerView = true
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
        audioModel.startPlayer(track: "Beach Ambience")
        startActivity()
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
        .fill(colorScheme == .dark ? Color(red: 0.06, green: 0.06, blue: 0.06) : Color.white)
        .ignoresSafeArea()
    }
    .frame(maxHeight: .infinity, alignment: .bottom)
  }

  func startActivity() {
    let attributes = TimerAttributes(timerName: "Breathe Timer")
    let state = TimerAttributes.TimerStatus(
      endTime: Date()...Date().addingTimeInterval(TimeInterval(breatheModel.totalSeconds)),
      progress: breatheModel.progress)
    let content = ActivityContent<TimerAttributes.ContentState>(state: state, staleDate: nil)

    activity = try? Activity<TimerAttributes>.request(attributes: attributes, content: content, pushType: .token)
  }

  func stopActivity() {
    let state = TimerAttributes.TimerStatus(endTime: Date()...Date(), progress: breatheModel.progress)
    let content = ActivityContent<TimerAttributes.ContentState>(state: state, staleDate: nil)

    Task {
      await activity?.end(content, dismissalPolicy: .immediate)
    }
  }

  func updateActivity() {
    let state = TimerAttributes.TimerStatus(
      endTime: Date()...Date().addingTimeInterval(TimeInterval(breatheModel.totalSeconds)),
      progress: breatheModel.progress)
    let content = ActivityContent<TimerAttributes.ContentState>(state: state, staleDate: nil)

    // Ensure that the activity has been started before trying to update its content.
    if activity != nil {
      Task {
        await activity?.update(content)
      }
    }
  }

  // MARK: Private

  @State private var isPresentingNewTimerView = false

}

// MARK: - Breathe_Previews

struct Breathe_Previews: PreviewProvider {
  static var previews: some View {
    BreatheView()
      .environmentObject(BreatheModel())
      .environmentObject(AudioModel())
  }
}
