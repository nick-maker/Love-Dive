//
//  BreatheViewModel.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//

import SwiftUI

class BreatheModel: NSObject, ObservableObject, UNUserNotificationCenterDelegate {

  // Mark: Timer
  @Published var progress: CGFloat = 1
  @Published var timerStringValue = "00:00"
  @Published var isStarted = false
  @Published var addNewTimer = false

  @Published var minute = 0
  @Published var seconds = 0
  // Mark: Total timer
  @Published var totalSeconds = 0
  @Published var staticTotalSeconds = 0
  // Mark: Post timer properties
  @Published var isFinished = false

  // Mark: request permission
  func authorizeNotification() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in
    }
    // In app notification
    UNUserNotificationCenter.current().delegate = self
  }

  func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent _: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    completionHandler([.sound, .banner])
  }

  func startTimer() {
    withAnimation(.easeInOut(duration: 0.25)) { isStarted = true }
    timerStringValue = "\(minute >= 10 ? "\(minute):" : "0\(minute):")\(seconds > 10 ? "\(seconds)" : "0\(seconds)")"
    totalSeconds = (minute * 60 + seconds)
    staticTotalSeconds = totalSeconds
    addNewTimer = false
    addNotification()
  }

  func stopTimer() {
    withAnimation {
      isStarted = false
      minute = 0
      seconds = 0
      progress = 1
    }
    totalSeconds = 0
    staticTotalSeconds = 0
    timerStringValue = "00:00"
  }

  func updateTimer() {
    totalSeconds -= 1
    progress = CGFloat(totalSeconds) / CGFloat(staticTotalSeconds)
    progress = progress < 0 ? 0 : progress
    minute = (totalSeconds / 60) % 60
    seconds = totalSeconds % 60
    timerStringValue = "\(minute >= 10 ? "\(minute):" : "0\(minute):")\(seconds >= 10 ? "\(seconds)" : "0\(seconds)")"
    if minute == 0, seconds == 0 {
      isStarted = false
      isFinished = true
    }
  }

  func addNotification() {
    let content = UNMutableNotificationContent()
    content.title = "Love Dive"
    content.subtitle = "Finished Breathing"
    content.sound = UNNotificationSound.defaultCritical

    let request = UNNotificationRequest(
      identifier: UUID().uuidString,
      content: content,
      trigger: UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(staticTotalSeconds), repeats: false))

    UNUserNotificationCenter.current().add(request)
  }

}
