//
//  TopTagsList.swift
//  MementoFM
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct TopTagsList {
  static let maxTagCount = 10
  let tags: [Tag]
}

extension TopTagsList: Mappable {
  init(map: Mapper) throws {
    let tags: [Tag] = try map.from("tag")
    self.tags = Array(tags.prefix(TopTagsList.maxTagCount))
  }
}
