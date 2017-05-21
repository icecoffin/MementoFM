//
//  Track.swift
//  MementoFM
//
//  Created by Daniel on 06/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct Track {
  let artist: Artist
}

extension Track: Mappable {
  init(map: Mapper) throws {
    try artist = map.from("artist")
  }
}
