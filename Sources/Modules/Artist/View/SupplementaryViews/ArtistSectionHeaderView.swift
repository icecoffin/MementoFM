//
//  ArtistSectionHeaderView.swift
//  LastFMNotifier
//
//  Created by Daniel on 13/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistSectionHeaderView: UICollectionReusableView {
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
      make.top.equalToSuperview().offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(8).priority(UILayoutPriorityDefaultHigh)
    }

    textLabel.font = Fonts.ralewayBold(withSize: 18)
  }

  func configure(with viewModel: ArtistSectionViewModel) {
    textLabel.text = viewModel.sectionHeaderText
  }
}
