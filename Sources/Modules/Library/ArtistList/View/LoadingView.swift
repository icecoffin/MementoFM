//
//  LoadingView.swift
//  MementoFM
//
//  Created by Daniel on 15/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit

final class LoadingView: UIView {
  private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
  private let activityIndicator = UIActivityIndicatorView(style: .white)
  private let messageLabel = UILabel()

  init() {
    super.init(frame: .zero)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addBlurView()
    addActivityIndicator()
    addMessageLabel()
  }

  private func addBlurView() {
    addSubview(blurView)
    blurView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }

  private func addActivityIndicator() {
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(16)
    }

    activityIndicator.startAnimating()
  }

  private func addMessageLabel() {
    addSubview(messageLabel)
    messageLabel.snp.makeConstraints { make in
      make.leading.equalTo(activityIndicator.snp.trailing).offset(16)
      make.centerY.equalToSuperview()
      make.trailing.equalToSuperview().inset(16)
    }

    messageLabel.font = .contentSecondary
    messageLabel.textColor = .white
  }

  func update(with message: String) {
    messageLabel.text = message
  }

  override var intrinsicContentSize: CGSize {
    return CGSize(width: UIView.noIntrinsicMetric, height: 50)
  }
}
