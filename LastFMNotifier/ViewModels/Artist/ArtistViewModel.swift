//
//  ArtistViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/01/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistViewModel {
  private let artist: Artist

  init(artist: Artist) {
    self.artist = artist
  }

  var title: String {
    return artist.name
  }

  var imageURL: URL? {
    if let imageURLString = artist.imageURLString {
      return URL(string: imageURLString)
    } else {
      return nil
    }
  }

  var tags: String {
    let topTags = artist.tags.prefix(5)
    return "Tags: " + topTags.map({ $0.name.lowercased() }).joined(separator: ", ")
  }
}
