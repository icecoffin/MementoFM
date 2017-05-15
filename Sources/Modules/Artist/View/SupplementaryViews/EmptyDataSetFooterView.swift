//
//  EmptyDataSetFooterView.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class EmptyDataSetFooterView: UICollectionReusableView {
  private let textLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addSubview(textLabel)
    textLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(8).priority(UILayoutPriorityDefaultHigh)
      make.leading.trailing.equalToSuperview().inset(16)
    }

    textLabel.numberOfLines = 0
    textLabel.font = Fonts.ralewayMedium(withSize: 14)
    textLabel.textColor = .darkGray
  }

  func configure(with text: String) {
    textLabel.text = text
  }
}
