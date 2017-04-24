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
  func ignoredTags() -> [IgnoredTag] {
    return defaultRealm.objects(RealmIgnoredTag.self).map({ $0.toTransient() })
  }

  func updateIgnoredTags(_ ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return write(block: { realm in
      realm.delete(realm.objects(RealmIgnoredTag.self))
      let realmIgnoredTags = ignoredTags.map({ RealmIgnoredTag.from(ignoredTag: $0) })
      realm.add(realmIgnoredTags)
    })
  }
}
