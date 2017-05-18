//
//  LibraryPage.swift
//  LastFMNotifier
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct LibraryPage {
  let index: Int
  let totalPages: Int
  let artists: [Artist]
}

extension LibraryPage: Mappable {
  init(map: Mapper) throws {
    try index = map.from("@attr.page") { int(from: $0) }
    try totalPages = map.from("@attr.totalPages") { int(from: $0) }
    try artists = map.from("artist")
  }
}
