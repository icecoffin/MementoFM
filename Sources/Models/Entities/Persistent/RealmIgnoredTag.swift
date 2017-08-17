//
//  RealmIgnoredTag.swift
//  MementoFM
//
//  Created by Daniel on 23/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmIgnoredTag: Object, RealmEntity {
  dynamic var uuid = UUID().uuidString
  dynamic var name = ""

  class func ignoredTag(withName name: String) -> RealmIgnoredTag {
    let realmIgnoredTag = RealmIgnoredTag()
    realmIgnoredTag.name = name
    return realmIgnoredTag
  }

  class func from(transient: IgnoredTag) -> RealmIgnoredTag {
    let ignoredTag = transient
    let realmIgnoredTag = RealmIgnoredTag()
    realmIgnoredTag.uuid = ignoredTag.uuid
    realmIgnoredTag.name = ignoredTag.name
    return realmIgnoredTag
  }

  func toTransient() -> IgnoredTag {
    return IgnoredTag(uuid: uuid, name: name)
  }
}
