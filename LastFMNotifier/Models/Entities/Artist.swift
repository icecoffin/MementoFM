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

  var hashValue: Int {
    return name.hashValue
  }

  init(map: Mapper) throws {
    try name = map.from("name")
    playcount = map.optionalFrom("playcount", transformation: { int(from: $0) }) ?? 0
    urlString = map.optionalFrom("url") ?? ""
    imageURLString = map.optionalFrom("image", transformation: extractImageURLString)
  }

  init(name: String, playcount: Int, urlString: String, imageURLString: String?) {
    self.name = name
    self.playcount = playcount
    self.urlString = urlString
    self.imageURLString = imageURLString
  }
}

func == (lhs: Artist, rhs: Artist) -> Bool {
  return lhs.name == rhs.name
}
