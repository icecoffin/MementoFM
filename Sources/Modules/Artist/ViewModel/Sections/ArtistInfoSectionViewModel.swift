//
//  ArtistInfoSectionViewModel.swift
//  MementoFM
//
//  Created by Daniel on 11/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation

final class ArtistInfoSectionViewModel {
  private let artist: Artist

  required init(artist: Artist) {
    self.artist = artist
  }

  var numberOfItems: Int {
    return 1
  }

  func itemViewModel(at index: Int) -> ArtistInfoCellViewModel {
    return ArtistInfoCellViewModel(artist: artist)
  }
}
