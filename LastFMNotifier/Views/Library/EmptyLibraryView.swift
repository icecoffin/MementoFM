//
//  EmptyLibraryView.swift
//  LastFMNotifier
//
//  Created by Daniel on 20/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class EmptyLibraryView: UIView {
  private let textLabel = UILabel()

  init() {
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
      make.leading.trailing.equalToSuperview().inset(16).priority(UILayoutPriorityDefaultHigh)
    }

    textLabel.numberOfLines = 0
    textLabel.textAlignment = .center
    textLabel.text = NSLocalizedString("No artists found", comment: "")
    textLabel.font = Fonts.ralewayMedium(withSize: 16)
  }
}
