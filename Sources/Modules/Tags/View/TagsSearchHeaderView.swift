//
//  TagsSearchHeaderView.swift
//  MementoFM
//
//  Created by Daniel on 22/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import UIKit

class TagsSearchHeaderView: UICollectionReusableView {
  private var didAddSearchBar = false

  func addSearchBar(_ searchBar: UISearchBar) {
    if !didAddSearchBar {
      didAddSearchBar = true
      addSubview(searchBar)
    }
  }
}
