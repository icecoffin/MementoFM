//
//  LoadingFooterView.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class LoadingFooterView: UITableViewHeaderFooterView {
  private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  override init(reuseIdentifier: String?) {
    super.init(reuseIdentifier: reuseIdentifier)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(4).priority(999)
      make.centerX.equalToSuperview()
    }
    activityIndicator.startAnimating()
  }
}
