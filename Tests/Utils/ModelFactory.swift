//
//  ModelFactory.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class ModelFactory {
  class func generateArtist(index: Int = 1) -> Artist {
    return Artist(name: "Artist\(index)", playcount: index, urlString: "http://example.com/artist\(index)",
                  imageURLString: "http://example.com/artist\(index).jpg", needsTagsUpdate: false, tags: [], topTags: [])
  }

  class func generateTrack(index: Int = 1) -> Track {
    let artist = generateArtist(index: index)
    return Track(artist: artist)
  }

  class func generateTracks(inAmount amount: Int) -> [Track] {
    return (1...amount).map { index in generateTrack(index: index) }
  }
}
