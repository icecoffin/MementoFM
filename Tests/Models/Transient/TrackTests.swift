//
//  TrackTests.swift
//  MementoFMTests
//
//  Created by Daniel on 06/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import XCTest
@testable import MementoFM
import Mapper
import Nimble

class TrackTests: XCTestCase {
    func test_initWithMap_setsCorrectProperties() {
        let track = makeSampleTrack()

        expect(track?.artist.name) == "Morphine"
    }

    private func makeSampleTrack() -> Track? {
        guard let json = Utils.json(forResource: "sample_track", withExtension: "json") as? NSDictionary else {
            return nil
        }

        let mapper = Mapper(JSON: json)
        return try? Track(map: mapper)
    }
}
