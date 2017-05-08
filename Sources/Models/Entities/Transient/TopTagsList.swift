//
//  TopTagsList.swift
//  LastFMNotifier
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct TopTagsList: Mappable {
  let tags: [Tag]

  init(tags: [Tag]) {
    self.tags = tags
  }

  init(map: Mapper) throws {
    try tags = map.from("tag")
  }
}
