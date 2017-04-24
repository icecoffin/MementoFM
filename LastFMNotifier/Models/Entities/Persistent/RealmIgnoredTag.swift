//
//  RealmIgnoredTag.swift
//  LastFMNotifier
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmIgnoredTag: Object {
  dynamic var uuid = UUID().uuidString
  dynamic var name = ""

  class func from(ignoredTag: IgnoredTag) -> RealmIgnoredTag {
    let realmIgnoredTag = RealmIgnoredTag()
    realmIgnoredTag.uuid = ignoredTag.uuid
    realmIgnoredTag.name = ignoredTag.name
    return realmIgnoredTag
  }

  func toTransient() -> IgnoredTag {
    return IgnoredTag(uuid: uuid, name: name)
  }
}
