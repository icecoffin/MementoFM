//
//  TopTagsResponse.swift
//  LastFMNotifier
//
//  Created by Daniel on 02/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct TopTagsResponse: Mappable {
  let topTagsList: TopTagsList

  init(map: Mapper) throws {
    try topTagsList = map.from("toptags")
  }
}
