//
//  EmptyCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/7/10.
//

import UIKit

class EmptyCell: UICollectionViewCell {

  // MARK: Lifecycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(EmptyCell.self)"

  var onExploreButtonTapped: (() -> Void)?

  @objc
  func exploreButtonTapped() {
    onExploreButtonTapped?()
  }

  // MARK: Private

  // Configure your label and button
  private let titleLabel = UILabel()
  private let messageLabel = UILabel()

  private var exploreButton: UIButton = {
    var config = UIButton.Configuration.filled()
    config.cornerStyle = .dynamic
    config.baseBackgroundColor = .pacificBlue
    config.baseForegroundColor = .white
    config.title = "Start exploring"
    let button = UIButton(configuration: config)
    return button
  }()

  private func setupUI() {
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    exploreButton.translatesAutoresizingMaskIntoConstraints = false

    exploreButton.addTarget(self, action: #selector(exploreButtonTapped), for: .touchUpInside)

    titleLabel.text = "No favorites yet"
    messageLabel.text = "As you explore, tap the heart icon to save your favorite diving sites"
    messageLabel.textColor = .secondaryLabel
    messageLabel.numberOfLines = 0

    contentView.addSubview(titleLabel)
    contentView.addSubview(exploreButton)
    contentView.addSubview(messageLabel)

    NSLayoutConstraint.activate([
      titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),

      messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
      messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
      messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
      messageLabel.widthAnchor.constraint(equalToConstant: 40),
      messageLabel.heightAnchor.constraint(equalToConstant: 50),

      exploreButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
      exploreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
    ])
  }

}
