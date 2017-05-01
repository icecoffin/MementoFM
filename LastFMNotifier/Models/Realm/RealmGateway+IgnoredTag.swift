//
//  RealmGateway+IgnoredTag.swift
//  LastFMNotifier
//
//  Created by Daniel on 24/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: Ignored tags
extension RealmGateway {
  func hasIgnoredTags() -> Bool {
    return !defaultRealm.objects(RealmIgnoredTag.self).isEmpty
  }

  func ignoredTags() -> [IgnoredTag] {
    return defaultRealm.objects(RealmIgnoredTag.self).map({ $0.toTransient() })
  }

  func createDefaultIgnoredTags() -> Promise<Void> {
    return write(block: { realm in
      let ignoredTags = ["rock", "metal", "electronic", "seen live"]
      let realmIgnoredTags = ignoredTags.map({ RealmIgnoredTag.ignoredTag(withName: $0) })
      realm.add(realmIgnoredTags)
    })
  }

  func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return write(block: { realm in
      realm.delete(realm.objects(RealmIgnoredTag.self))
      let realmIgnoredTags = ignoredTags.map({ RealmIgnoredTag.from(ignoredTag: $0) })
      realm.add(realmIgnoredTags)
    })
  }
}
