//
//  ArtistInfoCell.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Kingfisher

class ArtistInfoCell: UICollectionViewCell {
  private let photoImageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(photoImageView)
    photoImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16).priority(UILayoutPriorityDefaultHigh)
      make.bottom.equalToSuperview().inset(4)
      make.centerX.equalToSuperview()
      make.width.height.equalTo(120)
    }

    photoImageView.backgroundColor = .groupTableViewBackground
    photoImageView.layer.cornerRadius = 60
    photoImageView.layer.masksToBounds = true
  }

  func configure(with viewModel: ArtistInfoCellViewModel) {
    photoImageView.kf.setImage(with: viewModel.imageURL)
  }
}
