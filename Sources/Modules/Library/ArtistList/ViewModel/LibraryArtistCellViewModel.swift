//
//  LibraryArtistCellViewModel.swift
//  MementoFM
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

final class LibraryArtistCellViewModel {
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
    guard let imageURLString = artist.imageURLString, !imageURLString.isEmpty else {
      return nil
    }
    return URL(string: imageURLString)
  }
}
