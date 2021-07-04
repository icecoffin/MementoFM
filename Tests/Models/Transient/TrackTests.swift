//
//  TrackTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Nimble

class TrackTests: XCTestCase {
    func test_initWithMap_setsCorrectProperties() {
        let track = makeSampleTrack()

        expect(track?.artist.name) == "Morphine"
    }

    private func makeSampleTrack() -> Track? {
        guard let data = Utils.data(fromResource: "sample_track", withExtension: "json") else {
            return nil
        }

        let jsonDecoder = JSONDecoder()
        return try? jsonDecoder.decode(Track.self, from: data)
    }
}
