//
//  DiveCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/18.
//

import UIKit

class DiveCell: UITableViewCell {

  // MARK: Lifecycle

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  static let reuseIdentifier = "\(DiveCell.self)"

  var waterDepthLabel = UILabel()
  var waterTempLabel = UILabel()

  // MARK: Private

  private var containerView = UIView()

  private func setupUI() {
    contentView.addSubview(containerView)
    contentView.backgroundColor = .lightBlue

    containerView.addSubview(waterDepthLabel)
    containerView.addSubview(waterTempLabel)
    containerView.backgroundColor = .systemBackground
    containerView.layer.cornerRadius = 20
    containerView.translatesAutoresizingMaskIntoConstraints = false
    waterDepthLabel.translatesAutoresizingMaskIntoConstraints = false
    waterTempLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

      waterDepthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      waterDepthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      waterDepthLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

      waterTempLabel.leadingAnchor.constraint(equalTo: waterTempLabel.leadingAnchor),
      waterTempLabel.topAnchor.constraint(equalTo: waterDepthLabel.topAnchor, constant: -15),
    ])
  }
}
