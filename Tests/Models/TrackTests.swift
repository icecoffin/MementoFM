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
  private func sampleTrack() -> Track? {
    guard let json = Utils.json(forResource: "sample_track", withExtension: "json") as? NSDictionary else {
      return nil
    }

    let mapper = Mapper(JSON: json)
    return try? Track(map: mapper)
  }

  func testInitializingWithMapper() {
    let track = sampleTrack()
    expect(track?.artist.name).to(equal("Morphine"))
  }
}
