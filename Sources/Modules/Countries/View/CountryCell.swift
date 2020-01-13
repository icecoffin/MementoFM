//
//  CountryCell.swift
//  MementoFM
//
//  Created by Dani on 22.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import UIKit

final class CountryCell: UITableViewCell {
  private let stackView = UIStackView()
  private let nameLabel = UILabel()
  private let countLabel = UILabel()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(stackView)
    stackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }

    stackView.axis = .horizontal
    stackView.spacing = 12
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

    stackView.addArrangedSubview(nameLabel)
    nameLabel.font = .title

    stackView.addArrangedSubview(countLabel)
    countLabel.font = .secondaryContent
    countLabel.textColor = .darkGray
  }

  func configure(with cellViewModel: CountryCellViewModel) {
    switch cellViewModel.country {
    case .unknown:
      nameLabel.textColor = .gray
    case .named:
      nameLabel.textColor = .black
    }
    nameLabel.text = cellViewModel.country.displayName
    countLabel.text = cellViewModel.countText
  }
}
