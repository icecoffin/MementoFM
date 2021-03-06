//
//  MockSimilarArtistsRequestStrategy.swift
//  MementoFMTests
//
//  Created by Daniel on 10/12/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class MockSimilarArtistsRequestStrategy: SimilarArtistsRequestStrategy {
    var minNumberOfIntersectingTags: Int = 0

    var customSimilarArtists: [Artist] = []
    var getSimilarArtistsShouldReturnError = false
    func getSimilarArtists(for artist: Artist) -> Promise<[Artist]> {
        if getSimilarArtistsShouldReturnError {
            return Promise(error: NSError(domain: "MementoFM", code: 6, userInfo: nil))
        } else {
            return .value(customSimilarArtists)
        }
    }
}
