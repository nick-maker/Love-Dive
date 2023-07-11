//
//  BreatheViewController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/26.
//
import SwiftUI
import UIKit

class BreatheViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    // Create an instance of BreatheModel
    let breatheModel = BreatheModel()
    breatheModel.authorizeNotification()
    let audioModel = AudioModel()

    // Create an instance of BreatheView and add BreatheModel to the environment
    let swiftUIView = BreatheView().environmentObject(breatheModel)
      .environmentObject(audioModel)
    let hostingController = UIHostingController(rootView: swiftUIView)

    // Make sure the hosting controller view is resizable and fits the parent view.
    hostingController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(hostingController.view)
    NSLayoutConstraint.activate([
      hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    // Add the hosting controller as a child view controller so it participates in the view controller lifecycle
    addChild(hostingController)
    hostingController.didMove(toParent: self)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.prefersLargeTitles = true
    navigationItem.title = "Breathe Timer"
    if let descriptor = UIFont.systemFont(ofSize: 34, weight: .bold).fontDescriptor.withDesign(.rounded) {
      let font = UIFont(descriptor: descriptor, size: 34)
      navigationController?.navigationBar.largeTitleTextAttributes = [.font: font]
    }
  }

}
