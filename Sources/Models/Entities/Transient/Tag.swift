//
//  Tag.swift
//  LastFMNotifier
//
//  Created by Daniel on 07/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct Tag: Mappable, AutoEquatable, AutoHashable {
  let name: String
  let count: Int

  init(map: Mapper) throws {
    let name: String = try map.from("name")
    self.name = name.lowercased()
    try count = map.from("count")
  }

  init(name: String, count: Int) {
    self.name = name
    self.count = count
  }
}
