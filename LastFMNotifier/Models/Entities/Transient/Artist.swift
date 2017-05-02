//
//  Artist.swift
//  LastFMNotifier
//
//  Created by Daniel on 06/11/16.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation
import Mapper

private func extractImageURLString(from json: Any?) throws -> String {
  guard let jsonImages = json as? [[String: Any]] else {
    return ""
  }

  let large = jsonImages.filter { dictionary in
    if let size = dictionary["size"] as? String, size == "large" {
      return true
    }
    return false
  }.first

  return large?["#text"] as? String ?? ""
}

struct Artist: Mappable, Hashable {
  let name: String
  let playcount: Int
  let urlString: String
  let imageURLString: String?

  let needsTagsUpdate: Bool
  let tags: [Tag]
  let topTags: [Tag]

  var hashValue: Int {
    return name.hashValue
  }

  init(map: Mapper) throws {
    try name = map.from("name")
    playcount = map.optionalFrom("playcount", transformation: { int(from: $0) }) ?? 0
    urlString = map.optionalFrom("url") ?? ""
    imageURLString = map.optionalFrom("image", transformation: extractImageURLString)
    needsTagsUpdate = true
    tags = []
    topTags = []
  }

  init(name: String, playcount: Int, urlString: String, imageURLString: String?, needsTagsUpdate: Bool, tags: [Tag], topTags: [Tag]) {
    self.name = name
    self.playcount = playcount
    self.urlString = urlString
    self.imageURLString = imageURLString
    self.needsTagsUpdate = needsTagsUpdate
    self.tags = tags
    self.topTags = topTags
  }
}

func == (lhs: Artist, rhs: Artist) -> Bool {
  return lhs.name == rhs.name
}
