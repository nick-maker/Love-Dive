//
//  LaunchViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/8.
//

import Lottie
import UIKit

class LaunchViewController: UIViewController {

  // MARK: Internal

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.darkBlue
    view.addSubview(animationView)
    HealthKitManager.shared.requestHealthKitPermissions()

    animationView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    animationView.center = view.center
    animationView.alpha = 1

    animationView.play { _ in
      UIView.animate(withDuration: 0.5, animations: {
        self.animationView.alpha = 0
      }, completion: { _ in
        self.animationView.isHidden = true

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
          windowScene.windows.first?.rootViewController = tabBarController
          windowScene.windows.first?.makeKeyAndVisible()
        }
      })
    }
  }

  // MARK: Private

  private let animationView: LottieAnimationView = {
    let lottieAnimationView = LottieAnimationView(name: "Logo")
    lottieAnimationView.backgroundColor = UIColor.darkBlue
    return lottieAnimationView
  }()
}
