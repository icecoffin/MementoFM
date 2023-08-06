//
//  MockArtistTopTagsCalculator.swift
//  MementoFM
//
//  Created by Daniel on 04/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
import TransientModels
@testable import SharedServices

final class MockArtistTopTagsCalculator: ArtistTopTagsCalculating {
    var numberOfCalculateTopTagsCalled = 0

    func calculateTopTags(for artist: Artist, ignoredTags: [IgnoredTag]) -> Artist {
        numberOfCalculateTopTagsCalled += 1
        return artist
    }
}
