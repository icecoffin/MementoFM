//
//  NSAttributedString+Join.swift
//  MementoFM
//
//  Created by Daniel on 18/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: NSAttributedString {
  func joined(separator: NSAttributedString) -> NSAttributedString {
    var isFirst = true
    return self.reduce(NSMutableAttributedString()) { (result, element) in
      if isFirst {
        isFirst = false
      } else {
        result.append(separator)
      }
      result.append(element)
      return result
    }
  }

  func joined(separator: String) -> NSAttributedString {
    return joined(separator: NSAttributedString(string: separator))
  }
}
