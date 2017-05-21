//
//  EmptyDataSetView.swift
//  MementoFM
//
//  Created by Daniel on 20/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class EmptyDataSetView: UIView {
  private let text: String
  private let textLabel = UILabel()

  init(text: String) {
    self.text = text
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addSubview(textLabel)
    textLabel.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.leading.trailing.equalToSuperview().inset(16).priority(999)
    }

    textLabel.numberOfLines = 0
    textLabel.textAlignment = .center
    textLabel.text = text
    textLabel.font = Fonts.ralewayMedium(withSize: 16)
  }
}
