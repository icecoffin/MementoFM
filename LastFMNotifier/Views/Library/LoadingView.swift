//
//  LoadingView.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit

class LoadingView: UIView {
  private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
  private let messageLabel = UILabel()

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addActivityIndicator()
    addMessageLabel()
  }

  private func addActivityIndicator() {
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.top.centerX.equalToSuperview()
    }

    activityIndicator.startAnimating()
  }

  private func addMessageLabel() {
    addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.top.equalTo(activityIndicator.snp.bottom).offset(8)
      make.leading.trailing.bottom.equalToSuperview()
    }

    messageLabel.text = NSLocalizedString("LOADING", comment: "")
    messageLabel.font = UIFont.systemFont(ofSize: 12)
    messageLabel.textColor = UIColor.gray
  }
}
