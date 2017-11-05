//
//  ArtistTopTagsCalculator.swift
//  MementoFM
//
//  Created by Daniel on 29/07/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

protocol ArtistTopTagsCalculating: class {
  func calculateTopTags(for artist: Artist) -> Artist
}

class ArtistTopTagsCalculator: ArtistTopTagsCalculating {
  private let ignoredTags: [IgnoredTag]
  private let numberOfTopTags: Int

  init(ignoredTags: [IgnoredTag], numberOfTopTags: Int = 5) {
    self.ignoredTags = ignoredTags
    self.numberOfTopTags = numberOfTopTags
  }

  func calculateTopTags(for artist: Artist) -> Artist {
    let topTags = artist.tags.filter { tag in
      !ignoredTags.contains(where: { ignoredTag in
        tag.name == ignoredTag.name
      })
    }.sorted(by: {
      $0.count > $1.count
    }).prefix(numberOfTopTags)
    return artist.updatingTopTags(to: Array(topTags))
  }
}
