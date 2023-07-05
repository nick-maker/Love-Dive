//
//  DiveCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/18.
//

import UIKit

// MARK: - DiveCell

class DiveCell: ShadowCollectionViewCell, UIGestureRecognizerDelegate {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    setupGesture()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(DiveCell.self)"

  weak var delegate: DiveCellDelegate?
  var isGestureCancelled = false

  var waterDepthLabel = UILabel()
  var dateLabel = UILabel()
  var arrowImage = UIImageView()

  func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
    true
  }

  // MARK: Private

  private func setupUI() {
    contentView.layer.cornerRadius = 20
    contentView.backgroundColor = .dynamicColor

    [waterDepthLabel, dateLabel, arrowImage].forEach { contentView.addSubview($0) }
    [waterDepthLabel, dateLabel, arrowImage].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

    waterDepthLabel.font = UIFont.systemFont(ofSize: 18)
    dateLabel.font = UIFont.systemFont(ofSize: 12)
    dateLabel.textColor = UIColor.lightGray
    arrowImage.image = UIImage(systemName: "chevron.right")

    NSLayoutConstraint.activate([
      waterDepthLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      waterDepthLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
      waterDepthLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

      dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
      dateLabel.topAnchor.constraint(equalTo: waterDepthLabel.bottomAnchor, constant: 2),
      dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

      arrowImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      arrowImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
    ])
  }

  private func setupGesture() {
    let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
    pressGesture.minimumPressDuration = 0.08
    pressGesture.allowableMovement = 5
    pressGesture.delegate = self
    contentView.addGestureRecognizer(pressGesture)
  }

  @objc
  private func handleLongPressGesture(_ sender: UILongPressGestureRecognizer) {
    switch sender.state {
    case .began:
      transform = .identity
      UIView.animate(withDuration: 0.25) {
        self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        self.contentView.backgroundColor = .tapColor
      }
      isGestureCancelled = false
    case .cancelled, .changed:
      UIView.animate(withDuration: 0.25) {
        self.transform = .identity
        self.contentView.backgroundColor = .dynamicColor
      }
      isGestureCancelled = true
    case .ended:
      UIView.animate(withDuration: 0.25) {
        self.transform = .identity
        self.contentView.backgroundColor = .dynamicColor
      }
      if !isGestureCancelled {
        delegate?.cellLongPressEnded(self)
      }
    default:
      break
    }
  }


}

// MARK: - DiveCellDelegate

protocol DiveCellDelegate: AnyObject {
  func cellLongPressEnded(_ cell: DiveCell)
}
