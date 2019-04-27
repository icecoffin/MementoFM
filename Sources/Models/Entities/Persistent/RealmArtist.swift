//
//  RealmArtist.swift
//  MementoFM
//
//  Created by Daniel on 20/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmArtist: Object, PersistentEntity {
  @objc dynamic var name = ""
  @objc dynamic var playcount = 0
  @objc dynamic var urlString = ""
  @objc dynamic var imageURLString: String?
  @objc dynamic var needsTagsUpdate = true
  var tags = List<RealmTag>()
  var topTags = List<RealmTag>()

  override static func primaryKey() -> String? {
    return "name"
  }

  class func from(transient: Artist) -> RealmArtist {
    let artist = transient
    let realmArtist = RealmArtist()
    realmArtist.name = artist.name
    realmArtist.playcount = artist.playcount
    realmArtist.urlString = artist.urlString
    realmArtist.imageURLString = artist.imageURLString
    realmArtist.tags = List<RealmTag>()
    realmArtist.needsTagsUpdate = artist.needsTagsUpdate
    for tag in artist.tags {
      let realmTag = RealmTag.from(transient: tag)
      realmArtist.tags.append(realmTag)
    }
    for topTag in artist.topTags {
      let realmTag = RealmTag.from(transient: topTag)
      realmArtist.topTags.append(realmTag)
    }
    return realmArtist
  }

  func toTransient() -> Artist {
    return Artist(name: name, playcount: playcount, urlString: urlString,
                  imageURLString: imageURLString, needsTagsUpdate: needsTagsUpdate,
                  tags: tags.map({ $0.toTransient() }), topTags: topTags.map({ $0.toTransient() }))
  }
}
