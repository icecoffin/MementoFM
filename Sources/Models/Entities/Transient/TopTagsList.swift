//
//  TopTagsList.swift
//  LastFMNotifier
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

fileprivate let maxTagCount = 10

struct TopTagsList {
  let tags: [Tag]
}

extension TopTagsList: Mappable {
  init(map: Mapper) throws {
    let tags: [Tag] = try map.from("tag")
    self.tags = Array(tags.prefix(maxTagCount))
  }
}
