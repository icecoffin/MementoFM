//
//  TrackEmptyStubRepository.swift
//  MementoFM
//
//  Created by Daniel on 05/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class TrackEmptyStubRepository: TrackRepository {
  func getRecentTracksPage(withIndex index: Int,
                           for user: String,
                           from: TimeInterval,
                           limit: Int) -> Promise<RecentTracksPageResponse> {
    fatalError()
  }
}
