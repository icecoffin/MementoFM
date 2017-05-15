//
//  TagCell.swift
//  LastFMNotifier
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
  private let containerView = UIView()
  private let textLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(containerView)
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    containerView.backgroundColor = Colors.gold
    containerView.layer.cornerRadius = 6

    containerView.addSubview(textLabel)
    textLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(4).priority(UILayoutPriorityDefaultHigh)
      make.leading.trailing.equalToSuperview().inset(8).priority(UILayoutPriorityDefaultHigh)
    }
    textLabel.font = Fonts.raleway(withSize: 14)
    textLabel.textColor = .white
  }

  func configure(with viewModel: TagCellViewModel) {
    textLabel.text = viewModel.name
  }
}
