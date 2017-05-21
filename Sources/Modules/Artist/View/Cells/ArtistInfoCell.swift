//
//  ArtistInfoCell.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Kingfisher

class ArtistInfoCell: UITableViewCell {
  private let photoImageView = UIImageView()

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(photoImageView)
    photoImageView.snp.makeConstraints { make in
      make.top.equalToSuperview().inset(16).priority(999)
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
