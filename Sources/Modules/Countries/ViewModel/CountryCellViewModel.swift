//
//  CountryCellViewModel.swift
//  MementoFM
//
//  Created by Dani on 22.12.2019.
//  Copyright © 2019 icecoffin. All rights reserved.
//

import Foundation

enum CountryType {
  case unknown
  case named(name: String)

  var displayName: String {
    switch self {
    case .unknown:
      return "unknown".unlocalized
    case .named(let name):
      return name
    }
  }
}

final class CountryCellViewModel {
  let country: CountryType
  let countText: String

  init(name: String, count: Int, numberFormatter: NumberFormatter) {
    self.country = name.isEmpty ? .unknown : .named(name: name)

    let countText = numberFormatter.string(from: count as NSNumber) ?? "0"
    // Add proper pluralization
    if count == 1 {
      self.countText = "\(countText) artist".unlocalized
    } else {
      self.countText = "\(countText) artists".unlocalized
    }
  }
}
