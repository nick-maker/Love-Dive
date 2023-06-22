//
//  DetailActView.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/23.
//

import SwiftUI
import UIKit

struct DetailActView: UIViewControllerRepresentable {

  var divingEntry: [DivingEntry]

  func makeUIViewController(context: Context) -> DetailActViewController {
    let detailActViewController = DetailActViewController()
    detailActViewController.divingEntry = divingEntry
    return detailActViewController
  }

  func updateUIViewController(_ uiViewController: DetailActViewController, context: Context) {
    // Handle any updates to the view controller if needed
  }
}
