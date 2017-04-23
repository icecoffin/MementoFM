//
//  LibraryCellViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 20/11/2016.
//  Copyright © 2016 icecoffin. All rights reserved.
//

import Foundation

class LibraryCellViewModel {
  private let artist: Artist

  var onSelection: ((Artist) -> Void)?

  init(artist: Artist) {
    self.artist = artist
  }

  var name: String {
    return artist.name
  }

  var playcount: String {
    return "\(artist.playcount) plays"
  }

  var imageURL: URL? {
    guard let imageURLString = artist.imageURLString, !imageURLString.isEmpty else {
      return nil
    }
    return URL(string: imageURLString)
  }

  func handleSelection() {
    onSelection?(artist)
  }
}
