//
//  LoadingFooterView.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class LoadingFooterView: UICollectionReusableView {
  private let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func setup() {
    addSubview(activityIndicator)
    activityIndicator.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview().inset(4)
      make.centerX.equalToSuperview()
    }
  }
}
