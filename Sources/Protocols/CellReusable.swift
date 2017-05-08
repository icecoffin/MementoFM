//
//  CellReusable.swift
//  LastFMNotifier
//
//  Created by Daniel on 06/12/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import UIKit

protocol CellReusable {
  static var reuseIdentifier: String { get }
}

extension CellReusable {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}

extension UITableViewCell: CellReusable { }
