//
//  AppDelegate.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/14.
//

import IQKeyboardManagerSwift
import UIKit
import SwiftUI

@main
struct BreatheApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  @StateObject var breatheModel: BreatheModel = .init()
  @StateObject var audioModel = AudioModel()
  //Mark: Scene Phase
  @Environment(\.scenePhase) var phase
  //Mark: Storing last time stamp
  @State var lastActiveTimeStamp: Date = Date()
  var body: some Scene {
    WindowGroup {
      BreatheContentView()
        .environmentObject(breatheModel)
        .environmentObject(audioModel)

    }
    .onChange(of: phase) { newValue in
      if breatheModel.isStarted {
        if newValue == .background {
          lastActiveTimeStamp = Date()
        }
        if newValue == .active {
          //Mark: finding the difference
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

class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options _: UIScene.ConnectionOptions)
    -> UISceneConfiguration
  {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running,
    // this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }

}
