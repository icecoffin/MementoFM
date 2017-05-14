//
//  ArtistInfoCellViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 12/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

class ArtistInfoCellViewModel {
  private let artist: Artist

  init(artist: Artist) {
    self.artist = artist
  }

  var imageURL: URL? {
    if let imageURLString = artist.imageURLString {
      return URL(string: imageURLString)
    } else {
      return nil
    }
  }
}
