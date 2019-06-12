//
//  ArtistAvatarView.swift
//  MementoFM
//
//  Created by Dani on 11.06.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class ArtistAvatarView: UIView {
  private let innerView = UIView()
  private let initialsLabel = UILabel()

  init() {
    super.init(frame: .zero)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundColor = .white
    addInnerView()
    addInitialsView()
  }

  private func addInnerView() {
    addSubview(innerView)
    innerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(10)
    }
    innerView.backgroundColor = .appPrimary
  }

  private func addInitialsView() {
    innerView.addSubview(initialsLabel)
    initialsLabel.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview().inset(16)
      make.centerY.equalToSuperview()
    }
    initialsLabel.adjustsFontSizeToFitWidth = true
    initialsLabel.textColor = .white
    initialsLabel.textAlignment = .center
    initialsLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)

    initialsLabel.text = "KK"
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    innerView.layer.cornerRadius = innerView.frame.width / 2
  }
}
