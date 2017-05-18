//
//  RealmGateway+Artist.swift
//  LastFMNotifier
//
//  Created by Daniel on 15/04/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import PromiseKit

fileprivate let numberOfTopTags = 5

extension RealmGateway {
  func saveArtists(_ artists: [Artist]) -> Promise<Void> {
    return write { realm in
      let realmArtists = artists.map({ RealmArtist.from(artist: $0) })
      realm.add(realmArtists, update: true)
    }
  }

  func artistsNeedingTagsUpdate() -> [Artist] {
    let predicate = NSPredicate(format: "needsTagsUpdate == \(true)")
    return mainQueueRealm.objects(RealmArtist.self).filter(predicate).map({ $0.toTransient() })
  }

  func updateArtist(_ artist: Artist, with tags: [Tag]) -> Promise<Void> {
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

  func calculateTopTagsForAllArtists(ignoring ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return write { realm in
      let artists = realm.objects(RealmArtist.self)
      for artist in artists {
        self.calculateTopTags(for: artist, ignoring: ignoredTags)
      }
    }
  }

  func calculateTopTags(for artist: Artist, ignoring ignoredTags: [IgnoredTag]) -> Promise<Void> {
    return write { realm in
      if let realmArtist = realm.object(ofType: RealmArtist.self, forPrimaryKey: artist.name) {
        self.calculateTopTags(for: realmArtist, ignoring: ignoredTags)
      }
    }
  }

  private func calculateTopTags(for artist: RealmArtist, ignoring ignoredTags: [IgnoredTag]) {
    let topTags = artist.tags.filter({ realmTag in
      !ignoredTags.contains(where: { ignoredTag in
        realmTag.name == ignoredTag.name
      })
    }).prefix(numberOfTopTags)
    artist.topTags.removeAll()
    artist.topTags.append(objectsIn: topTags)
  }

  func getArtistsWithIntersectingTopTags(for artist: Artist) -> Promise<[Artist]> {
    return dispatch_promise(DispatchQueue.global()) { () -> [Artist] in
      let topTagNames = artist.topTags.map({ $0.name })
      let predicate = NSPredicate(format: "ANY tags.name IN %@ AND name != %@", topTagNames, artist.name)
      let results = self.getCurrentQueueRealm().objects(RealmArtist.self).filter(predicate)
      return results.map({ $0.toTransient() })
    }
  }
}
