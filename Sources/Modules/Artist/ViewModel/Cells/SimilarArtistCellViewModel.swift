//
//  SimilarArtistCellViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class SimilarArtistCellViewModel {
  private let artist: Artist

  init(artist: Artist) {
    self.artist = artist
  }

  var name: String {
    return artist.name
  }

  var playcount: String {
    return "\(artist.playcount) plays".unlocalized
  }

  var imageURL: URL? {
    if let imageURLString = artist.imageURLString {
      return URL(string: imageURLString)
    } else {
      return nil
    }
  }

  var tags: String {
    return artist.topTags.map({ $0.name.lowercased() }).joined(separator: ", ")
  }
}
