//
//  StubTrackService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class StubTrackService: TrackServiceProtocol {
  var expectedRecentTracks: [Track] = []
  var user: String = ""
  var from: TimeInterval = 0
  var limit: Int = 0
  func getRecentTracks(for user: String, from: TimeInterval, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Track]> {
    self.user = user
    self.from = from
    self.limit = limit
    return Promise(value: expectedRecentTracks)
  }

  var tracks: [Track] = []
  func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> Promise<Void> {
    self.tracks = tracks
    return Promise(value: ())
  }

}
