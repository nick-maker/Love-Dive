//
//  Haptic.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/12.
//

import UIKit

enum HapticFeedback {

  // MARK: - Cases

  case selection
  case impact(UIImpactFeedbackGenerator.FeedbackStyle)
  case notification(UINotificationFeedbackGenerator.FeedbackType)

  // MARK: - Properties

  var toString: String {
    switch self {
    case .selection: return "selection"
    case .impact(let feedbackStyle):
      switch feedbackStyle {
      case .light: return "light"
      case .medium: return "medium"
      case .heavy: return "heavy"
      case .soft: return "soft"
      case .rigid: return "rigid"
      @unknown default: return "unknown"
      }
    case .notification(let feedbackType):
      switch feedbackType {
      case .success: return "success"
      case .warning: return "warning"
      case .error: return "error"
      @unknown default: return "unknown"
      }
    }
  }

}

func generateHapticFeedback(for hapticFeedback: HapticFeedback) {
  switch hapticFeedback {
  case .selection:
    // Initialize Selection Feedback Generator
    let feedbackGenerator = UISelectionFeedbackGenerator()

    // Trigger Haptic Feedback
    feedbackGenerator.selectionChanged()
  case .impact(let feedbackStyle):
    // Initialize Impact Feedback Generator
    let feedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)

    // Trigger Haptic Feedback
    feedbackGenerator.impactOccurred()
  case .notification(let feedbackType):
    // Initialize Notification Feedback Generator
    let feedbackGenerator = UINotificationFeedbackGenerator()

    // Trigger Haptic Feedback
    feedbackGenerator.notificationOccurred(feedbackType)
  }
}
