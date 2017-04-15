//
//  Tag.swift
//  LastFMNotifier
//
//  Created by Daniel on 07/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct Tag: Mappable {
  let name: String
  let count: Int

  init(map: Mapper) throws {
    try name = map.from("name")
    try count = map.from("count")
  }

  init(name: String, count: Int) {
    self.name = name
    self.count = count
  }
}
