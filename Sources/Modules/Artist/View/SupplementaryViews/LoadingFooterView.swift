//
//  LoadingFooterView.swift
//  MementoFM
//
//  Created by Daniel on 15/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

final class LoadingFooterView: UITableViewHeaderFooterView {
  private let activityIndicator = UIActivityIndicatorView(style: .medium)

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    backgroundView = UIView()
    contentView.backgroundColor = .white

    contentView.addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(4)
      make.centerX.equalToSuperview()
    }
    activityIndicator.color = .gray
    activityIndicator.startAnimating()
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    activityIndicator.startAnimating()
  }
}
