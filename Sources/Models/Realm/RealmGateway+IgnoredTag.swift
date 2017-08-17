//
//  RealmGateway+IgnoredTag.swift
//  MementoFM
//
//  Created by Daniel on 24/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

protocol IgnoredTagsDatabaseService {
  func hasIgnoredTags() -> Bool
  func ignoredTags() -> [IgnoredTag]
  func createDefaultIgnoredTags() -> Promise<Void>
  func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void>
}

extension RealmGateway: IgnoredTagsDatabaseService {
  func hasIgnoredTags() -> Bool {
    return !mainQueueRealm.objects(RealmIgnoredTag.self).isEmpty
  }

  func ignoredTags() -> [IgnoredTag] {
    return mainQueueRealm.objects(RealmIgnoredTag.self).map({ $0.toTransient() })
  }

  func createDefaultIgnoredTags() -> Promise<Void> {
    return write(block: { realm in
      let ignoredTags = ["rock", "metal", "electronic", "indie", "alternative", "seen live", "under 2000 listeners"]
      let realmIgnoredTags = ignoredTags.map({ RealmIgnoredTag.ignoredTag(withName: $0) })
      realm.add(realmIgnoredTags)
    })
  }

  func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return write(block: { realm in
      realm.delete(realm.objects(RealmIgnoredTag.self))
      let realmIgnoredTags = ignoredTags.map({ RealmIgnoredTag.from(transient: $0) })
      realm.add(realmIgnoredTags)
    })
  }
}
