//
//  RealmTag.swift
//  MementoFM
//
//  Created by Daniel on 09/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTag: Object {
  dynamic var name = ""
  dynamic var count = 0

  class func from(tag: Tag) -> RealmTag {
    let realmTag = RealmTag()
    realmTag.name = tag.name
    realmTag.count = tag.count
    return realmTag
  }

  func toTransient() -> Tag {
    return Tag(name: name, count: count)
  }
}
