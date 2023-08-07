//
//  AppDelegate.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/14.
//

import FirebaseCore
import SwiftUI
import UIKit

// MARK: - BreatheApp

@main
struct BreatheApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject var breatheModel: BreatheModel = .init()
  @StateObject var audioModel = AudioModel()
  // Mark: Scene Phase
  @Environment(\.scenePhase) var phase
  // Mark: Storing last time stamp
  @State var lastActiveTimeStamp = Date()

  var body: some Scene {
    WindowGroup {
      BreatheView()
        .environmentObject(breatheModel)
        .environmentObject(audioModel)
    }
    .onChange(of: phase) { newValue in
      if breatheModel.isStarted {
        if newValue == .background {
          lastActiveTimeStamp = Date()
        }
        if newValue == .active {
          // Mark: finding the difference
          let currentTimeStampDiff = Date().timeIntervalSince(lastActiveTimeStamp)
          if breatheModel.totalSeconds - Int(currentTimeStampDiff) <= 0 {
            breatheModel.isStarted = false
            breatheModel.totalSeconds = 0
            breatheModel.isFinished = true
          }
          else {
            breatheModel.totalSeconds -= Int(currentTimeStampDiff)
          }
        }
      }
    }
  }
}

// MARK: - AppDelegate

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    FirebaseApp.configure()
    return true
  }

}
