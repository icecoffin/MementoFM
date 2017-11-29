//
//  StubTagService.swift
//  MementoFM
//
//  Created by Daniel on 22/11/2017.
//  Copyright © 2017 icecoffin. All rights reserved.
//

import Foundation
@testable import MementoFM
import PromiseKit

class StubTagService: TagServiceProtocol {
  var artists: [Artist] = []
  func getTopTags(for artists: [Artist], progress: ((TopTagsRequestProgress) -> Void)?) -> Promise<Void> {
    self.artists = artists
    return Promise(value: ())
  }

  var expectedTopTags: [Tag] = []
  func getAllTopTags() -> [Tag] {
    return expectedTopTags
  }
}
