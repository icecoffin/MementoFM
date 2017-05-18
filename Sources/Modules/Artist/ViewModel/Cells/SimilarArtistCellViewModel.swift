//
//  SimilarArtistCellViewModel.swift
//  LastFMNotifier
//
//  Created by Daniel on 14/05/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import UIKit.UIFont

class SimilarArtistCellViewModel {
  private let artist: Artist
  private let commonTags: [String]

  init(artist: Artist, commonTags: [String]) {
    self.artist = artist
    self.commonTags = commonTags
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

  var tags: NSAttributedString {
    return artist.topTags.map({ tag in
      let name = tag.name
      if commonTags.contains(name) {
        return NSAttributedString(string: name, attributes: [NSFontAttributeName: Fonts.ralewayBold(withSize: 14)])
      } else {
        return NSAttributedString(string: name)
      }
    }).joined(separator: ", ")
  }
}