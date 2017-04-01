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
}
