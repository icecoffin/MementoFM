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

  func recalculateArtistTopTags(ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return write { realm in
      let artists = realm.objects(RealmArtist.self)
      for artist in artists {
        let topTags = artist.tags.filter({ realmTag in
          !ignoredTags.contains(where: { ignoredTag in
            realmTag.name == ignoredTag.name
          })
        }).prefix(5)
        artist.topTags.removeAll()
        artist.topTags.append(objectsIn: topTags)
      }
    }
  }
}
