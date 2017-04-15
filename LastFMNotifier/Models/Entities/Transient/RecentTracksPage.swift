//
//  RecentTracksPage.swift
//  LastFMNotifier
//
//  Created by Daniel on 06/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct RecentTracksPage: Mappable {
  let index: Int
  let totalPages: Int
  let tracks: [Track]

  init(map: Mapper) throws {
    try index = map.from("@attr.page") { int(from: $0) }
    try totalPages = map.from("@attr.totalPages") { int(from: $0) }
    try tracks = map.from("track")
  }
}
