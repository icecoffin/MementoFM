//
//  ArtistStubTopTagsCalculator.swift
//  MementoFM
//
//  Created by Daniel on 04/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM

class ArtistStubTopTagsCalculator: ArtistTopTagsCalculating {
  var numberOfCalculateTopTagsCalled = 0

  func calculateTopTags(for artist: Artist) -> Artist {
    numberOfCalculateTopTagsCalled += 1
    return artist
  }
}
