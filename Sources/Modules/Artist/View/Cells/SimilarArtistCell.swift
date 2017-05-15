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
  private let outerStackView = UIStackView()
  private let innerStackView = UIStackView()

  private let photoImageView = UIImageView()
  private let nameLabel = UILabel()
  private let playcountLabel = UILabel()
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
    contentView.addSubview(outerStackView)
    outerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview().priority(UILayoutPriorityDefaultHigh)
    }
    outerStackView.axis = .horizontal
    outerStackView.spacing = 12
    outerStackView.distribution = .fill
    outerStackView.alignment = .top
    outerStackView.isLayoutMarginsRelativeArrangement = true
    outerStackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    outerStackView.addArrangedSubview(photoImageView)
    photoImageView.snp.makeConstraints { make in
      make.width.height.equalTo(50)
    }
    photoImageView.backgroundColor = .groupTableViewBackground
    photoImageView.layer.cornerRadius = 25
    photoImageView.layer.masksToBounds = true

    outerStackView.addArrangedSubview(innerStackView)
    innerStackView.axis = .vertical
    innerStackView.spacing = 6
    innerStackView.distribution = .fill

    innerStackView.addArrangedSubview(nameLabel)
    nameLabel.numberOfLines = 0
    nameLabel.font = Fonts.ralewayBold(withSize: 16)

    innerStackView.addArrangedSubview(playcountLabel)
    playcountLabel.font = Fonts.raleway(withSize: 14)
    playcountLabel.textColor = .gray

    innerStackView.addArrangedSubview(tagsLabel)
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
    playcountLabel.text = viewModel.playcount
    // TODO: bold common tags?
    tagsLabel.text = viewModel.tags
  }
}
