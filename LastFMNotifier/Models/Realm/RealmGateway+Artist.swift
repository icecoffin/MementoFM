//
//  RealmGateway+Artist.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

extension RealmGateway {
  func artistsNeedingTagsUpdate() -> [Artist] {
    let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
    return defaultRealm.objects(RealmArtist.self).filter(predicate).map({ $0.toTransient() })
  }

  @discardableResult func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Void> {
    return write { realm in
      guard let realmArtist = realm.object(ofType: RealmArtist.self, forPrimaryKey: artist.name) else {
        return
      }
      realmArtist.needsTagsUpdate = false
      realmArtist.tags.removeAll()
      tags.forEach { tag in
        realmArtist.tags.append(RealmTag.from(tag: tag))
      }
      realm.add(realmArtist, update: true)
    }
  }
}
