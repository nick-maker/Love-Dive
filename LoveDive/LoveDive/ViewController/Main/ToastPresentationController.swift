//
//  ToastPresentationController.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/10.
//

import UIKit

class ToastPresentationController: UIPresentationController {
  override var frameOfPresentedViewInContainerView: CGRect {
    guard let containerView = containerView,
          let presentedView = presentedView else { return .zero }

    let inset: CGFloat = 32

    // Make sure to account for the safe area insets
    let safeAreaFrame = containerView.bounds
      .inset(by: containerView.safeAreaInsets)

    let targetWidth = safeAreaFrame.width - 2 * inset
    let fittingSize = CGSize(
      width: targetWidth,
      height: UIView.layoutFittingCompressedSize.height
    )
    let targetHeight = presentedView.systemLayoutSizeFitting(
      fittingSize, withHorizontalFittingPriority: .required,
      verticalFittingPriority: .defaultLow).height

    var frame = safeAreaFrame
    frame.origin.x += inset
    frame.origin.y += frame.size.height - targetHeight - inset * 2
    frame.size.width = targetWidth
    frame.size.height = targetHeight
    return frame
  }

  override func containerViewDidLayoutSubviews() {
    super.containerViewDidLayoutSubviews()
    presentedView?.frame = frameOfPresentedViewInContainerView
  }

  override func presentationTransitionWillBegin() {
    super.presentationTransitionWillBegin()
    presentedView?.layer.cornerRadius = 12
  }

  private var calculatedFrameOfPresentedViewInContainerView = CGRect.zero
  private var shouldSetFrameWhenAccessingPresentedView = false

  override var presentedView: UIView? {
    if shouldSetFrameWhenAccessingPresentedView {
      super.presentedView?.frame = calculatedFrameOfPresentedViewInContainerView
    }
    return super.presentedView
  }

  override func presentationTransitionDidEnd(_ completed: Bool) {
    super.presentationTransitionDidEnd(completed)
    shouldSetFrameWhenAccessingPresentedView = completed
  }

  override func dismissalTransitionWillBegin() {
    super.dismissalTransitionWillBegin()
    shouldSetFrameWhenAccessingPresentedView = false
  }

}
