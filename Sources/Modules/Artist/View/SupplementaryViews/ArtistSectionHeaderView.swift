//
//  ArtistSectionHeaderView.swift
//  LastFMNotifier
//
//  Created by Daniel on 13/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class ArtistSectionHeaderView: UITableViewHeaderFooterView {
  private let titleLabel = UILabel()

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    contentView.addSubview(titleLabel)
    titleLabel.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(16)
      make.leading.trailing.equalToSuperview().inset(16)
      make.bottom.equalToSuperview().inset(8).priority(999)
    }

    titleLabel.font = Fonts.ralewayBold(withSize: 18)
  }

  func configure(with viewModel: ArtistSectionViewModel) {
    titleLabel.text = viewModel.sectionHeaderText
  }
}
