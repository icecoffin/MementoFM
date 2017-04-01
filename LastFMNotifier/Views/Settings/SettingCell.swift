//
//  SettingCell.swift
//  LastFMNotifier
//
//  Created by Daniel on 25/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
  private let containerView = UIView()
  private let titleLabel = UILabel()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addContainerView()
    addTitleLabel()
  }

  private func addContainerView() {
    contentView.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(60)
    }
  }

  private func addTitleLabel() {
    containerView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(16)
      make.trailing.equalToSuperview().offset(-16)
      make.centerY.equalToSuperview()
    }

    titleLabel.font = Fonts.ralewayMedium(withSize: 16)
  }

  func configure(with viewModel: SettingCellViewModel) {
    titleLabel.text = viewModel.title
  }
}
