//
//  TrackStubRepository.swift
//  MementoFM
//
//  Created by Daniel on 26/10/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class TrackStubRepository: TrackRepository {
  private let totalPages: Int
  private let shouldFailWithError: Bool

  init(totalPages: Int, shouldFailWithError: Bool) {
    self.totalPages = totalPages
    self.shouldFailWithError = shouldFailWithError
  }

  func getRecentTracksPage(withIndex index: Int, for user: String,
                           from: TimeInterval, limit: Int) -> Promise<RecentTracksPageResponse> {
    if shouldFailWithError {
      return Promise(error: NSError(domain: "MementoFM", code: 1, userInfo: nil))
    } else {
      let tracks = ModelFactory.generateTracks(inAmount: limit)
      let recentTracksPage = RecentTracksPage(index: index, totalPages: totalPages, tracks: tracks)
      let response = RecentTracksPageResponse(recentTracksPage: recentTracksPage)
      return Promise(value: response)
    }
  }
}
