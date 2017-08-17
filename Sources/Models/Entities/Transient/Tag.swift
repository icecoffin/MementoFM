//
//  Tag.swift
//  MementoFM
//
//  Created by Daniel on 07/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct Tag: AutoEquatable, AutoHashable {
  let name: String
  let count: Int
}

extension Tag: Mappable, TransientEntity {
  typealias RealmType = RealmTag

  init(map: Mapper) throws {
    let name: String = try map.from("name")
    self.name = name.lowercased()
    try count = map.from("count")
  }
}
