//
//  SimilarArtistCell.swift
//  LastFMNotifier
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import Kingfisher

class SimilarArtistCell: UICollectionViewCell {
  private let photoImageView = UIImageView()
  private let nameLabel = UILabel()
  private let tagsLabel = UILabel()
  private let separatorView = UIView()

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
      make.top.equalToSuperview()
      make.bottom.lessThanOrEqualToSuperview().inset(8).priority(UILayoutPriorityDefaultHigh)
      make.leading.equalToSuperview().offset(16)
      make.width.height.equalTo(50)
    }
    photoImageView.backgroundColor = .groupTableViewBackground
    photoImageView.layer.cornerRadius = 25
    photoImageView.layer.masksToBounds = true

    contentView.addSubview(nameLabel)
    nameLabel.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalTo(photoImageView.snp.trailing).offset(16).priority(UILayoutPriorityDefaultHigh)
      make.trailing.equalToSuperview().inset(16)
    }
    nameLabel.numberOfLines = 0
    nameLabel.font = Fonts.ralewayBold(withSize: 16)

    contentView.addSubview(tagsLabel)
    tagsLabel.snp.makeConstraints { make in
      make.top.equalTo(nameLabel.snp.bottom).offset(8)
      make.leading.trailing.equalTo(nameLabel)
      make.bottom.equalToSuperview().inset(8).priority(UILayoutPriorityDefaultHigh)
    }
    tagsLabel.numberOfLines = 0
    tagsLabel.font = Fonts.raleway(withSize: 14)
    tagsLabel.textColor = .darkGray

    contentView.addSubview(separatorView)
    separatorView.snp.makeConstraints { make in
      make.leading.trailing.bottom.equalToSuperview()
      make.height.equalTo(0.5)
    }
    separatorView.backgroundColor = .lightGray
  }

  func configure(with viewModel: SimilarArtistCellViewModel) {
    photoImageView.kf.setImage(with: viewModel.imageURL)
    nameLabel.text = viewModel.name
    tagsLabel.text = viewModel.tags
  }
}
