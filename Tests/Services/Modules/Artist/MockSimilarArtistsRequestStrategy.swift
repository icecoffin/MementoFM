//
//  MockSimilarArtistsRequestStrategy.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import Combine

final class MockSimilarArtistsRequestStrategy: SimilarArtistsRequestStrategy {
    var minNumberOfIntersectingTags: Int = 0

    var customSimilarArtists: [Artist] = []
    var getSimilarArtistsShouldReturnError = false
    func getSimilarArtists(for artist: Artist) async throws -> [Artist] {
        if getSimilarArtistsShouldReturnError {
            throw NSError(domain: "MementoFM", code: 6, userInfo: nil)
        } else {
            return customSimilarArtists
        }
    }
}
