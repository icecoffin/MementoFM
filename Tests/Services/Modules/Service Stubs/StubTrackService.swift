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
  var stubRecentTracks: [Track] = []
  var user: String = ""
  var from: TimeInterval = 0
  var limit: Int = 0
  var didCallGetRecentTracks = false
  func getRecentTracks(for user: String, from: TimeInterval, limit: Int, progress: ((Progress) -> Void)?) -> Promise<[Track]> {
    self.user = user
    self.from = from
    self.limit = limit
    didCallGetRecentTracks = true
    return .value(stubRecentTracks)
  }

  var tracks: [Track] = []
  var didCallProcessTracks = false
  func processTracks(_ tracks: [Track], using processor: RecentTracksProcessing) -> Promise<Void> {
    self.tracks = tracks
    didCallProcessTracks = true
    return .value(())
  }

}
