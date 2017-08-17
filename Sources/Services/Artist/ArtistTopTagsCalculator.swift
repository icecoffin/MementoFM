//
//  ArtistTopTagsCalculator.swift
//  MementoFM
//
//  Created by Daniel on 29/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistTopTagsCalculator {
  private let ignoredTags: [IgnoredTag]
  private let numberOfTopTags: Int

  init(ignoredTags: [IgnoredTag], numberOfTopTags: Int) {
    self.ignoredTags = ignoredTags
    self.numberOfTopTags = numberOfTopTags
  }

  func calculateTopTags(for artist: Artist) -> Artist {
    let topTags = artist.tags.filter({ tag in
      !ignoredTags.contains(where: { ignoredTag in
        tag.name == ignoredTag.name
      })
    }).sorted(by: {
      $0.count > $1.count
    }).prefix(numberOfTopTags)
    return Artist(name: artist.name, playcount: artist.playcount, urlString: artist.urlString,
                  imageURLString: artist.imageURLString, needsTagsUpdate: artist.needsTagsUpdate,
                  tags: artist.tags, topTags: Array(topTags))
  }
}
