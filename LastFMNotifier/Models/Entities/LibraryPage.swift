//
//  LibraryPage.swift
//  LastFMNotifier
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct LibraryPage: Mappable {
  let index: Int
  let totalPages: Int
  let artists: [Artist]

  init(map: Mapper) throws {
    try index = map.from("@attr.page") { int(from: $0) }
    try totalPages = map.from("@attr.totalPages") { int(from: $0) }
    try artists = map.from("artist")
  }

  init(index: Int, totalPages: Int, artists: [Artist]) {
    self.index = index
    self.totalPages = totalPages
    self.artists = artists
  }
}
