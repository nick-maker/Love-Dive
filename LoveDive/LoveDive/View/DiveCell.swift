//
//  DiveCell.swift
//  LoveDive
//
//  Created by Nick Liu on 2023/6/18.
//

import UIKit

class DiveCell: UITableViewCell {

  static let reuseIdentifier = "\(DiveCell.self)"

  var waterDepthLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setupUI() {
    contentView.addSubview(waterDepthLabel)
    contentView.backgroundColor = .systemBackground
    contentView.layer.cornerRadius = 20
    waterDepthLabel.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      waterDepthLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
      waterDepthLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      waterDepthLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
    ])

  }
}
