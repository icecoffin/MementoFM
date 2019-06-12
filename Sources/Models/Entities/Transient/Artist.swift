//
//  Artist.swift
//  MementoFM
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

struct Artist: TransientEntity, Equatable {
  typealias PersistentType = RealmArtist

  let name: String
  let playcount: Int
  let urlString: String

  let needsTagsUpdate: Bool
  let tags: [Tag]
  let topTags: [Tag]

  func intersectingTopTagNames(with artist: Artist) -> [String] {
    let topTagNames = topTags.map({ $0.name })
    let otherTopTagNames = artist.topTags.map({ $0.name })
    return topTagNames.filter({ otherTopTagNames.contains($0) })
  }

  func updatingPlaycount(to playcount: Int) -> Artist {
    return Artist(name: name, playcount: playcount, urlString: urlString,
                  needsTagsUpdate: needsTagsUpdate, tags: tags, topTags: topTags)
  }

  func updatingTags(to tags: [Tag], needsTagsUpdate: Bool) -> Artist {
    return Artist(name: name, playcount: playcount, urlString: urlString,
                  needsTagsUpdate: needsTagsUpdate, tags: tags, topTags: topTags)
  }

  func updatingTopTags(to topTags: [Tag]) -> Artist {
    return Artist(name: name, playcount: playcount, urlString: urlString,
                  needsTagsUpdate: needsTagsUpdate, tags: tags, topTags: topTags)
  }
}

extension Artist: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(name)
    hasher.combine(playcount)
    hasher.combine(urlString)
  }
}

extension Artist: Mappable {
  init(map: Mapper) throws {
    try name = map.from("name")
    playcount = map.optionalFrom("playcount", transformation: { int(from: $0) }) ?? 0
    urlString = map.optionalFrom("url") ?? ""
    needsTagsUpdate = true
    tags = []
    topTags = []
  }
}
