//
//  UITableView+HeaderVIew.swift
//  LastFMNotifier
//
//  Created by Daniel on 24/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit
import SnapKit

extension UITableView {
  func layoutTableHeaderView() {
    guard let headerView = tableHeaderView else {
      return
    }

    var widthConstraint: Constraint?
    headerView.snp.updateConstraints { make in
      widthConstraint = make.width.equalTo(frame.size.width).constraint
    }

    headerView.setNeedsLayout()
    headerView.layoutIfNeeded()

    let height = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
    widthConstraint?.deactivate()

    headerView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: height)
    headerView.translatesAutoresizingMaskIntoConstraints = true
    tableHeaderView = headerView
  }
}
