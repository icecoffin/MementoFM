//
//  ArtistCell.swift
//  MementoFM
//
//  Created by Daniel on 22/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

final class ArtistCell: UITableViewCell {
  private let photoImageView = UIImageView()
  private let nameLabel = UILabel()
  private let playcountLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    let outerStackView = UIStackView()
    outerStackView.axis = .horizontal
    outerStackView.alignment = .center
    outerStackView.distribution = .fill
    outerStackView.spacing = 12
    outerStackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    outerStackView.isLayoutMarginsRelativeArrangement = true
    outerStackView.translatesAutoresizingMaskIntoConstraints = false
    outerStackView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)

    contentView.addSubview(outerStackView)
    outerStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    outerStackView.addArrangedSubview(photoImageView)
    configurePhotoImageView()

    let innerStackView = UIStackView()
    innerStackView.axis = .vertical
    innerStackView.distribution = .fill
    innerStackView.spacing = 8
    innerStackView.translatesAutoresizingMaskIntoConstraints = false

    outerStackView.addArrangedSubview(innerStackView)

    innerStackView.addArrangedSubview(nameLabel)
    innerStackView.addArrangedSubview(playcountLabel)

    configureNameLabel()
    configurePlaycountLabel()
  }

  private func configurePhotoImageView() {
    let photoSize: CGFloat = 60
    photoImageView.snp.updateConstraints { make in
      make.width.height.equalTo(photoSize).priority(999)
    }

    photoImageView.layer.cornerRadius = photoSize / 2
    photoImageView.layer.masksToBounds = true
    photoImageView.backgroundColor = .groupTableViewBackground
  }

  private func configureNameLabel() {
    nameLabel.numberOfLines = 0
    nameLabel.lineBreakMode = .byWordWrapping
    nameLabel.font = .ralewayMedium(withSize: 16)
  }

  private func configurePlaycountLabel() {
    playcountLabel.font = .raleway(withSize: 14)
    playcountLabel.textColor = UIColor.gray
  }

  func configure(with viewModel: LibraryArtistCellViewModel) {
    nameLabel.text = viewModel.name
    playcountLabel.text = viewModel.playcount
    if let url = viewModel.imageURL {
      photoImageView.kf.setImage(with: url)
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    photoImageView.kf.cancelDownloadTask()
    photoImageView.image = nil
  }
}
