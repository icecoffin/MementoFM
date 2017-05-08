//
//  RealmArtist.swift
//  LastFMNotifier
//
//  Created by Daniel on 20/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import RealmSwift

class RealmArtist: Object {
  dynamic var name = ""
  dynamic var playcount = 0
  dynamic var urlString = ""
  dynamic var imageURLString: String?
  dynamic var needsTagsUpdate = true
  var tags = List<RealmTag>()
  var topTags = List<RealmTag>()

  override static func primaryKey() -> String? {
    return "name"
  }

  class func from(artist: Artist) -> RealmArtist {
    let realmArtist = RealmArtist()
    realmArtist.name = artist.name
    realmArtist.playcount = artist.playcount
    realmArtist.urlString = artist.urlString
    realmArtist.imageURLString = artist.imageURLString
    realmArtist.tags = List<RealmTag>()
    realmArtist.needsTagsUpdate = artist.needsTagsUpdate
    for tag in artist.tags {
      let realmTag = RealmTag.from(tag: tag)
      realmArtist.tags.append(realmTag)
    }
    return realmArtist
  }

  func toTransient() -> Artist {
    return Artist(name: name, playcount: playcount, urlString: urlString,
                  imageURLString: imageURLString, needsTagsUpdate: needsTagsUpdate,
                  tags: tags.map({ $0.toTransient() }), topTags: topTags.map({ $0.toTransient() }))
  }
}
